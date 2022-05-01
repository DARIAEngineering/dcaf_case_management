class PledgeConfig < ApplicationRecord
  acts_as_tenant :fund

  validates_presence_of :contact_email,
                        :logo_url,
                        :address1,
                        :address2
                        # :generator
end
