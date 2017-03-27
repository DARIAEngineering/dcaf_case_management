# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready = ->
  $(document).on 'show.bs.collapse', '.collapsible-clinic-details', (event) ->
    $(event.target).siblings('.clinic-detail-toggle').text('Fewer Details')

  $(document).on 'hide.bs.collapse', '.collapsible-clinic-details', (event) ->
    $(event.target).siblings('.clinic-detail-toggle').text('More Details')

$(document).on 'ready page:load', ready