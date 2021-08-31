# Object representing a fund's intake path.
class Line < ApplicationRecord
  acts_as_tenant :fund
end
