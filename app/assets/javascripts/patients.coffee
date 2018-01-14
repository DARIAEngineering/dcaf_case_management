# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
updateBalance = ->
  if $("#patient_procedure_cost").val()
    $(".outstanding-balance-ctn").removeClass('hidden')
    $("#outstanding-balance").text('$' + calculateRemainder())
  else
    $(".outstanding-balance-ctn").addClass('hidden')

calculateRemainder = ->
  total = valueToNumber $("#patient_procedure_cost").val()
  contributions = valueToNumber($("#patient_patient_contribution").val()) +
                  valueToNumber($("#patient_naf_pledge").val()) +
                  valueToNumber($("#patient_fund_pledge").val()) +
                  valueToNumber($(".external_pledge_amount").toArray().reduce (acc, next) ->
                    acc + valueToNumber($(next).val())
                  , 0)
  total - contributions

valueToNumber = (val) ->
  +val || 0

markFulfilledWhenFieldsChecked = ->
  pledge_fields = [
    '#patient_fulfillment_procedure_cost'
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

  $(document).on "change", "#abortion-information-form input, #external_pledges input", ->
    updateBalance()

  $(document).on "submit", "#generate-pledge-form form", ->
    if($("#case_manager_name").val())
      true
    else
      $("#generate-pledge-form .alert").show()
      false

  $(document).on "click", "#create-external-pledge", ->
    # timeout to handle mongo updating and rails appending new field
    setTimeout(updateBalance, 500)

  if $("#patient_procedure_cost").val()
    updateBalance()

  # put a help icon next to form field labels that have the "tooltip-header" class
  # the text that shows up in the tooltip is from the label's corresponding form field's "data-tooltip-text" attribute
  $( '.tooltip-header' ).append( ' <span class="tooltip-header-help">(?)</span>' )
  $( '.tooltip-header' ).parent( '.form-group' ).find( '.form-control' ).each ->
    $(@).parents( '.form-group' ).find( '.tooltip-header-help' ).tooltip( {
      html: true,
      placement: 'top',
      title: $(@).data( 'tooltip-text' )
    } )
