# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# http://stackoverflow.com/questions/1307705/jquery-ui-sortable-with-table-and-tr-width/1372954#1372954
# http://benw.me/posts/sortable-bootstrap-tables/

jQuery -> 

    $('#call_list td').each (index, element) ->
      $(element).css('width', $(element).width())

    $('#call_list').sortable(
      placeholder: "ui-state-highlight"
      axis: 'y'
      items: '.pregnancy-data'
      cursor: 'move'
      sort: (e, ui) ->
        ui.item.addClass('active-item-shadow')
      stop: (e, ui) ->
        ui.item.removeClass('active-item-shadow')
        # highlight the row on drop to indicate an update
        ui.item.children('td').effect('highlight', {color:'#ece0ff'}, 500)
      update: (e, ui) ->
        item_id = ui.item[0].id
        parent = $('#'+item_id).parent()
        children = parent.children()
        order = []
        for child, value of children
          if value.id? then order.push(value.id)
        console.log(order)

        $.ajax(
          type: 'PATCH'
          url: '/users/reorder_call_list'
          dataType: 'json'
          data: { order }
        )
    )

    # make the columns of all of the tables sortable
    autosortable_tables = [ '#call_list table', '#completed_calls table', '#urgent_patients table' ]
    autosortable_tables.forEach ( table ) ->
        stupidtable = $( table ).stupidtable()

        # when a column is clicked, make sure to reset all of the other columns back to [-]
        stupidtable.on 'beforetablesort', ( event, data ) ->
            stupidtable.find( 'th' ).filter( ( i ) -> return i isnt data.column ).find( '.arrow' ).html( '[-]' )

        # when a column is clicked, show an up or down arrow appropriately
        stupidtable.on 'aftertablesort', ( event, data ) ->
            arrow = if data.direction is $.fn.stupidtable.dir.ASC then '[&uarr;]' else '[&darr;]'
            stupidtable.find( 'th' ).eq( data.column ).find( '.arrow' ).html( arrow )
