# Behavior around expanding/closing the clinic finder partial.

$(document).on 'turbolinks:load', ->
  $(document).on 'click', '.clinic-finder-expand', ->
    $('#clinic-finder-search-form').toggleClass('hide')
