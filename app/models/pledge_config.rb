class PledgeConfig < ApplicationRecord
  acts_as_tenant :fund
end
