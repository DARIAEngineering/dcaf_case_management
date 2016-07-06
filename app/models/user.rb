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

  has_many :pregnancies

  has_and_belongs_to_many :pregnancies, inverse_of: :users

  # Fields
  # Non-devise generated
  field :name, type: String
  field :line, type: String
  field :role, type: String

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

  # ticket 241 recently called criteria:
  # someone has a call from the current_user
  # that is less than 8 hours old,
  # AND they would otherwise be in the call list

  def recently_called_pregnancies
    pregnancies.select { |p| recently_called?(p) }
  end

  def call_list_pregnancies
    pregnancies.reject { |p| recently_called?(p) }
  end

  def recently_called?(preg)
    preg.calls.any? { |call| call.created_by_id == id && call.recent? }
  end
end
