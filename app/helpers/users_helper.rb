# Functions for cleaner rendering of user panels.
module UsersHelper
  def user_role_options
    [
      ['Case manager', 'cm'],
      ['Data volunteer', 'data_volunteer'],
      ['Admin', 'admin']
    ]
  end
end
