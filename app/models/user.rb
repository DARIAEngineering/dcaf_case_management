class User
  include Mongoid::Document
  include Mongoid::Userstamp::User

  # Devise modules
  devise  :database_authenticatable,
          :registerable,
          :recoverable,
          :trackable,
          :validatable,
          :lockable,
          :timeoutable
  # :rememberable
  # :confirmable

  # Relationships
  has_and_belongs_to_many :pregnancies, inverse_of: :users

  # Fields
  # Non-devise generated
  field :name, type: String
  field :line, type: String
  field :role, type: String
  field :call_order, type: Array

  ## Database authenticatable
  field :email,              type: String, default: ''
  field :encrypted_password, type: String, default: ''

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  # field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  field :locked_at,       type: Time

  # Validations
  validates :email, :name, presence: true
  validate :secure_password

  def secure_password
    return true if password.nil?
    pc = verify_password_complexity
    if pc == false
      errors.add :password, 'Password must include at least one lowercase ' \
                            'letter, one uppercase letter, and one digit. ' \
                            'Forbidden words include DCAF and password.'
    end
  end

  # ticket 241 recently called criteria:
  # someone has a call from the current_user
  # that is less than 8 hours old,
  # AND they would otherwise be in the call list

  def recently_called_pregnancies
    pregnancies.select { |p| recently_called_by_user?(p) }
  end

  def call_list_pregnancies
    pregnancies.reject { |p| recently_called_by_user?(p) }
  end

  def add_pregnancy(pregnancy)
    pregnancies << pregnancy
    reload
  end

  def remove_pregnancy(pregnancy)
    pregnancies.delete pregnancy
    reload
  end

  def reorder_call_list(order)
    update call_order: order
    save
    reload
  end

  def ordered_pregnancies
    return call_list_pregnancies unless call_order
    ordered_pregnancies = call_list_pregnancies.sort_by do |pregnancy|
      call_order.index(pregnancy.id.to_s) || 0
    end
    ordered_pregnancies
  end

  def clear_call_list
    pregnancies.each do |p|
      pregnancies.delete(p) if recently_reached_by_user?(p)
    end
  end

  private

  def verify_password_complexity
    # Enforce length of at least ten
    return false unless password.length >= 8
    # we want at least one lower case
    return false if (password =~ /[a-z]/).nil?
    # We want at least one uppercase
    return false if (password =~ /[A-Z]/).nil?
    # We want at least one digit
    return false if (password =~ /[0-9]/).nil?
    # Make sure the word password isn't in there
    return false if !(password.downcase[/(password|dcaf)/]).nil?
  end

  def recently_reached_by_user?(preg)
    preg.calls.any? { |call| call.created_by_id == id && call.recent? && call.reached? }
  end

  def recently_called_by_user?(preg)
    preg.calls.any? { |call| call.created_by_id == id && call.recent? }
  end
end
