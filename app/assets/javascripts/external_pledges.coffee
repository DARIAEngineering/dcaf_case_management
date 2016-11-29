# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# $(document).ready ->
#   console.log 'document ready'
# 
#   $ps1 = $('.pledge_modal_screen1')
#   $ps2 = $('.pledge_modal_screen2')
#   $ps3 = $('.pledge_modal_screen3')
# 
#   resetScreens = ->
#     $ps1.show()
#     $ps2.hide()
#     $ps3.hide()
# 
#   $('.pledge_submit').on 'click', ->
#     $ps1.hide()
#     $ps2.show()
#     console.log 'pledge submit'
# 
#   $('.pledge_continue').on 'click', ->
#     $ps2.hide()
#     $ps3.show()
#     console.log 'pledge continue'
# 
#   $('.pledge_back_submit').on 'click', ->
#     $ps2.hide()
#     $ps1.show()
#     console.log 'pledge go back s1'
# 
#   $('.pledge_back_review').on 'click', ->
#     $ps3.hide()
#     $ps2.show()
#     console.log 'plege go back s2'
# 
#   $('.pledge_modal').on 'hide.bs.modal', ->
#     # can use hidden.bs.modal but that event fires when hiding is done
#     resetScreens()
#     console.log 'pledge closed'
# 
#   $('.pledge_finish').on 'click', ->
#     # e.preventDefault()
#     # console.log e
#     # $ps3.hide()
#     resetScreens()
#     console.log 'pledge finish'
#     $('.pledge-create-modal-form').submit()
# 
# 
#   # tried to add this so it would run on document ready, but the modal seems to
#   # not respond with it here
#   # resetScreens()
# 
#   # TODO
#   # _ do resetScreens on ready/load?
#   # _ hook up submit/Finish
# 