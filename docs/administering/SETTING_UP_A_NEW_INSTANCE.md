# Setting up a new instance of DARIA

These are detailed instructions in spinning up an instance in heroku on the DCAF pipeline. It assumes that you already have access set up and permissions on the resources we use.

## By the way

If you're an abortion fund and NOT interested in worrying about servers, maintenance, and patching, DCAF already manages the infrastructure (what's referred to in this document as the `DCAF pipeline`) for several abortion funds. For your share of server costs (generally $25/month) our team will manage your instance, apply security patches, etc. Please reach out to us in slack if you're interested in skipping a lot of the tedious technical setup here. If you are trying to use this, you'll likely need to make some on-the-fly adjustments as this guide assumes you have access to all the resources in here.

## Main steps

### Information gathering

To provision an app, we'll need the following information. The DARIA team member requesting the provisioning should provide all this information to you.

* Short abbreviation of the fund (e.g. DCAF) - referred to as `FUND`
* Name of the fund (e.g. DC Abortion Fund) - referred to as `FUND_FULL`
* Phone number of the abortion fund (e.g. 202-000-1111) - referred to as `FUND_PHONE`
* Website of the fund (e.g. dcabortionfund.org) - referred to as `FUND_DOMAIN`
* Name and email of the fund admins (e.g. Susan Everyteen - susan@example.com) - we create initial admin accounts for these people

### Gathering API tokens and secrets

We also need to have some API tokens and such that we generate or dig up when we provision.

* Generate Google OAuth configuration (for Login with Google):
  * Go to our [GCP project](https://console.cloud.google.com/home/dashboard?project=dcaf-single-sign-on-production)
  * On the left menu, `APIs & Services > Credentials > Create Credentials > OAuth Client ID` to create a new set of OAuth credentials
  * Fill in the form as follows: Application type: Web Application, Name: FUND_FULL from above, Authorized Javascript origins: (leave blank), Authorized redirect URIs: https://daria-FUND.herokuapp.com/users/auth/google_oauth2/callback, then click Create
  * Keep tabs on the generated the Client ID and Client secret; these are `DARIA_GOOGLE_KEY` and `DARIA_GOOGLE_SECRET`

* Grab our Google API token:
  * Go to our [GCP project](https://console.cloud.google.com/home/dashboard?project=dcaf-single-sign-on-production)
  * On the left menu, `APIs & Services > Credentials`
  * Copy the Key value of the `Google Geo API Key`; this is `GOOGLE_GEO_API_KEY`

* Get the Sentry DSN key we use:
  * Head to our [Sentry client keys](https://sentry.io/settings/dcaf-engineering/projects/daria/keys) and get the DSN value. This is `SENTRY_DSN`

* Grab a Sqreen API token:
  * Log in to [Sqreen](https://www.sqreen.io/), then click [here](https://my.sqreen.com/new-application) to create a new application.
  * Fill out as follows: Application name: daria-FUND, Language of the application: Ruby, Environment: 'production'. Click the `Show instructions` button
  * Look for the value of `token` on the right side. `daria-FUND` is `SQREEN_APP_NAME` and the token is `SQREEN_TOKEN`

* Grab a Sendgrid API token:
  * NOTE: Only two people have access to this, @colinxfleming and @xmunoz for the time being. This may expand in the future. If you can't get ahold of them when you're setting this up, use a `SENDGRID_PASSWORD` env var from an existing instance and file a github ticket to fix later.
  * Log in to [SendGrid](https://www.sendgrid.com/)
  * Go to Settings > API Keys > Create API Key
  * Create a new API key named `daria-FUND` with full access and save it. This is your `SENDGRID_PASSWORD`.

### Provision the instance in the heroku pipeline

[Click this here link to spin up a new app](https://heroku.com/deploy?template=https://github.com/DCAFEngineering/dcaf_case_management). This vastly simplifies new instance setup and automatically provisions the necessary Heroku add-ons for you.

Fill in the form as follows (stuff in caps are variables you should have on hand):

* App name should be `daria-FUND`
* App owner should be the `casemanager` team
* Click `Add this app to a pipeline` and select `casemanager-pipeline`, then `production`
* In the config vars section, fill in config variables based on what you have. Use defaults where applicable for fields like `CSP_VIOLATION_URI` and `DARIA_LINES`; the DARIA team member leading the onboarding will tell you if you need to change a default value. You should have the resour

Clicking Deploy App will launch the new DARIA instance! We should now have an instance running, but there are still some followup tasks to handle.

### Complete service setup

* Make a new fund thru the rails console: `heroku run rails c -a daria-FUND`, then `Fund.create name: 'FUND', subdomain: 'daria-FUND', domain: 'herokuapp.com', site_domain: 'FUND_DOMAIN', full_name: 'FUND_FULL_NAME', phone: 'FUND_PHONE'`
* Set up an uptime monitor for the new domain. (We generally use StatusCake for right now but will switch to a team monitor soon; use an existing monitor as a guide to configure.)
* Go to the new app in Heroku, click on `Scheduler`, and add the nightly cleanup job: `$ rake nightly_cleanup`, dyno size hobby, frequency daily, 08:00 UTC

### Smoke test to confirm everything is working right 

With the instance set up, we want to make sure it's properly configured and working before we let users in.

You should be able to access the rails console via this snippet: `heroku run rails c -a daria-FUND`

* Create yourself an admin account from the rails console. Confirm that this sends an email to you notifying you of account creation. This confirms we can save new users to the database and that the mailer is properly configured. If an email doesn't send, check that the Sendgrid Heroku addon is working right and that the sendgrid env vars are properly set. You can use this snippet:
```
scratch_pass = SecureRandom.alphanumeric
User.create email: 'your@email.org',
            name: 'Your Name',
            role: :admin,
            password: scratch_pass,
            password_confirmation: scratch_pass,
            fund: Fund.first
```
* Go to the url at `http://daria-FUND.herokuapp.com`. Confirm that this loads, and redirects you to `https://...`
* Confirm the oauth signin flow works by clicking the `Sign in with Google` button. This confirms that oauth is properly set up. If something is weird here, check that `DARIA_GOOGLE_KEY` and `DARIA_GOOGLE_SECRET` are properly set and configured.
* Confirm that the lines are properly set and show up right. For most funds, this means after logging in you will go straight to the call list. For funds with more than one line, you'll go to a line selection screen instead. If this is does not behave as expected, check that the `DARIA_LINES` environment variable is properly set.
* Confirm that the top left badge name (`DARIA - full fund name`) is showing properly. If this is weird, check that  `Fund.first.full_name` attribute is set right.
* Confirm that you can create and update a patient in the UI. Click the Magnifying Glass icon below `Build Your Call List` and fill in the new patient partial that appears below as follows: Phone: 000-000-0000, Name: DB Test. Click the `Add new patient` button to create the patient. Delete the patient you made in the rails console with this snippet: `Patient.find_by(name: 'DB Test').destroy`. If this acts weird, notify the slack channel and start looking at the logs/stack trace to investigate.

### Clean up our mess

We've confirmed everything is working as expected, so we'll want to make accounts for handoff and clean up some of our mess.

* Create new users for the fund's admins. You can do this via the UI or in the rails console with this snippet: `User.create email: 'your@email.org', name: 'Your Name', role: :admin, password: 'random string', password_confirmation: 'same random string as in password'`. Throw away the password after generating it.
* Destroy the user you made to log in and smoke test: `User.find_by(email: 'your@email.org').destroy`
* Create an email for the support contractor test account: `User.create email: 'daria-user@opentechstrategies.com', name: 'OpenTechStrategies Monitor', role: :admin, password: 'random string', password_confirmation: 'same random string as in password'`

### Let people know things are ready

Send this email to the DARIA team member that requested provisioning, subbing the all caps variables:

```
Hi, we've provisioned the requested instance. Please let them know they can log in at SITE_URL when they're ready.

When they do so, they should do the following to start:
* Log in with Google (or reset their passwords and log in)
* Go to Admin > Clinic Management and enter info about clinics they work with
* Go to Admin > Config Management and enter info about other funds they work with, insurance options they track, etc
* Go to Admin > User Management and create other accounts.
```

## All set!
