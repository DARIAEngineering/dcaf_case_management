# Object representing a case manager.
# Fields are all devise settings; most of the methods relate to call list mgmt.
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Userstamp::User
  include Mongoid::History::Trackable
  extend Enumerize

  include UserSearchable
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
          :omniauthable,
          :omniauth_providers => [:google_oauth2]
  # :rememberable
  # :confirmable

  # Callbacks
  after_update :send_password_change_email, if: :needs_password_change_email?

  # Relationships
  has_and_belongs_to_many :patients, inverse_of: :users

  # Fields
  # Non-devise generated
  field :name, type: String
  field :line, type: String
  field :role

  enumerize :role, in: [:cm, :admin, :data_volunteer], predicates: true
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
  field :failed_attempts, type: Integer, default: 0
  # field :unlock_token,    type: String
  field :locked_at,       type: Time

  # Validations
  # email presence validated through Devise
  validates :name, presence: true
  validate :secure_password

  TIME_BEFORE_INACTIVE = 2.weeks

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
    user = User.find_by email: data['email']

    user
  end

  # ticket 241 recently called criteria:
  # someone has a call from the current_user
  # that is less than 8 hours old,
  # AND they would otherwise be in the call list
  # (e.g. assigned to current line and in user.patients)

  def recently_called_patients(lines = LINES)
    patients.in(line: lines)
            .select { |patient| recently_called_by_user? patient }
  end

  def call_list_patients(lines = LINES)
    patients.in(line: lines)
            .reject { |patient| recently_called_by_user? patient }
  end

  def add_patient(patient)
    patients << patient
    if call_order
      reorder_call_list(call_order.unshift(patient.id.to_s))
    else
      reorder_call_list([patient.id.to_s])
    end
    reload
  end

  def remove_patient(patient)
    patients.delete patient
    reload
  end

  def reorder_call_list(order)
    update call_order: order
    save
    reload
  end

  def ordered_patients(lines = LINES)
    return call_list_patients(lines) unless call_order
    ordered_patients = call_list_patients(lines).sort_by do |patient|
      call_order.index(patient.id.to_s) || call_order.length
    end
    ordered_patients
  end

  def clean_call_list_between_shifts
    if last_sign_in_at.present? &&
       last_sign_in_at < Time.zone.now - TIME_BEFORE_INACTIVE
      patients.clear
    else
      patients.each do |p|
        # TODO: reexamine this behavior in awhile
        patients.delete(p) if recently_reached_by_user?(p)
      end
    end
  end

  def clear_call_list
    patients.clear
    save
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

  def recently_reached_by_user?(patient)
    patient.calls.any? do |call|
      call.created_by_id == id && call.recent? && call.reached?
    end
  end

  def recently_called_by_user?(patient)
    patient.calls.any? { |call| call.created_by_id == id && call.recent? }
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
