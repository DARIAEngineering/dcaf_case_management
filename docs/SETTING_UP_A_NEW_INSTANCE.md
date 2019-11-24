# Setting up a new instance of DARIA

These are detailed instructions in spinning up an instance in heroku. These assume some familiarity with the ideas and concepts and don't go into much detail, such as where to click, the mechanics involved, etc. You don't need to do this for routine development.

## By the way

If you're an abortion fund and NOT interested in worrying about servers, maintenance, and patching, DCAF already manages the infrastructure (what's referred to in this document as the `DCAF pipeline`) for several abortion funds. For your share of server costs they will manage your instance, apply security patches, etc. Please reach out to us in slack if you're interested in skipping a lot of the tedious technical setup here.

## Main steps

### Preparation and gathering API tokens

First, we generate some API tokens from services that DARIA uses.

* Generate Google OAuth configuration (for Login with Google):
  * If you don't have one, set up a google project to administer this app (or choose an existing account you own - DCAF has one)
  * Once logged in, navigate to https://console.developers.google.com/apis/dashboard and select your project
  * Under "Credentials" follow prompts to "Create credentials" for "OAuth client ID"
  * Configure your OAuth Consent screen:
    * Make your application type public
    * Add your app URL (`https://daria-FUND.herokuapp.com`) as the authorized domain
    * Select "Web Application" when prompted to choose an application type
    * Leave Authorized Javascript origins blank
    * Set Authorized redirect URIs to https://daria-FUND.herokuapp.com/users/auth/google_oauth2/callback
  * Generate a `GOOGLE_KEY` and a `GOOGLE_SECRET` - these values are `DARIA_GOOGLE_KEY` and `DARIA_GOOGLE_SECRET` respectively
* Generate a Google API token (for the Clinic Finder):
  * Enable the Geocoding API
  * Create a Google API key, named `FUND Geocoding API Key`; restrict it to just the Geocoding API
* Optional but recommended: Generate a [Skylight](https://www.skylight.io/) API token -- this is a performance monitoring service
* Optional but recommended: Generate a [Sqreen](https://www.sqreen.io/) API token -- this is a security service

### Create a new heroku app

[Click this here link to spin up a new app](https://heroku.com/deploy?template=https://github.com/DCAFEngineering/dcaf_case_management). This vastly simplifies new instance setup and automatically provisions the necessary Heroku add-ons for you:

* mLabs -- this is a mongodb data service (our database!)
* Sendgrid -- this is used as the email service (our emailer!)
* Logentries -- used for application logging
* Scheduler -- used to run tasks on a cron schedule

Follow the directions to fill out necessary environment variables and configuration for your DARIA instance. (Ask our slack channel if you have questions.) Clicking Deploy App will launch your DARIA instance! You now have an instance running, but there are still some followup tasks.

### If not within the DCAF pipeline

- [ ] In Heroku, make sure someone other than you has access to the instance -- make sure you aren't the only member of your fund with Heroku panel access!
- [ ] Confirm that you are using HTTPS with heroku ACM ([Automated Certificate Management](https://devcenter.heroku.com/articles/automated-certificate-management)). Note that this may require a paid heroku dyno. (For the love of god, do not enter real data into DARIA unless you have HTTPS set up.)

### Finish up service setup

- [ ] Set up an uptime monitor (we recommend StatusCake!)
- [ ] Go to Heroku, click on `Scheduler`, and add the nightly cleanup job: `$ rake nightly cleanup`, dyno size hobby, frequency daily, 08:00 UTC

### Smoke test to confirm everything is working right 

- [ ] Go to the root url at `http://daria-FUND.herokuapp.com`. Confirm that this loads, and redirects you to `https://...`
- [ ] Create yourself an admin account from the rails console. Confirm that this sends an email to you
- [ ] After you get that email, log in with google to confirm the oauth signin flow works. (This should use the `DARIA_GOOGLE_KEY` and `DARIA_GOOGLE_SECRET` creds. If something's jacked up, make sure you have these set properly.)
- [ ] Confirm that the lines are properly set and show up right (if you have just one line, this will send you straight to the call list)
- [ ] Confirm that the top left badge name (`DARIA - full fund name`) is set properly
- [ ] Confirm that you can create and update a patient. Delete it afterwards in the rails console

### In-app configuration before you start entering data

- [ ] Go to Admin Tools -> Clinic Management and enter info about clinics you work with
- [ ] Go to Admin Tools -> Config Management and enter info about other funds your work with, insurance options you want to track, etc.
- [ ] Go to Admin Tools -> User Management and create any other admin or user accounts

### When you start entering data

* There's a specialized endpoint for bulk data entry at `/data_entry` not linked from the main dashboards. This has most of the info in one form and helps speed the data entry process up if you are entering patients en masse, for example.

## gl hf
