# Object representing a case manager.
# Fields are all devise settings; most of the methods relate to call list mgmt.
class User < ApplicationRecord
  # Concerns
  include HistoryTrackable
  include UserSearchable
  include CallListable

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

  enum role: {
    cm: 0,
    data_volunteer: 1,
    admin: 2
  }

  # Callbacks
  after_update :send_password_change_email, if: :needs_password_change_email?
  after_create :send_account_created_email, if: :persisted?

  # Relationships
  has_many :call_list_entries

  # Validations
  # email presence validated through Devise
  validates :name, :role, presence: true
  validate :secure_password

  TIME_BEFORE_DISABLED_BY_FUND = 9.months

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

    inactive_has_logged_in = where('current_sign_in_at < ?', cutoff_date)
                              .where.not(role: [:admin])
    inactive_no_logins = where('created_at < ?', cutoff_date)
                          .where(current_sign_in_at: nil)
                          .where.not(role: [:admin]) 

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
