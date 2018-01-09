# Functions for cleaner rendering of user panels.
module UsersHelper
  def user_role_options
    [
      ['Case manager', 'cm'],
      ['Data volunteer', 'data_volunteer'],
      ['Admin', 'admin']
    ]
  end

  def user_lock_status(user)
    if user.access_locked?
      'Locked'
    else
      'Active'
    end
  end

  def role_toggle_button(user, new_role)
    link_to "Change #{user.name}'s role to #{new_role.titleize}",
            public_send("change_role_to_#{new_role}_path", user),
            method: :patch,
            class: 'btn btn-warning'
  end
end
