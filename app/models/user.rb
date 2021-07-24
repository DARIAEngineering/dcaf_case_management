# Object representing a case manager.
# Fields are all devise settings; most of the methods relate to call list mgmt.
class User < ApplicationRecord
  acts_as_tenant :fund

  # Concerns
  include PaperTrailable
  include CallListable

  # Devise modules
  devise  :database_authenticatable,
          :registerable,
          :recoverable,
          :trackable,
          # :validatable,
          :lockable,
          :timeoutable,
          :omniauthable, omniauth_providers: [:google_oauth2]
  # :rememberable
  # :confirmable

  # Enums
  enum role: {
    cm: 0,
    data_volunteer: 1,
    admin: 2
  }

  # Constants
  MIN_PASSWORD_LENGTH = 8
  TIME_BEFORE_DISABLED_BY_FUND = 9.months
  SEARCH_LIMIT = 15

  # Callbacks
  after_update :send_password_change_email, if: :needs_password_change_email?
  after_create :send_account_created_email, if: :persisted?

  # Relationships
  has_many :call_list_entries

  # Validations
  validates_uniqueness_to_tenant :email, allow_blank: true, if: :email_changed?

  # email presence validated through Devise
  validates :name, :role, :email, presence: true
  validates_format_of :email, with: Devise::email_regexp
  validate :secure_password, if: :updating_password?
  # i18n-tasks-use t('errors.messages.password.password_strength')
  validates :password, password_strength: {use_dictionary: true}, if: :updating_password?

  # To accommodate tenancy, we use our own devise validations
  # See https://github.com/heartcombo/devise/blob/master/lib/devise/models/validatable.rb
  validates_format_of     :email, with: Devise::email_regexp, allow_blank: true, if: :email_changed?
  validates_presence_of     :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of       :password, within: MIN_PASSWORD_LENGTH..100, allow_blank: true

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
  # end boilerplate from validatable

  def updating_password?
    return !password.nil?
  end

  def secure_password
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

  def allowed_data_access?
    admin? || data_volunteer?
  end

  def self.search(name_or_email_str)
    return if name_or_email_str.blank?
    wildcard = "%#{name_or_email_str}%"
    User.where('name ilike ?', wildcard)
        .or(User.where('email ilike ?', wildcard))
        .order(updated_at: :desc)
        .limit(SEARCH_LIMIT)
  end

  private

  def verify_password_complexity
    return false unless password.length >= MIN_PASSWORD_LENGTH # length at least 8
    return false if (password =~ /[a-z]/).nil? # at least one lowercase
    return false if (password =~ /[A-Z]/).nil? # at least one uppercase
    return false if (password =~ /[0-9]/).nil? # at least one digit
    # Make sure no bad words are in there
    fund = FUND.downcase
    return false unless password.downcase[/(password|#{fund})/].nil?
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
