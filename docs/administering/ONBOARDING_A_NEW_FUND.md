# Onboarding a new fund to our managed pipeine

These are detailed instructions to onboarding a new fund into our managed `daria-services-pipeline`. It assumes that you already have access set up and permissions on the resources we use.

## By the way

If you're an abortion fund and NOT interested in worrying about servers, maintenance, and patching, the DARIA team manage the infrastructure for several abortion funds (what's referred to in this document as the `daria-services-pipeline`). For your share of server costs ($25/month) our team will manage your instance, apply security patches, etc. Please reach out to us in [Slack](https://app.slack.com/client/T02GC3VEL/C0E6APB36) if you're interested in skipping a lot of the tedious technical setup here. If you are trying to use this, you'll likely need to make some on-the-fly adjustments as this guide assumes you have access to all the resources in here.

## Main steps

### Information gathering

To provision an app, we'll need the following information. The DARIA team member requesting the provisioning should provide all this information to you.

* Short abbreviation of the fund (e.g. DCAF) - referred to as `NAME`, or `NAME_LOWERCASED` if it should be lowercase
* Full name of the fund (e.g. DC Abortion Fund) - referred to as `FULL_NAME`
* Phone number of the abortion fund (e.g. 202-000-1111) - referred to as `FUND_PHONE`
* Website of the fund (e.g. dcabortionfund.org) - referred to as `FUND_DOMAIN`
* Name and email of the fund admins (e.g. Susan Everyteen - susan@example.com) - we create initial admin accounts for these people
* Possibly, the different lines they want.

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
  * Insert the fund record as follows: `Fund.create! name: NAME, subdomain: NAME_LOWERCASED, site_domain: FUND_DOMAIN, domain: 'dariaservices.com', full_name: FULL_NAME, phone: FUND_PHONE`. (For example: `Fund.create! name: 'CAT', subdomain: 'cat', site_domain: 'www.catfund.org', domain: 'dariaservices.com', full_name: 'Cat Fund', phone: '281-330-8004')`

* Set that fund as Active for scoping purposes:
  * `ActsAsTenant.current_tenant = Fund.find_by(name: NAME)`

* Set up the Lines:
  * If you didn't get explicit instructions on which lines, that means they just need one, `Main`. Run `Line.create name: 'Main'`.
  * If you DID get a set of lines to create, for every line they want, run `Line.create name: LINE_NAME`. ex: `Line.create name: 'Cats'`.

* Set up the first users, and also do a little smoke testing while you're at it:
  * Set yourself up first, using this snippet:

```
scratch_pass = SecureRandom.alphanumeric
User.create email: 'your@email.org',
            name: 'Your Name',
            role: :admin,
            password: scratch_pass,
            password_confirmation: scratch_pass
```

  * Create the support contractor monitor user, using this snippet:

```
scratch_pass = SecureRandom.alphanumeric
User.create email: 'daria-user@opentechstrategies.com',
            name: 'OpenTechStrategies Monitor',
            role: :admin,
            password: scratch_pass,
            password_confirmation: scratch_pass
```

  * Repeat with the other admin users requested by the fund.

* Smoke test to confirm things are working properly.
  * Head to the domain you set up and try logging in with google, to affirm that OAuth is properly set up. If that doesn't work, check that OAuth is configured properly in the Google Cloud console.
  * Confirm that the lines are properly set and show up right. For most funds, this means after logging in you will go straight to the call list. For funds with more than one line, you'll go to a line selection screen instead. If this is does not behave as expected, hop into the console and check that `Line.all` has objects associated with the new values.
  * Confirm that the top left badge name (`DARIA - full fund name`) is showing properly. If this is weird, check that the fund's `full_name` attribute is set right in the rails console.

  * Log in at the domain you set up, using Google. (This will confirm that logging in with google works.)
  * Head to Admin > User Management and create their first fund users.

* Clean up our mess.
  * Destroy the user you made to log in and smoke test: `User.find_by(email: 'your@email.org').destroy`

### Notify the fund and the team that everything is set

Send this email to the DARIA team member that requested provisioning, subbing the all caps variables:

```
Hi, we've provisioned the requested instance. You can log in at (NEW_URL) when you're ready.

When you do so, you should configure your DARIA instance by doing the following to start:
* Log in with Google (or reset their passwords and log in)
* Go to Admin > Clinic Management and enter info about clinics they work with
* Go to Admin > Config Management and enter info about other funds they work with, insurance options they track, etc
* Go to Admin > User Management and create other accounts.
```

## All set!
