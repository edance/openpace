# Squeeze Running App

## Overview

I want an running app that will basically tell me how far to run today and at what pace. Anything more than that is gravy.

## Scenarios

As a runner,

- I want to create a calendar of events like runs and weight exercises.
- I want to see my planned events for today.
- I want to create a goal.
- I want to create different paces depending on my goals and events.
- I want to see my recent activities.

## Goals

- [x] Deploy on heroku
- [ ] Connect to strava using [strava wrapper](https://github.com/slashdotdash/strava)
- [x] Add license
- [ ] Get the tests to pass and add travis ci badge
- [ ] Add inch-ci badge to project
- [x] Add exdoc and setup github pages
- [ ] Add guide markdown pages to show how it works
- [ ] Get a domain for this project

## ENV Variables

To run correctly, these variables must be set:

  * `STRAVA_CLIENT_ID`: Client id when setting up strava oauth.
  * `STRAVA_CLIENT_SECRET`: Secret from strava oauth.
  * `HEROKU_URL`: This is the url of the server. Needed for the callback url.

## Getting Started

  1. Create an app for strava [here](https://developers.strava.com).
  2. Set environment variables above.

## Basic Phoenix Stuff

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## App Schema

### Accounts/Users

Stores the name and common information for a user. This is pretty obvious.

- [string] first_name
- [string] last_name
- [string] description
- [string] avatar
- [string] city
- [string] state
- [string] country

### Accounts/Credentials

Stores the data to connect to one of the services. Right now only, we will only have strava.

- [string] provider - will be `strava` until another authentication method is supported
- [string] token - token from strava that will be used to get the information
- [string] uid - unique identifier for the user on strava (used for authentication)
- belongs_to user

### Dashboard/Goals

Every user has one current goal and many past goals. Goals are a distance and a
pace. An example of a goal would be to run a 3 hour marathon.

- [float] distance (in meters)
- [integer] duration (in seconds)
- [string] name (optional) - the name of your race. Most goals will be for a given race.
- [date] date (optional) - date to accomplish the goal.
- [boolean] current - whether this is the current goal or past goal.
- belongs_to user

### Dashboard/Paces

Paces are a little bit more complicated. A user has many paces and a pace
includes a modifier on the users current goal. Seems confusing right? Yeah I'm
not sure exactly how this will work yet.

Here are some basic paces based on our goal above:

|Workout             |Pace per mile       |Modifier            |
|--------------------|--------------------|--------------------|
|Easy                |8:52                |goal + 120 secs     |
|Tempo               |6:52                |goal + 0 secs       |
|Speed               |6:17                |goal - 35 secs      |
|Strength            |6:42                |goal - 10 secs      |
|Long                |7:22                |goal + 30 secs      |

- [string] name - the name of the pace e.g. Easy, Tempo, Long
- [integer] offset - number of seconds difference from goal pace
- belongs_to user

### Dashboard/Events (Workout)

Events for the most part are planned runs. They belong to a user and a pace.
They hold the distance or time to be covered in the run. For example, today's
event could be 10 miles at the easy pace. This means I should run 10 miles
around 8:52 a mile.

- [string] name (optional) - Name of the event or workout
- [float] distance (in meters) - Distance of the content of the workout. This does not include warmup or cooldown.
- [date] date
- [boolean] warmup - whether this workout needs a warmup
- [boolean] cooldown - whether this workout needs a cooldown
- belongs_to user
- belongs_to pace

### Dashboard/Activities

Activities are where the strava integration comes in. An activity holds the data
about a run that has already been completed. Eventually we will match up the
events with activities and display if the pace/distance/time was sufficient to
mark the workout as complete.

- [string] name
- [float] distance (in meters)
- [integer] duration
- [datetime] start_at

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
