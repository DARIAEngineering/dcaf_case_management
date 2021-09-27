class AddFundToModels < ActiveRecord::Migration[6.1]
  def change
    %w(
      archived_patients
      calls
      call_list_entries
      clinics
      configs
      events
      external_pledges
      fulfillments
      notes
      patients
      practical_supports
      users
    ).each do |model|
      add_reference model, :fund, foreign_key: true
    end
  end
end