# Setting up a new instance of DARIA

These are detailed instructions in spinning up an instance in heroku. These assume some familiarity with the ideas and concepts and don't go into much detail, such as where to click, the mechanics involved, etc. You don't need to do this for routine development.

## By the way

DCAF has a lot of the surrounding infrastructure set up in such a way that it's easy to add new instances to our set (what's referred to in this document as the `DCAF pipeline`). So please reach out to us if you're interested in skipping a lot of the tedious technical setup here.

## Main steps

### Create a new heroku app

[Click this here link to spin up a new app](https://heroku.com/deploy?template=https://github.com/DCAFEngineering/dcaf_case_management). By deploying using this link, the following accounts will be automatically provisioned and managed via Heroku (as heroku add-ons). This means that each individual app deployed with this link will have its own unique accounts with the following:

* mLabs -- this is a mongodb data service
* Sendgrid -- this is used as the email service
* Logentries -- used for application logging
* Scheduler -- used to run tasks on a cron schedule

*Note -- if you choose to deploy this app manually rather than via the link provided above, you will need to handle your own set up for your mongodb, email, logging, and cron services.*

Follow the directions to fill out necessary environment variables and configuration for your DARIA instance. (Ask our slack channel if you have questions.)

* Go into logentries and add anyone who needs to be added to the alerts. This should be just people who need to know about application errors, pretty much.
* Set up an uptime monitor (we recommend StatusCake!)
* Click on `Scheduler` and set up the scheduled cleanup job:
- `$ rake nightly cleanup`, dyno size hobby, frequency daily, 08:00 UTC
* Set up Google OAuth credentials
  * Set up a google account to administer this app (or choose an existing account you own)
  * Once logged in, navigate to https://console.developers.google.com/apis/dashboard
  * Add a project (note -- credentials can be set up alongside existing creds for different environments)
  * Enable the Google+ API (this is necessary to use google for sign in to the app)
  * Click to "Create OAuth client ID"
  * Configure your OAuth Consent screen
    * Make your application type public
    * Authorized Javascript Origins should be https://your-app.herokuapp.com 
    * Authorized redirect URIs should be https://your-app.herokuapp.com/users/auth/google_oauth2/callback
  * Fill in the `DARIA_GOOGLE_KEY` and `DARIA_GOOGLE_SECRET` env vars with your client id and client secret
* While still in the google developers console, enable the Geocoding API, create an API key, and set the `GOOGLE_GEO_API_KEY` in heroku to that API key

## Optional (but recommended) steps

* Set `SKYLIGHT_AUTH_TOKEN` (get it from [Skylight](https://www.skylight.io/), this is a performance monitoring service)
* Set `SQREEN_TOKEN` (get it from [Sqreen](https://www.sqreen.io/), this is a security service)
* if you have a custom domain set up, set up heroku ACM
* If not within DCAF pipeline, in Heroku, add some other app members if there aren't any. Make sure you aren't the only member of your fund with config access!

## Checklist after setup

### Smoke test

- [ ] Go to root url
- [ ] Create yourself an admin account from the rails console. Confirm that this sends an email to you
- [ ] After you get that email, log in with google to confirm the oauth signin flow works. (This should use the `DARIA_GOOGLE_KEY` and `DARIA_GOOGLE_SECRET` creds. If something's jacked up, make sure you have these set properly.)
- [ ] Confirm that the lines are properly set and show up right
- [ ] Confirm that the top left badge name (`DARIA - full fund name`) is set properly
- [ ] Confirm that you can create and update a patient. Delete it afterwards in the rails console

### Before you start entering data

- [ ] Go to Admin Tools -> Clinic Management and enter info about clinics you work with
- [ ] Go to Admin Tools -> Config Management and enter info about other funds your work with, insurance options you want to track, etc.
- [ ] Create any other admin or user accounts by going to Admin Tools -> User Management and following the workflow there

### When you start entering data

* There's a specialized endpoint for bulk data entry at `/data_entry` not linked from the main dashboards. This has most of the info in one form and helps speed the data entry process up if you are entering patients en masse, for example.

## gl hf
