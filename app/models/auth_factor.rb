# frozen_string_literal: true

# An authentication factor used for two factor authentication.
class AuthFactor < ApplicationRecord
  include PaperTrailable

  cattr_accessor :form_steps do
    [:registration, :verification, :confirmation]
  end
  attr_accessor :form_step

  before_validation :clean_fields

  belongs_to :user

  CHANNELS = [
    SMS = 'sms'
  ].freeze

  CHANNELS.each do |channel|
    scope channel, -> { where(channel: channel) }
  end

  validates :channel, presence: true, inclusion: { in: CHANNELS }

  with_options if: -> { required_for_step?(:registration) } do
    validates :name, presence: true, uniqueness: { scope: :user_id }, length: { maximum: 30 }
    validates :phone, presence: true, format: /\A\d{10}\z/, length: { is: 10 }
  end

  private

  def clean_fields
    phone&.gsub!(/\D/, '')
    name&.strip!
  end

  def required_for_step?(step)
    # All fields are required if no form step is present
    return true if form_step.nil?

    # All fields from previous steps are required if the
    # step parameter appears before or we are on the current step
    return true if form_steps.index(step) <= form_steps.index(form_step)
  end
end
