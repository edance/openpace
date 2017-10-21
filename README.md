# Fitbit on Phoenix

## Overview
I would like to build something to download my fitbit and strava data. I'm not sure how far I am going to get on this.

## Goals

- [x] Deploy on heroku
- [x] Connect via oauth to fitbit api
- [ ] Learn phoenix along the way

## ENV Variables

To run correctly, these variables must be set:

  * `FITBIT_CLIENT_ID`: Client id when setting up fitbit oauth.
  * `FITBIT_CLIENT_SECRET`: Secret from fitbit oauth.
  * `HEROKU_URL`: This is the url of the server. Needed for the callback url.

## Getting Started

  1. Create an app for fitbit [here](https://dev.fitbit.com/apps/new).
  2. Set environment variables above.

## Basic Phoenix Stuff

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
