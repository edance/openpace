![Squeeze](https://github.com/edance/art/blob/master/squeeze/repo-banner.png)

[![Built with Spacemacs](https://cdn.rawgit.com/syl20bnr/spacemacs/442d025779da2f62fc86c2082703697714db6514/assets/spacemacs-badge.svg)](http://spacemacs.org)
[![Build Status](https://travis-ci.org/edance/squeeze.svg?branch=master)](https://travis-ci.org/edance/squeeze)
[![Coverage Status](https://coveralls.io/repos/github/edance/squeeze/badge.svg?branch=master)](https://coveralls.io/github/edance/squeeze?branch=master)
[![license](https://img.shields.io/github/license/edance/squeeze.svg)](https://github.com/edance/squeeze/blob/master/LICENSE.md)

Try it yourself: [https://www.openpace.co](https://www.openpace.co)

## Scenarios

As a runner,

- I want to create a calendar of events like runs and weight exercises.
- I want to see my planned events for today.
- I want to create a goal.
- I want to create different paces depending on my goals and events.
- I want to see my recent activities.

## Run your own Squeeze

  * Copy `.env.example` file to `.env` with `cp .env.example .env`
  * Create an app for strava [here](https://developers.strava.com).
  * Set environment variables in your `.env` file.
  * Import your environment variables with `export $(cat .env | grep -v ^# | xargs)`
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && yarn install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Additional Setup Tasks

These tasks are not required to run squeeze.

* `mix setup.stripe` - creates the stripe billing options
* `mix setup.subscriptions` - creates the strava webhook subscription

## Translations

Every time that we add a new call to gettext in the templates, we need to update our POT and PO files. We can accomplish that with a single task:

```bash
mix gettext.extract --merge
```

### Pending Translations

To update and add to existing locales, please visit the folders below and update the PO files.

* [French (fr)](https://github.com/edance/squeeze/blob/master/priv/gettext/fr/LC_MESSAGES)
* [German (de)](https://github.com/edance/squeeze/blob/master/priv/gettext/de/LC_MESSAGES)
* [Spanish (es)](https://github.com/edance/squeeze/blob/master/priv/gettext/es/LC_MESSAGES)
* [Russian (ru)](https://github.com/edance/squeeze/blob/master/priv/gettext/ru/LC_MESSAGES)

### New Translations

To add new locales, run this task below to create PO files for that locale:

```bash
mix gettext.merge priv/gettext --locale it
```

### Testing Translations

Locale is set in the locale plug which first checks the `locale` query param, then the `locale` cookie, and finally the `Accept-Language` request header. The easiest way to test is to visit [`localhost:4000?locale=fr`](http://localhost:4000?locale=fr)

## FAQ/Contact

  * Official website: https://www.openpace.co
  * Guides: WIP
  * Docs: WIP
  * Source: https://github.com/edance/squeeze
