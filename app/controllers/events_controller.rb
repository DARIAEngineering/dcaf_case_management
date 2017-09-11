# For render
class EventsController < ApplicationController
  include LinesHelper

  def index
    @events = Event.where(line: current_line)
                   .order_by(created_at: :desc)

    render partial: 'events/events'
  end
end
