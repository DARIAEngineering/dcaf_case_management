# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery -> 

    $('#call_list td').each (index, element) ->
      $(element).css('width', $(element).width())

    $('#call_list').sortable(
      placeholder: "ui-state-highlight"
      axis: 'y'
      items: '.pregnancy-data'
      handle: '.handle'
    );

