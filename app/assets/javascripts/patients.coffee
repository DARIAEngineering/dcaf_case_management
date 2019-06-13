# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

markFulfilledWhenFieldsChecked = ->
  pledge_fields = [
    '#patient_fulfillment_fund_payout'
    '#patient_fulfillment_check_number'
    '#patient_fulfillment_gestation_at_procedure'
    '#patient_fulfillment_date_of_check'
    '#patient_fulfillment_procedure_date'
  ]

  i = 0
  empty = true
  el = $('#patient_fulfillment_fulfilled')

  while i < pledge_fields.length
    if $(pledge_fields[i]).val().length > 0
      empty = false
      if el.prop 'checked'
        break;
      else
        el.prop 'checked', true
      i++
    else
      i++
  if empty == true
    el.prop 'checked', false

$(document).on 'turbolinks:load', ->
  $(document).on "click", "#toggle-call-log", ->
    $(".old-calls").toggleClass("hidden")
    html = if $(".old-calls").hasClass("hidden") then "View all calls" else "Limit list"
    $("#toggle-call-log").html(html)

  $(document).on "change", ".edit_patient", ->
    $(this).submit()

  $(document).on "change", "#pledge_fulfillment_form", ->
    markFulfilledWhenFieldsChecked()
    $(this).submit()

  $(document).on "change", ".edit_external_pledge", ->
    $(this).submit()

  $(document).on "submit", "#generate-pledge-form form", ->
    if($("#case_manager_name").val())
      true
    else
      $("#generate-pledge-form .alert").show()
      false
