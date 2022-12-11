class Fund < ApplicationRecord
  # TODO make papertrailable

  # Relations
  has_many :lines
  has_one :pledge_config

  # Validations
  validates :name,
            :subdomain,
            :domain,
            :full_name,
            :site_domain,
            :phone,
            presence: true
  validates :name, :subdomain, uniqueness: true

  def delete_patient_related_data
    [ Patient,
      ArchivedPatient,
      Note,
      Fulfillment,
      ExternalPledge,
      PracticalSupport,
      Call ].each do |model|
        model.destroy_all
      end
  end

  def delete_administrative_data
    [ Clinic, Config, Line, User ].each do |model|
      model.destroy_all
    end
  end
end
