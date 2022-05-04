# Methods relating to notes or parsing notes
module Notetakeable
  extend ActiveSupport::Concern

  def most_recent_note
    notes.order('created_at DESC').limit(1).first
  end
end
