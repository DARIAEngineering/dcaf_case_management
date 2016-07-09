# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  console.log 'document ready'

  $ps1 = $('.pledge_modal_screen1')
  $ps2 = $('.pledge_modal_screen2')
  $ps3 = $('.pledge_modal_screen3')

  resetScreens = ->
    $ps1.show()
    $ps2.hide()
    $ps3.hide()

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

  # TODO
  # hook up go back button
  # do resetScreens on ready/load?
  # on close, reset the screens so if modal opens again, will show screen 1 properly
    # how to do on data-dismiss modal
  # hook up submit/Finish?
