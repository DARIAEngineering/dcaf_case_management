ready = ->
  $(document).on "click", "#select-all-users", ->
      if $('#select-all-users').prop 'checked'
        $('tbody :checkbox').prop 'checked', true
      else
        $('tbody :checkbox').prop 'checked', false


$(document).on 'ready page:load', ready
