# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $(document).on 'ready page:load', ->
    # make the columns of all of the tables sortable
    autosortable_tables = [ '#call_list table', '#completed_calls table', '#urgent_patients table', '#user-list table']
    autosortable_tables.forEach ( table ) ->
        stupidtable = $( table ).stupidtable()

        # when a column is clicked, make sure to reset all of the other columns back to [-]
        stupidtable.on 'beforetablesort', ( event, data ) ->
            stupidtable.find( 'th' ).filter( ( i ) -> return i isnt data.column ).find( '.arrow' ).html( '[-]' )

        # when a column is clicked, show an up or down arrow appropriately
        stupidtable.on 'aftertablesort', ( event, data ) ->
            arrow = if data.direction is $.fn.stupidtable.dir.ASC then '[&uarr;]' else '[&darr;]'
            stupidtable.find( 'th' ).eq( data.column ).find( '.arrow' ).html( arrow )
