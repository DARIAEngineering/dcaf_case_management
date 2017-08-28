# For render
class EventsController < ApplicationController
  def index
    @events = Event.all.order_by(created_at: :desc)
                   # .where(line: current_user.line)
                   
                   # .includes(:user, :patient)

    render partial: 'events/events'
    # respond_to { |format| format.js }
  end
end
