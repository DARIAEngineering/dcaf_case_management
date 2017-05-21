# Setting up a new instance of DARIA

These are detailed instructions in spinning up an instance in heroku. These assume some familiarity with the ideas and concepts and don't go into much detail, such as where to click, the mechanics involved, etc.

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
* Go to `Settings` and set the buildpack to `heroku/ruby`
* Also under settings, set the following config variables with the following values (values tk)
- (possibly ACME_DOMAIN, ACME_EMAIL, HEROKU_APP, HEROKU_TOKEN?)
- `CM_RESOURCES_URL`
- `CSP_VIOLATION_URI` (note to self: did this dirty)
- `DARIA_FUND`
- `DARIA_FUND_FULL`
- `DARIA_GOOGLE_KEY`
- `DARIA_GOOGLE_SECRET`
- `FUND_MAILER_DOMAIN`
- `LANG`
- `LINES`
- `mongodb`
- `mongohost`
- `mongopass`
- `mongoport`
- `mongouser`
- `NEW_RELIC_LICENSE_KEY` (note to self: did this dirty)
- `RAILS_LOG_TO_STDOUT`
- `RAILS_SERVE_STATIC_FILES`
- `SECRET_KEY_BASE`
- `SITE_URL` ()

## Optional steps

* If within DCAF pipeline, go to the pipeline after Heroku app is created and add app to pipeline, so it can enjoy downstream

* If not within DCAF pipeline, in Heroku, add some other app members if there aren't any. Make sure you aren't the only member of your fund with config access!

## Checklist

* Go to root url
* Create yourself an admin account from the rails console. Confirm that this sends an email to the email you put down confirming that 
* After you get that email, log in with google to confirm the oauth signin flow works. (This should use the `DARIA_GOOGLE_KEY` and `DARIA_GOOGLE_SECRET` creds.)
* Confirm that the lines are properly set and show up right
* Confirm that the top left badge name (`DARIA - full fund name`) is set properly
* 