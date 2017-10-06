# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  # make the columns of all of the tables sortable
  sortTables()

sortTables = ->
  $('table').each (index) ->
    stupidtable = undefined
    stupidtable = $(this).stupidtable()
    stupidtable.on 'beforetablesort', (event, data) ->
      stupidtable.find('th').filter((i) ->
        i != data.column
      ).find('.arrow').html '[-]'
    stupidtable.on 'aftertablesort', (event, data) ->
      arrow = undefined
      arrow = if data.direction == $.fn.stupidtable.dir.ASC then '[&uarr;]' else '[&darr;]'
      stupidtable.find('th').eq(data.column).find('.arrow').html arrow
