namespace :user do
  desc "update role field production data"
  task update_role: :environment do
    User.all.each do |user|
      enum_role = check_role(user.role)
      user.update(role: enum_role)
    end

    puts 'User role updated'
  end

private
  def check_role(role)
    case role
    when 'admin'
      1
    else
      0
    end
  end
end
