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
    if user.disabled_by_fund?
      'Locked by admin'
    elsif user.access_locked?
      'Temporarily locked'
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

  def disabled_toggle_button(user)
    verb = user.disabled_by_fund? ? 'Unlock' : 'Lock'
    link_to "#{verb} account",
            toggle_disabled_path(user),
            method: :post,
            class: 'btn btn-warning'
  end
end
