# Offboarding a fund from our managed pipeine

These are detailed instructions to offboarding a fund from our managed `daria-services-pipeline`. It assumes that you already have access set up and permissions on the resources we use.

Fund data ultimately belongs to the Fund. These are the steps and timeline we follow to ensuring we do not retain any information after a Fund no longer needs DARIA.

## Main steps

At a high level, we are:

  - Removing Fund-specific rows from our production database
  - Removing the fund configuration on our infrastructure
  - Removing the fund from our contact systems

### Removing Production Data for the Fund

Connect to the production console and run this process

Collect all the model types and setup data checks
```ruby
Rails.application.eager_load!
all_models = ActiveRecord::Base.descendants
models_fund_agnostic = [ Fund ActiveRecord::SessionStore::Session, PaperTrail::Version, PaperTrailVersion]
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
fund_counts = {}
models_fund_agnostic.each do |model|
  fund_counts[model.to_s] = model.all.size
end
starting_counts['fund_agnostic'] = fund_counts

#save starting counts to file
$stdout = File.new('initail_state.out', 'w')
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

# exit and restart to console to drop the ActsAsTenant.current_tenant
exit
```

Check everything looks right before destroying the PaperTrail versions
```ruby
# Check the new overall state
models_fund_dependent = [ PledgeConfig, PracticalSupport, Patient, Note, Line, Fulfillment, ExternalPledge, Event, Config, Clinic, CallListEntry, Call, ArchivedPatient, User]
models_fund_agnostic = [ Fund, ActiveRecord::SessionStore::Session, PaperTrail::Version, PaperTrailVersion] 

post_deletion_counts = {}             
Fund.all.sort.each do |fund|          
  fund_counts = {}                    
  models_fund_dependent.each do |model|
    fund_counts[model.to_s.to_sym] = model.where(fund_id: fund.id).size
  end                                                                  
  post_deletion_counts[fund.name] = fund_counts                        
end                                                                    
fund_counts = {}                                                       
models_fund_agnostic.each do |model|                                   
  fund_counts[model.to_s.to_sym] = model.all.size                      
end                                                                    
post_deletion_counts['fund_agnostic'] = fund_counts                    
                                                                       
#save starting counts to file                                          
$stdout = File.new('post_deletion.out', 'w')                           
$stdout.sync = true                                                    
post_deletion_counts                                                   
$stdout = STDOUT

# diff those files!
# the other fund objects should not have changed significantly
# There should be a jump in PaperTrails corresponding to the total object count we've deleted
# IF AND ONLY IF everything looks good, let's continue.
```

Once you are satisfied, remove the PaperTrails associated with the fund, and finally the Fund row itself.

```ruby
# delete the PaperTrails
#  🚨 ⚠️ 🚨 ⚠️ 🚨 This is the point of no return.
# Once these are deleted, we cannot restore the funds information from this database
defunct_fund_versions = PaperTrail::Version.where_object(fund_id: id)
defunct_fund_versions.destroy_all
defunct_fund_changes = PaperTrailVersion.where_object_changes(fund_id: id)
defunct_fund_changes.destroy_all

# Finally, destroy the fund row
defunct_fund_id = #the fund you're removing!
fund = Fund.find(defunct_fund_id)
fund.destroy

exit
```

### Removing the Subdomain Configuration

#### Remove Google OAuth
  -  Go to our [GCP project](https://console.cloud.google.com/apis/credentials?project=daria-services-multitenant)
  -  Open up DARIA Services Production from the list of Client IDs to edit
  -  Remove the Authorized redirect URI for the fund's subdomain
#### Remove the DNS in Namecheap
  -  Open up the Namecheap control panel and head to Advanced DNS.
  -  Remove the CNAME Record for the host 
#### Remove the subdomain in heroku
  -  Open up the pipeline in Heroku and go to the production instance, then open up Settings, then go to Domains.
  -  Click the edit icon for the fund's domain and select Remove Domain
  - Remove the domain's certs, if not done automatically
#### Remove defunct manual database backups in heroku
  -  Open up the pipeline in Heroku and go to the production instance, then open up Resources, then click on Heroku Postgres, then open Durability
  - Remove any Manual Backups & Data Exports

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
