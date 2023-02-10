# frozen_string_literal: true

# An authentication factor used for multi factor authentication.
class AuthFactor < ApplicationRecord
  include PaperTrailable

  cattr_accessor :form_steps do
    [:registration, :verification, :confirmation]
  end
  attr_accessor :current_form_step

  before_validation :clean_fields

  belongs_to :user

  CHANNELS = [
    SMS = 'sms'
  ].freeze

  CHANNELS.each do |channel|
    scope channel, -> { where(channel: channel) }
  end

  validates :channel, presence: true, inclusion: { in: CHANNELS }

  with_options if: -> { past_step?(:registration) } do
    validates :name, presence: true, uniqueness: { scope: :user_id }, length: { maximum: 30 }
    validates :phone, presence: true, format: /\A\d{10}\z/, length: { is: 10 }
  end

  private

  def clean_fields
    phone&.gsub!(/\D/, '')
    name&.strip!
  end

  # Returns true if the current step is on or past the input step.
  def past_step?(step)
    # If the form is complete, there will be no current step.
    return true if current_form_step.nil?

    return true if form_steps.index(current_form_step) >= form_steps.index(step)
  end
end
