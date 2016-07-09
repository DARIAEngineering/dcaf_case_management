# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  console.log 'document ready'

  $ps1 = $('.pledge_modal_screen1')
  $ps2 = $('.pledge_modal_screen2')
  $ps3 = $('.pledge_modal_screen3')

  $('.pledge_submit').on 'click', ->
    $ps1.hide()
    $ps2.show()
    console.log 'pledge submit'

  $('.pledge_continue').on 'click', ->
    $ps2.hide()
    $ps3.show()
    console.log 'pledge continue'

  $('.pledge_finish').on 'click', ->
    $ps3.hide()
    console.log 'pledge finish'
