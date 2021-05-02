# Methods relating to calls or contacts
module Callable
  extend ActiveSupport::Concern

  def recent_calls
    calls.includes(:versions).order('created_at DESC').limit(10)
  end

  def old_calls
    calls.includes(:versions).order('created_at DESC').offset(10)
  end

  def last_call
    calls.order(created_at: :desc).first
  end
end
