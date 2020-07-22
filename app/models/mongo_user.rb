# Object representing a case manager.
# Fields are all devise settings; most of the methods relate to call list mgmt.
class MongoUser
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Userstamp::User
  include Mongoid::History::Trackable
  extend Enumerize

  store_in collection: 'users'

  track_history on: fields.keys + [:updated_by_id],
                  version_field: :version,
                  track_create: true,
                  track_update: true,
                  track_destroy: true

  after_create :send_account_created_email, if: :persisted?

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

  # Callbacks
  after_update :send_password_change_email, if: :needs_password_change_email?

  # Relationships
  has_and_belongs_to_many :patients, class_name: 'MongoPatient', inverse_of: :users

  # Fields
  # Non-devise generated
  field :name, type: String
  field :line, type: String
  field :role, default: :cm

  enumerize :role, in: [:cm, :admin, :data_volunteer], predicates: true
  field :call_order, type: Array # Manipulated by the call list controller

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
  field :failed_attempts, type: Integer, default: 0
  # field :unlock_token,    type: String
  field :locked_at,       type: Time

  # An extra hard shutoff field for when a fund wants to shut off a user acct.
  # We call this disabling in the app, but users/CMs see this as 'Lock/Unlock'.
  # We do this because Devise calls a temporary account shutoff because of too
  # many failed attempts an account lock.
  field :disabled_by_fund, type: Boolean, default: false
end
# PORTED
