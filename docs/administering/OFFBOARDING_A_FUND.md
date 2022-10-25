# Offboarding a fund from our managed pipeine

These are detailed instructions to offboarding a fund from our managed `daria-services-pipeline`. It assumes that you already have access set up and permissions on the resources we use. It assumes you have the Heroku CLI configured.

Fund data ultimately belongs to the Fund. These are the steps and timeline we follow to ensuring we do not retain any information after a Fund no longer needs DARIA.

## Main steps

At a high level, we are:

  - Removing Fund-specific rows from our production database
  - Removing the fund configuration on our infrastructure
  - Removing the fund from our contact systems

### Removing Production Data for the Fund

Start by taking a snapshot of the database in heroku:
  - Open up the pipeline in Heroku and go to the production instance, then open up Resources, then click on Heroku Postgres, then open Durability
  - Create a manual snapshot

I suggest doing these console commands by connecting to the console via the Heroku CLI, as I have found the GUI console can close unexpectedly. Heroku run instances are ephemeral and will not retain a saved file from one run to the next.

run `heroku run bash`. You should stay in this instance throughout or the reference files won't be retained.

Once connected, run `rails c`

Collect all the model types and setup data checks
```ruby
Rails.application.eager_load!
all_models = ActiveRecord::Base.descendants
models_fund_agnostic = [ Fund, ActiveRecord::SessionStore::Session, PaperTrail::Version, PaperTrailVersion]
models_fund_dependent = [ PledgeConfig,    PracticalSupport, Patient, Note, Line, Fulfillment,   ExternalPledge, Event, Config, Clinic, CallListEntry, Call, ArchivedPatient, User]

# Prove to yourself all models are accounted for
all_models - models_fund_dependent - models_fund_agnostic
=> [ApplicationRecord(abstract)]

# Catch all the model counts for each fund to eyeball after
starting_counts = {}
Fund.all.sort.each do |fund|
  fund_counts = {}
  models_fund_dependent.each do |model|
    fund_counts[model.to_s] = model.where(fund_id: fund.id).size
  end
  starting_counts[fund.name] = fund_counts
end
counts = {}
models_fund_agnostic.each do |model|
  counts[model.to_s] = model.all.size
end
starting_counts['fund_agnostic'] = counts

#save starting counts to file
$stdout = File.new('initial_state.out', 'w')
$stdout.sync = true
starting_counts
$stdout = STDOUT
```

Remove tenant-specific rows.
```ruby
#Lock our tenant!
Fund.all.pluck(:name,:id)
defunct_fund_id = #the fund you are removing
ActsAsTenant.current_tenant = Fund.find(defunct_fund_id)

Patient.destroy_all
ArchivedPatient.destroy_all
[Note, Fulfillment, ExternalPledge, PracticalSupport, Call].each { |model| model.destroy_all }
[Clinic, Line, Config].each { |model| model.destroy_all }
User.destroy_all

ActsAsTenant.current_tenant = nil

# Check the new overall state
post_deletion_counts = {}
Fund.all.sort.each do |fund|
  fund_counts = {}
  models_fund_dependent.each do |model|
    fund_counts[model.to_s.to_sym] = model.where(fund_id: fund.id).size
  end
  post_deletion_counts[fund.name] = fund_counts
end
counts = {}
models_fund_agnostic.each do |model|
  counts[model.to_s.to_sym] = model.all.size
end
post_deletion_counts['fund_agnostic'] = counts

#save final counts to file
$stdout = File.new('post_deletion.out', 'w')
$stdout.sync = true
post_deletion_counts
$stdout = STDOUT

exit
```

diff those files!

  - The other fund objects should not have changed significantly
  - There should be a jump in PaperTrails corresponding to the total object count we've deleted

`diff -y initial_count.out post_deletion.out`

IF AND ONLY IF everything looks good, let's continue.

Remove the PaperTrails associated with the fund, and finally the Fund row itself.

run `rails c` again

```ruby
# delete the PaperTrails
#  🚨 ⚠️ 🚨 ⚠️ 🚨 This is the point of no return.
# Once these are deleted, we cannot restore the funds information from this database
Fund.all.pluck(:name,:id)
defunct_fund_id = #the fund you are removing
defunct_fund_versions = PaperTrail::Version.where_object(fund_id: defunct_fund_id)
defunct_fund_versions.destroy_all
defunct_fund_changes = PaperTrailVersion.where_object_changes(fund_id: defunct_fund_id)
defunct_fund_changes.destroy_all

# Finally, destroy the fund row
fund = Fund.find(defunct_fund_id)
fund.destroy

exit
```

Copy any exerpts from the output files you want for later reference and `exit` the bash

### Removing the Subdomain Configuration

#### Remove Google OAuth
  - Go to our [GCP project](https://console.cloud.google.com/apis/credentials?project=daria-services-multitenant)
  - Open up DARIA Services Production from the list of Client IDs to edit
  - Remove the Authorized redirect URI for the fund's subdomain
#### Remove the DNS in Namecheap
  - Open up the Namecheap control panel and head to Advanced DNS.
  - Remove the CNAME Record for the host
#### Remove the subdomain in heroku
  - Open up the pipeline in Heroku and go to the production instance, then open up Settings, then go to Domains.
  - Click the edit icon for the fund's domain and select Remove Domain
  - Remove the domain's certs, if not done automatically
#### Remove defunct manual database backups in heroku
  - Open up the pipeline in Heroku and go to the production instance, then open up Resources, then click on Heroku Postgres, then open Durability
  - Remove all Manual Backups & Data Exports

### Remaining Fund Information

#### Sentry
Sentry errors for the fund, containing no PII, may be retained for up to 90 days.

#### Database backups
Automatic database backups are retained for four days.

In the event that we need to rollback the database we will repeat the removal of all fund information.

### Removing the fund from our contact systems

  - Remove the fund from our Fund Information & Point of Contact document
  - Remove the fund email(s) from our Mailing List
  - Inform the team that we've decommisioned their instance

## All set!
