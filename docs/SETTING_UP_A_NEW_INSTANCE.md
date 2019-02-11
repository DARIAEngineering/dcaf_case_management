# Setting up a new instance of DARIA

These are detailed instructions in spinning up an instance in heroku. These assume some familiarity with the ideas and concepts and don't go into much detail, such as where to click, the mechanics involved, etc. You don't need to do this for routine development.

## By the way

DCAF has a lot of the surrounding infrastructure set up in such a way that it's easy to add new instances to our set (what's referred to in this document as the `DCAF pipeline`). So please reach out to us if you're interested in skipping a lot of the tedious technical setup here.

## Main steps

### Create a new heroku app

[Click this here link to spin up a new app](https://heroku.com/deploy?template=https://github.com/DCAFEngineering/dcaf_case_management). Follow the directions to fill out environment variables and configuration. (Ask our slack channel if you have questions.)

* Go into logentries and add anyone who needs to be added to the alerts. This should be just people who need to know about application errors, pretty much.
* Set up a google cloud account and generate OAuth credentials (Google Cloud Platform -> API Manager -> Credentials -> Create Credentials, can be set up alongside existing creds for different environments)
* Set up an uptime monitor (we recommend StatusCake!)
* Click on `Scheduler` and set up the scheduled cleanup job:
- `$ rake nightly cleanup`, dyno size hobby, frequency daily, 08:00 UTC

Optionally but recommended:

## Optional steps

* Set `SKYLIGHT_AUTH_TOKEN` (get it from Skylight, this is a performance monitoring service)
* Set `SQREEN_TOKEN` (get it from Sqreen, this is a security service)
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
