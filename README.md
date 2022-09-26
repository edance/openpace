<h1>
  <a href="https://www.openpace.co/" target="_blank">
   <img src="https://github.com/edance/art/raw/master/squeeze/repo-banner.png" alt="Openpace" width="100%">
  </a>
</h1>

[![Built with Spacemacs](https://cdn.rawgit.com/syl20bnr/spacemacs/442d025779da2f62fc86c2082703697714db6514/assets/spacemacs-badge.svg)](http://spacemacs.org)
[![Build Status](https://github.com/edance/openpace/actions/workflows/ci.yml/badge.svg)](https://github.com/edance/openpace/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/edance/openpace/badge.svg?branch=main)](https://coveralls.io/github/edance/openpace?branch=main)
[![license](https://img.shields.io/github/license/edance/openpace.svg)](https://github.com/edance/openpace/blob/main/LICENSE.md)

OpenPace is an open-source, web application that helps runners run their fastest marathon built with [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view). It features tools to hit new personal bests, analyze your training program, and take a deep dive into your race performance.

From a developer standpoint, it features:

  * Sync's all fitness data from [Strava](https://github.com/slashdotdash/strava) including activities, GPS, heart rate, pace information.

  * Dashboard based off of the [Argon Dashboard by Creative Tim](https://www.creative-tim.com/product/argon-dashboard) using [Bootstrap 4](https://getbootstrap.com)

  * Canvas charts provided by [Chart.js](https://chartjs.org) using [Phoenix LiveView hooks](https://hexdocs.pm/phoenix_live_view/js-interop.html#client-hooks-via-phx-hook)

  * Maps using [Mapbox GL](https://mapbox.com)

  * Payment processing with Stripe using the [Stripity Stripe](https://github.com/beam-community/stripity_stripe)

I'm actively working on Openpace and can use any help I can get. Feel free to create an issue or open a pull request.

![Dashboard](https://github.com/edance/openpace/raw/ml-playground/.github/imgs/dashboard.png)


## Documentation

Documentation is hosted using ex_doc. And you can view the documentation [here](https://www.openpace.co/docs).


## Development

You'll need to install Elixir v1.13 or later. I recommend installing using [asdf](https://github.com/asdf-vm/asdf) with `asdf install elixir`.

```shell
git clone https://github.com/edance/openpace.git
cd openpace

# Copy the example env to your own file and edit it
cp .env.example .env

# Use this command to export the variables into your system
export $(cat .env | grep -v ^# | xargs)

# Get dependencies, create and seed database, and install js deps
mix setup

# Start Phoenix Server
iex -S mix phx.server
```

You will then be able to sign in with `a@b.co` and the password `password`.

### Environment Variables

To run locally, you'll need to set up a [strava api account](https://www.strava.com/settings/api). And set the following environment variables.

  * STRAVA_CLIENT_ID

  * STRAVA_CLIENT_SECRET

  * STRAVA_WEBHOOK_TOKEN

There are additional environment variables in `.env.example`.

### Feedback

Please create a github issue with any ideas, feedback, or suggestions, etc. Pull requests are welcome.

## Why is it named squeeze?

The project was originally under the domain [squeeze.run](https://squeeze.run) with the goal of taking all your running data and "squeezing" it into summaries and graphs.

## Deployment on Fly

This project is run on fly.io. You can run your own with `fly deploy`.

Fly deploy does not include `mix` so one-off tasks have to be run using a command like:

```shell
fly ssh console -C  "/app/bin/squeeze eval Squeeze.TaskModule.method"
```

See `Squeeze.Release.migrate` for an example.

You can also open remote iex with:

```shell
fly ssh console -C  "/app/bin/squeeze remote"
```
