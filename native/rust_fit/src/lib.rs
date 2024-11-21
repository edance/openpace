use chrono::{DateTime, NaiveDateTime, Utc};
use fitparser;
use fitparser::profile::MesgNum;
use polyline::encode_coordinates;
use rustler::{Encoder, Env, Error, NifStruct, Term};
use std::collections::HashMap;
use std::fs::File;
use std::io::BufReader;
use geo_types::LineString;

#[derive(NifStruct)]
#[module = "Squeeze.FitRecord.Coordinates"]
struct Coordinates {
    lat: f64,
    lon: f64,
}

#[derive(NifStruct)]
#[module = "Squeeze.FitRecord.Trackpoint"]
struct Trackpoint {
    altitude: Option<f64>,
    cadence: Option<i32>,
    coordinates: Option<Coordinates>,
    distance: Option<f64>,
    heartrate: Option<i32>,
    velocity: Option<f64>,
    moving: bool,
    time: i64,
}

#[derive(NifStruct)]
#[module = "Squeeze.FitRecord.Lap"]
struct Lap {
    average_cadence: Option<f64>,
    average_speed: Option<f64>,
    distance: Option<f64>,
    elapsed_time: Option<i32>,
    start_index: i32,
    end_index: i32,
    lap_index: i32,
    max_speed: Option<f64>,
    moving_time: Option<i32>,
    name: Option<String>,
    split: i32,
    start_date: String,
    start_date_local: String,
    total_elevation_gain: Option<f64>,
}

#[derive(NifStruct)]
#[module = "Squeeze.FitRecord"]
struct Activity {
    r#type: String,
    activity_type: String,
    distance: Option<f64>,
    duration: Option<i32>,
    moving_time: Option<i32>,
    elapsed_time: Option<i32>,
    start_at: String,
    start_at_local: String,
    elevation_gain: Option<f64>,
    polyline: String,
    trackpoints: Vec<Trackpoint>,
    laps: Vec<Lap>,
}

fn parse_timestamp(timestamp: &str) -> Result<DateTime<Utc>, Error> {
    // Try ISO format first
    if let Ok(dt) = DateTime::parse_from_rfc3339(timestamp) {
        return Ok(dt.with_timezone(&Utc));
    }

    // Try custom format
    let dt = NaiveDateTime::parse_from_str(timestamp, "%Y-%m-%d %H:%M:%S %z")
        .map_err(|e| Error::Term(Box::new(e.to_string())))?;
    
    Ok(DateTime::from_naive_utc_and_offset(dt, Utc))
}

fn get_sport_type(sport: &str) -> (String, String) {
    match sport {
        "running" => ("Run".to_string(), "run".to_string()),
        "cycling" => ("Ride".to_string(), "bike".to_string()),
        "swimming" => ("Swim".to_string(), "swim".to_string()),
        _ => (sport.to_string(), "other".to_string()),
    }
}

fn get_value_by_priority(fields: &HashMap<String, String>, keys: &[&str]) -> Option<String> {
    for key in keys {
        if let Some(value) = fields.get(*key) {
            return Some(value.clone());
        }
    }
    None
}

fn parse_coordinates(fields: &HashMap<String, String>) -> Option<Coordinates> {
    let lat = fields.get("position_lat")
        .and_then(|v| v.parse::<f64>().ok())
        .map(|v| v / 11_930_465.0);
    
    let lon = fields.get("position_long")
        .and_then(|v| v.parse::<f64>().ok())
        .map(|v| v / 11_930_465.0);

    match (lat, lon) {
        (Some(lat), Some(lon)) => Some(Coordinates { lat, lon }),
        _ => None
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
fn parse_fit_file<'a>(env: Env<'a>, file_path: String) -> Result<Term<'a>, Error> {
    let fp = File::open(file_path).map_err(|e| Error::Term(Box::new(e.to_string())))?;
    let mut reader = BufReader::new(fp);
    
    let records = fitparser::from_reader(&mut reader)
        .map_err(|e| Error::Term(Box::new(e.to_string())))?;

    // Find session data
    let session = records.iter()
        .find(|record| record.kind() == MesgNum::Session)
        .ok_or_else(|| Error::Term(Box::new("No session data found".to_string())))?;

    let session_fields: HashMap<String, String> = session.fields().iter()
        .map(|field| (field.name().to_string(), field.value().to_string()))
        .collect();

    let start_time = parse_timestamp(&session_fields["start_time"])?;
    
    // Parse trackpoints
    let trackpoints: Vec<Trackpoint> = records.iter()
        .filter(|record| record.kind() == MesgNum::Record)
        .map(|record| {
            let fields: HashMap<String, String> = record.fields().iter()
                .map(|field| (field.name().to_string(), field.value().to_string()))
                .collect();

            let timestamp = parse_timestamp(&fields["timestamp"]).unwrap_or(start_time);
            let time = (timestamp - start_time).num_seconds();

            Trackpoint {
                altitude: get_value_by_priority(&fields, &["enhanced_altitude", "altitude"])
                    .and_then(|v| v.parse().ok()),
                cadence: fields.get("cadence").and_then(|v| v.parse().ok()),
                coordinates: parse_coordinates(&fields),
                distance: fields.get("distance").and_then(|v| v.parse().ok()),
                heartrate: fields.get("heart_rate").and_then(|v| v.parse().ok()),
                velocity: get_value_by_priority(&fields, &["enhanced_speed", "speed"])
                    .and_then(|v| v.parse().ok()),
                moving: true,
                time,
            }
        })
        .collect();

    // Create a LineString from our coordinates
    let coords: LineString<f64> = LineString::from(
        trackpoints.iter()
            .filter_map(|tp| tp.coordinates.as_ref())
            .map(|coord| (coord.lon, coord.lat))
            .collect::<Vec<(f64, f64)>>()
    );

    // Encode with precision and handle the Result
    let polyline = encode_coordinates(coords, 5).unwrap();


    // Parse laps
    let laps: Vec<Lap> = records.iter()
        .filter(|record| record.kind() == MesgNum::Lap)
        .enumerate()
        .map(|(i, record)| {
            let fields: HashMap<String, String> = record.fields().iter()
                .map(|field| (field.name().to_string(), field.value().to_string()))
                .collect();

            let start_time = parse_timestamp(&fields["start_time"]).unwrap_or(start_time);

            Lap {
                average_cadence: get_value_by_priority(&fields, &["avg_running_cadence", "avg_cadence"])
                    .and_then(|v| v.parse().ok()),
                average_speed: get_value_by_priority(&fields, &["enhanced_avg_speed", "avg_speed"])
                    .and_then(|v| v.parse().ok()),
                distance: fields.get("total_distance").and_then(|v| v.parse().ok()),
                elapsed_time: fields.get("total_elapsed_time").and_then(|v| v.parse().ok()),
                start_index: 0,
                end_index: 0,
                lap_index: i as i32,
                max_speed: get_value_by_priority(&fields, &["enhanced_max_speed", "max_speed"])
                    .and_then(|v| v.parse().ok()),
                moving_time: fields.get("total_elapsed_time").and_then(|v| v.parse().ok()),
                name: fields.get("event").cloned(),
                split: (i + 1) as i32,
                start_date: start_time.naive_utc().to_string(),
                start_date_local: start_time.naive_utc().to_string(),
                total_elevation_gain: fields.get("total_ascent").and_then(|v| v.parse().ok()),
            }
        })
        .collect();

    let (type_str, activity_type) = get_sport_type(&session_fields["sport"]);

    let activity = Activity {
        r#type: type_str,
        activity_type,
        distance: session_fields.get("total_distance").and_then(|v| v.parse().ok()),
        duration: session_fields.get("total_elapsed_time").and_then(|v| v.parse().ok()),
        moving_time: session_fields.get("total_elapsed_time").and_then(|v| v.parse().ok()),
        elapsed_time: session_fields.get("total_elapsed_time").and_then(|v| v.parse().ok()),
        start_at: start_time.to_string(),
        start_at_local: start_time.to_string(),
        elevation_gain: session_fields.get("total_ascent").and_then(|v| v.parse().ok()),
        polyline,
        trackpoints,
        laps,
    };

    Ok(activity.encode(env))
}

rustler::init!("Elixir.Squeeze.RustFit");
