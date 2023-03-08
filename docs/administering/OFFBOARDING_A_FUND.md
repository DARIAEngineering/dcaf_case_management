# Offboarding a fund from our managed pipeine

These are detailed instructions to offboarding a fund from our managed `daria-services-pipeline`. It assumes that you already have access set up and permissions on the resources we use. It assumes you have the Heroku CLI configured.

Fund data ultimately belongs to the Fund. These are the steps and timeline we follow to ensuring we do not retain any information after a Fund no longer needs DARIA.

## Main steps

At a high level, we are:
- Removing Fund-specific information from our production database
- Removing the fund configuration on our infrastructure
- Removing the fund from our contact systems

### Removing Production Data for the Fund

Schedule a maintenance window with a potential downtime. This will only be necesary in the fallback case that we restore from the database snapshot.

Start by taking a snapshot of the database in heroku:
- Open up the pipeline in Heroku and go to the production instance, then open up Resources, then click on Heroku Postgres, then open Durability
- Create a manual snapshot

I suggest doing these console commands by connecting to the console via the Heroku CLI, as I have found the GUI console can close unexpectedly, losing the console output.

1. Run `heroku run bash`.
2. Run `rails c` and confirm the `fund.name` of the fund you wish to remove, and `exit`.
3. Run the rake command with the actual fund name inside the [] to remove the fund & all its related objects. The quotes are required.
   ```bash
   rails "fund_management:delete_fund[CatFund]"
   ```
   NOTE: This step takes a long time to run, on the order of 10 minutes. Be patient if the script appears to be hanging. It's likely not hanging. If you are still unsure, the script can be safely interrupted and restarted after you have investigated the console.
4. Review the output of the script to confirm the fund's objects are completely deleted and the other funds look unaffected.
   - If anything appears to have gone wrong with the other funds, restore from the database backup created earlier.

### Removing the Subdomain Configuration

#### Remove Google OAuth
- Go to our [GCP project](https://console.cloud.google.com/apis/credentials?project=daria-services-multitenant).
- Open up DARIA Services Production from the list of Client IDs to edit.
- Remove the Authorized redirect URI for the fund's subdomain.
#### Remove the DNS in Cloudflare
- Open up the Cloudflare control panel and head to [DNS](https://dash.cloudflare.com/04a3c6a398793e6f59a1dbcadcd9ddc9/dariaservices.com/dns).
- Remove the CNAME Record for the host.
#### Remove the subdomain in heroku
- Open up the pipeline in Heroku and go to the production instance, then open up Settings, then go to Domains.
- Click the edit icon for the fund's domain and select Remove Domain.
- Remove the domain's certs, if not done automatically.
#### Remove defunct manual database backups in heroku
- Open up the pipeline in Heroku and go to the production instance, then open up Resources, then click on Heroku Postgres, then open Durability.
- Remove all Manual Backups & Data Exports.

### Remaining Fund Information

#### Sentry
Sentry errors for the fund may be retained for up to 90 days. These contain no PII.

#### Automatic database backups
Automatic database backups are retained for four days.

In the event that we need to rollback to one of these database snapshots, we will repeat the removal of all fund information.

### Removing the fund from our contact systems

- Mark the fund as defunct in our Fund Information & Point of Contact document.
- Remove the fund email(s) from our Mailing List.
- Inform the team that we've decommisioned their instance.

## All set!
