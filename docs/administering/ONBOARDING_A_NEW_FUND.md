# Onboarding a new fund to our managed pipeine

These are detailed instructions to onboarding a new fund into our managed pipeline. It assumes that you already have access set up and permissions on the resources we use.

## By the way

If you're an abortion fund and NOT interested in worrying about servers, maintenance, and patching, the DARIA team manage the infrastructure for several abortion funds (what's referred to in this document as the `pipeline`). For your share of server costs ($25/month) our team will manage your instance, apply security patches, etc. Please reach out to us in slack if you're interested in skipping a lot of the tedious technical setup here. If you are trying to use this, you'll likely need to make some on-the-fly adjustments as this guide assumes you have access to all the resources in here.

## Main steps

### Information gathering

To provision an app, we'll need the following information. The DARIA team member requesting the provisioning should provide all this information to you.

* Short abbreviation of the fund (e.g. DCAF) - referred to as `NAME`, or `NAME_LOWERCASED` if it should be lowercase
* Full name of the fund (e.g. DC Abortion Fund) - referred to as `FULL_NAME`
* Phone number of the abortion fund (e.g. 202-000-1111) - referred to as `FUND_PHONE`
* Website of the fund (e.g. dcabortionfund.org) - referred to as `FUND_DOMAIN`
* Name and email of the fund admins (e.g. Susan Everyteen - susan@example.com) - we create initial admin accounts for these people

### Gathering API tokens and secrets

We also need to have some API tokens and such that we generate or dig up when we provision.

* Set up the subdomain in heroku
  * Open up the pipeline in Heroku and go to the production instance, then open up Settings, then go to Domains.
  * Click Add Domain and enter in `NAME_LOWERCASED.dariaservices.com`.
  * Save the DNS target this generates - you'll need it next in Namecheap.

* Set up the DNS in Namecheap
  * Open up the Namecheap control panel and head to Advanced DNS.
  * Add a new CNAME Record, with the host of `NAME_LOWERCASED`, and the DNS target from the step above.

* Configure Google OAuth (for Login with Google):
  * Go to our [GCP project](https://console.cloud.google.com/apis/credentials?project=daria-services-multitenant)
  * Open up `DARIA Services Production` from the list of Client IDs to edit
  * Add a new `Authorized redirect URI` using the pattern, using `NAME_LOWERCASED` as the subdomain, and save.

* Insert the new fund record:
  * Open up a rails console `heroku run rails c -a (multitenant_app_name)`. You're gonna be in here for a few steps, so don't exit out right away.
  * Insert the fund record as follows: `Fund.create! name: NAME, subdomain: NAME_LOWERCASED, domain: FUND_DOMAIN, full_name: FULL_NAME, phone: FUND_PHONE`. (For example: `Fund.create! name: 'CAT', subdomain: 'cat', domain: 'www.catfund.org', full_name: 'Cat Fund', phone: '281-330-8004')`

* Set that fund as Active:
  * TK

* Set up the Lines:
  * TK

* Set up the first users:
  * TK







tkkkkk

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
* Confirm that the lines are properly set and show up right. For most funds, this means after logging in you will go straight to the call list. For funds with more than one line, you'll go to a line selection screen instead. If this is does not behave as expected, hop into the console and check that `Line.all` has objects associated with the new values.
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
