# Setting up a new instance of DARIA

These are detailed instructions in spinning up an instance in heroku on the DCAF pipeline. It assumes that you already have access set up and permissions on the following resources:

* Heroku pipeline (for provisioning)
* Google Cloud (for oauth and key)
* Sentry (for keys)
* Sqreen (for keys)

## By the way

If you're an abortion fund and NOT interested in worrying about servers, maintenance, and patching, DCAF already manages the infrastructure (what's referred to in this document as the `DCAF pipeline`) for several abortion funds. For your share of server costs (generally $25/month) our team will manage your instance, apply security patches, etc. Please reach out to us in slack if you're interested in skipping a lot of the tedious technical setup here.

## Main steps

### Information gathering

To provision an app, we'll need the following information. The DARIA team member requesting the provisioning should have all this information.

* Short abbreviation of the fund (e.g. DCAF) - referred to as FUND
* Name of the fund (e.g. DC Abortion Fund) - referred to as FUND_FULL
* Phone number of the abortion fund (e.g. 202-000-1111) - referred to as FUND_PHONE
* Name and email of the fund admins (e.g. Susan Everyteen - susan@example.com) - we create initial admin accounts for these people
* Website of the fund (e.g. dcabortionfund.org) - referred to as FUND_DOMAIN

### Gathering API tokens and secrets

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
* Generate a [Sqreen](https://www.sqreen.io/) API token

### Provision the instance in the heroku pipeline

[Click this here link to spin up a new app](https://heroku.com/deploy?template=https://github.com/DCAFEngineering/dcaf_case_management). This vastly simplifies new instance setup and automatically provisions the necessary Heroku add-ons for you.

Fill in the form as follows (stuff in caps are variables you should have on hand):

* App name should be `daria-FUND`
* App owner should be the `casemanager` team
* Click `Add this app to a pipeline` and select `casemanager-pipeline`, then `production`
* In the config vars section, fill in config variables based on what you have. Use defaults where applicable for fields like `CSP_VIOLATION_URI` and `DARIA_LINES`; the DARIA team member leading the onboarding will tell you if you need to change a default value. You should have the resour

Clicking Deploy App will launch the new DARIA instance! We should now have an instance running, but there are still some followup tasks to handle.

### Finish up service setup

* Set up an uptime monitor for the new domain. (We generally use StatusCake for right now but will switch to a team monitor soon; use an existing monitor as a guide to configure.)
* Go to the new app in Heroku, click on `Scheduler`, and add the nightly cleanup job: `$ rake nightly_cleanup`, dyno size hobby, frequency daily, 08:00 UTC

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
