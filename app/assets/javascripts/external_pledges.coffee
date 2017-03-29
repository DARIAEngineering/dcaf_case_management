# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  # use event that works with rails turbolinks
  $(document).on 'ready turbolinks:load', ->
    # select all elements with id ending with "modal"
    $('[id$=modal]').modalSteps()
