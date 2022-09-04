class ErrorsController < ApplicationController
  def errors_controller?
    true
  end

  def error_404; end

  def error_422; end

  def error_500; end
end
