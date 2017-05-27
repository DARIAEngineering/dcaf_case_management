module UsersHelper
  def user_role_options
    [
      ['Case manager', 'cm'],
      ['Data volunteer', 'data_volunteer'],
      ['Admin', 'admin']
    ]
  end

  def status user
    if user.access_locked?
      'Locked'
    else
      'Active'
    end
  end
end
