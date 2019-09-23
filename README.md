![OpenPace](https://github.com/edance/art/blob/master/squeeze/repo-banner.png)

[![Built with Spacemacs](https://cdn.rawgit.com/syl20bnr/spacemacs/442d025779da2f62fc86c2082703697714db6514/assets/spacemacs-badge.svg)](http://spacemacs.org)
[![Build Status](https://travis-ci.org/edance/squeeze.svg?branch=master)](https://travis-ci.org/edance/squeeze)
[![Coverage Status](https://coveralls.io/repos/github/edance/squeeze/badge.svg?branch=master)](https://coveralls.io/github/edance/squeeze?branch=master)
[![license](https://img.shields.io/github/license/edance/squeeze.svg)](https://github.com/edance/squeeze/blob/master/LICENSE.md)

## What is this?

This is the repository for [openpace.co](https://www.openpace.co).
It is built in [Elixir](http://elixir-lang.org/) using the [Phoenix](http://www.phoenixframework.org/) web framework.
We use [Webflow](https://webflow.com) to host our landing pages and content.

## What is OpenPace?

OpenPace is a goal oriented application that helps long distance runners hit their goals and measure their progress and fitness.

## Why is it open source?

Many runners are developers and hackers.
We believe that you should be able to build and hack on your running data.

## What does it look like?

### Dashboard
![Dashboard](https://github.com/edance/art/blob/master/squeeze/screenshots/dashboard.jpg)

### Calendar
![Calendar](https://github.com/edance/art/blob/master/squeeze/screenshots/calendar.jpg)

### Activity
![Activity](https://github.com/edance/art/blob/master/squeeze/screenshots/activity.jpg)

## How can I help?

### Contributing

Here are the steps to get started:

  * Copy `.env.example` file to `.env` with `cp .env.example .env`
  * Create an app for strava [here](https://developers.strava.com).
  * Set environment variables in your `.env` file.
  * Import your environment variables with `export $(cat .env | grep -v ^# | xargs)`
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && yarn install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Feedback

Please email us with any ideas, bugs, suggestions at feedback AT openpace.co.

## Why is it named squeeze?

The project was originally under the domain [squeeze.run](https://squeeze.run) with the goal of taking all your running data and "squeezing" it into summaries and graphs.
