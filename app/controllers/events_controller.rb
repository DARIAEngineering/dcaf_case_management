# For render
class EventsController < ApplicationController
  include LinesHelper

  def index
    puts current_line
    @events = Event.where(line: current_line)
                   .order_by(created_at: :desc)

    render partial: 'events/events'
    # respond_to { |format| format.js }
  end
end
