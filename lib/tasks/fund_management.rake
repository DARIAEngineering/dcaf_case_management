namespace :fund_management do
  desc "Remove a fund and all its related objects"
  task :delete_fund, [:fund_name] => [:environment] do |task, args|
    # query our fund
    fund_name = args.fund_name
    defunct_fund = Fund.find_by(name: fund_name)
    if defunct_fund.nil?
      raise 'Fund not found. Please doublecheck the name!'
    end
    puts "Removing the fund #{fund_name} and all its subobjects"
    puts
    puts "Initial model counts by fund"
    print_counts

    ActsAsTenant.with_tenant(defunct_fund) do
      print "Deleting Patient & Patient-related data"
      defunct_fund.delete_patient_related_data
      puts " ✅"

      print "Deleting Fund administrative data"
      defunct_fund.delete_administrative_data
      puts " ✅"
    end

    # delete the versions & print count deleted
    print "Deleting fund PaperTrails"
    PaperTrail::Version.where_object(fund_id: defunct_fund.id).destroy_all
    PaperTrailVersion.where_object_changes(fund_id: defunct_fund.id).destroy_all
    puts " ✅"
    puts

    puts "Final model counts by fund"
    print_counts

    print "Deleting #{fund_name} from the Fund table"
    # print the final state
    defunct_fund.destroy
    puts " ✅"
  end

  private
  def print_counts
    models_fund_agnostic = [ Fund, ActiveRecord::SessionStore::Session, PaperTrail::Version, PaperTrailVersion]
    models_fund_dependent = [ ArchivedPatient, Patient, Fulfillment, PledgeConfig, ExternalPledge, PracticalSupport, Note, Call, Event, CallListEntry, Clinic, Line, Config, User ]
    starting_counts = {}
    Fund.all.sort.each do |fund|
      fund_counts = {}
      models_fund_dependent.each do |model|
        fund_counts[model.to_s] = model.where(fund_id: fund.id).size
      end
      starting_counts[fund.name] = fund_counts
    end
    pp starting_counts

    counts = {}
    models_fund_agnostic.each do |model|
      counts[model.to_s] = model.all.size
    end
    puts "Fund agnostic model counts"
    pp counts
    puts
  end
end
