# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# File dynamically loads in all patient data on click.

jQuery ->
  $(document).on "click", ".call_button", ->

    $('.new-call').attr('id', $('.call_button').data('primaryphone'))
    el = $('.modal-title')

    el.html("")
    el.append('Call <b>' + $('.call_button').data('patientname') + '</b> now:</h4>')
    el.append('<br>')
    el.append($('.call_button').data('othercontact'))
    el.append('<h4 class="calls-phone">' + $('.call_button').data('primaryphone') + '</h4>')
    el.append($('.call_button').data('reachedpatientlink'))
    el.append($('.call_button').data('voicemaillink'))
    el.append($('.call_button').data('couldntreachlink'))
    el.append($('.call_button').data('notetext'))
    $('.modal').modal 'toggle'
