# Object representing a case manager.
# Fields are all devise settings; most of the methods relate to call list mgmt.

# TODO ENUMS
class User < ApplicationRecord
  has_paper_trail

  # Concerns
  include UserSearchable
  include CallListable

  TIME_BEFORE_DISABLED_BY_FUND = 9.months

  # Devise modules
  devise  :database_authenticatable,
          :registerable,
          :recoverable,
          :trackable,
          :validatable,
          :lockable,
          :timeoutable,
          :omniauthable, omniauth_providers: [:google_oauth2]
  # :rememberable
  # :confirmable

  # Relations
  has_many :call_lists
  has_many :patients, through: :call_lists

  # Validations
  # email presence validated through Devise
  validates :name, presence: true
  validates :role, presence: true
  validate :secure_password

  enum role: { cm: 0, admin: 1, data_volunteer: 2 }

  # Methods
  def secure_password
    return true if password.nil?
    pc = verify_password_complexity
    if pc == false
      errors.add :password, 'Password must include at least one lowercase ' \
                            'letter, one uppercase letter, and one digit. ' \
                            "Forbidden words include #{FUND} and password."
    end
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.find_by! email: data['email']

    user
  end

  def toggle_disabled_by_fund
    # Since toggle skips callbacks...
    update disabled_by_fund: !disabled_by_fund
  end

  def self.disable_inactive_users
    cutoff_date = Time.zone.now - TIME_BEFORE_DISABLED_BY_FUND
    inactive_has_logged_in = where(:role.nin => [:admin],
                                   :current_sign_in_at.lt => cutoff_date)
    inactive_no_logins = where(:role.nin => [:admin],
                               :current_sign_in_at => nil,
                               :created_at.lt => cutoff_date)
    [inactive_no_logins, inactive_has_logged_in].each do |set|
      set.update disabled_by_fund: true
    end
  end

  def admin?
    role == 'admin'
  end

  def allowed_data_access?
    admin? || data_volunteer?
  end

  private

  def verify_password_complexity
    return false unless password.length >= 8 # length at least 8
    return false if (password =~ /[a-z]/).nil? # at least one lowercase
    return false if (password =~ /[A-Z]/).nil? # at least one uppercase
    return false if (password =~ /[0-9]/).nil? # at least one digit
    # Make sure no bad words are in there
    return false unless password.downcase[/(password|#{FUND})/].nil?
    true
  end

  def needs_password_change_email?
    encrypted_password_changed? && persisted?
  end

  def send_password_change_email
    # @user = User.find(id)
    UserMailer.password_changed(id).deliver_now
  end

  def send_account_created_email
    UserMailer.account_created(id).deliver_now
  end
end
