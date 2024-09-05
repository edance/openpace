use rustler::{Encoder, Env, Error, Term, NifStruct};
use std::fs::File;
use std::io::BufReader;
use fitparser;

#[derive(NifStruct)]
#[module = "Squeeze.FitRecord"]
struct FitRecord {
    kind: String,
    fields: Vec<(String, String)>,
}

#[rustler::nif(schedule = "DirtyCpu")]
fn parse_fit_file<'a>(env: Env<'a>, file_path: String) -> Result<Term<'a>, Error> {
    println!("Parsing FIT files using Profile version: {}", fitparser::profile::VERSION);
    
    let fp = File::open(file_path).map_err(|e| Error::Term(Box::new(e.to_string())))?;
    let mut reader = BufReader::new(fp);
    
    let records = fitparser::from_reader(&mut reader)
        .map_err(|e| Error::Term(Box::new(e.to_string())))?;

    let fit_records: Vec<FitRecord> = records.into_iter().map(|record| {
        FitRecord {
            kind: record.kind().to_string(),
            fields: record.fields().iter().map(|field| {
                (field.name().to_string(), field.value().to_string())
            }).collect(),
        }
    }).collect();

    Ok(fit_records.encode(env))
}

rustler::init!("Elixir.Squeeze.RustFit");
