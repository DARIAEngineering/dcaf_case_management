# Setting up a new instance of DARIA

These are detailed instructions in spinning up an instance in heroku. These assume some familiarity with the ideas and concepts and don't go into much detail, such as where to click, the mechanics involved, etc.

## By the way

DCAF has a lot of the surrounding infrastructure set up in such a way that it's easy to add new instances to our set. So please reach out to us if you're interested in skipping a lot of the tedious technical setup here.

## Main steps

### Create a new heroku app

* Create a new Heroku app (if in DCAF pipeline: named xxx-fundname)

* Open new app, go to `Resources` and install the following add-ons:
- Logentries (TryIt version)
- mLab MongoDB (sandbox version)
- Heroku scheduler (standard version)
- SendGrid (starter version)
* Click on `Scheduler` and set up the scheduled cleanup job:
- `$ rake nightly cleanup`, dyno size hobby, frequency daily, 08:00 UTC

* Set up an uptime monitor (we recommend StatusCake!)
* Set up a CSP report endpoint (we recommend report-uri.io)
* Set up a google cloud account and generate OAuth credentials (Google Cloud Platform -> API Manager -> Credentials -> Create Credentials)

* Go back to heroku, to `Settings` and set the buildpack to `heroku/ruby`
* Also under settings, set the following config variables with the following values (values tk)

- (possibly ACME_DOMAIN, ACME_EMAIL, HEROKU_APP, HEROKU_TOKEN? may be OBE due to heroku ACM)
- `CM_RESOURCES_URL` (usually a link to the google drive folder with CM resources in it)
- `CSP_VIOLATION_URI` (from your CSP report endpoint)
- `DARIA_FUND` (fund abbreviation. e.g. `DCAF`)
- `DARIA_FUND_FULL` (full fund name. e.g. `DC Abortion Fund`)
- `DARIA_GOOGLE_KEY` (from google cloud account)
- `DARIA_GOOGLE_SECRET` (from google cloud account)
- `FUND_MAILER_DOMAIN` (domain you want emails to come from. e.g. `dcabortionfund.org`)
- `LINES` - (Lines to divide calls into, separated by commas. If one line, just put `Main`)
- `mongodb` (database from MONGODB_URI)
- `mongohost` (hostname from MONGODB_URI)
- `mongopass` (password from MONGODB_URI)
- `mongoport` (port from MONGODB_URI)
- `mongouser` (user from MONGODB_URI)
- `NEW_RELIC_LICENSE_KEY` (Get from New Relic APM)
- `RAILS_LOG_TO_STDOUT` (set to `true`)
- `RAILS_SERVE_STATIC_FILES` (set to `true`)
- `SITE_URL` (The URL, without http, your CMs will go to. e.g. `app.myabortionfund.org`)
- `SKYLIGHT_AUTH_TOKEN` (get it from Skylight)



(did not do these yet)
* Go into logentries and add anyone who needs to be added to the alerts. This should be just people who need to know about application errors, pretty much.

#### You don't need to worry about

* Setting `SECRET_KEY_BASE` (the buildpack does it for you)

## Optional steps

* If within DCAF pipeline, go to the pipeline after Heroku app is created and add app to pipeline, so it can enjoy downstream deployments

* If not within DCAF pipeline, in Heroku, add some other app members if there aren't any. Make sure you aren't the only member of your fund with config access!

## Checklist after setup

### Smoke test

- [ ] Go to root url
- [ ] Create yourself an admin account from the rails console. Confirm that this sends an email to you
- [ ] After you get that email, log in with google to confirm the oauth signin flow works. (This should use the `DARIA_GOOGLE_KEY` and `DARIA_GOOGLE_SECRET` creds.)
- [ ] Confirm that the lines are properly set and show up right
- [ ] Confirm that the top left badge name (`DARIA - full fund name`) is set properly
- [ ] Confirm that you can create and update a patient. Delete it afterwards in the rails console

### Before you start entering data

- [ ] Go to Admin Tools -> Clinic Management and enter info about clinics your work with
- [ ] Create any other admin accounts by going to Admin Tools -> User Management and following the workflow there

### When you start entering data

* There's a specialized endpoint for bulk data entry at `/data_entry` not linked anywhere, this should

## gl hf
