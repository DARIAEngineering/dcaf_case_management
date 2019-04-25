# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'turbolinks:load', ->
  $(document).on "click", "#toggle-call-log", ->
    $(".old-calls").toggleClass("hidden")
    html = if $(".old-calls").hasClass("hidden") then "View all calls" else "Limit list"
    $("#toggle-call-log").html(html)

  $(document).on "change", ".edit_patient", ->
    $(this).submit()

  $(document).on "change", ".edit_external_pledge", ->
    $(this).submit()

  balanceFields = '#abortion-information-form input,
  #external_pledges input,
  #patient_procedure_cost,
  #patient_patient_contribution,
  #patient_naf_pledge,
  #patient_fund_pledge'

  $(document).on "change", balanceFields, ->
    updateBalance()

  $(document).on "click", "#create-external-pledge", ->
    # timeout to handle mongo updating and rails appending new field
    setTimeout(updateBalance, 500)

  if $("#patient_procedure_cost").val()
    updateBalance()
