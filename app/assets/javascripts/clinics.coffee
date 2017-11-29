# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

getClinics = ->
  $.get '/clinics', ((data, status) ->
    if status == 'success'
      $.when data
  ), 'json'

filterClinicsByNAF = ->
  checked = $("#naf_filter").prop("checked")
  $("#patient_clinic_id > option").each ->
    if $(this).attr('data-naf') == "false"
      $(this).attr("disabled", checked)

mapNAFtoClinic = (data) ->
  $.each data, (index) ->
    id = data[index]._id.$oid
    accepts_naf = data[index].accepts_naf
    $('#patient_clinic_id > option[value=\'' + id + '\']').attr 'data-naf', accepts_naf

filterClinicsByMedicaid = ->
  checked = $("#medicaid_filter").prop("checked")
  $("#patient_clinic_id > option").each ->
    if $(this).attr('data-medicaid') == "false"
      $(this).attr("disabled", checked)

mapMedicaidToClinic = (data) ->
  $.each data, (index) ->
    id = data[index]._id.$oid
    accepts_medicaid = data[index].accepts_medicaid
    $('#patient_clinic_id > option[value=\'' + id + '\']').attr 'data-medicaid', accepts_medicaid

ready = ->
  $(document).on 'show.bs.collapse', '.collapsible-clinic-details', (event) ->
    $(event.target).siblings('.clinic-detail-toggle').text('Fewer Details')

  $(document).on 'hide.bs.collapse', '.collapsible-clinic-details', (event) ->
    $(event.target).siblings('.clinic-detail-toggle').text('More Details')

  $(document).on "click", "#naf_filter", ->
    attr = $('#patient_clinic_id > option').last().attr 'data-naf'
    if typeof attr == 'undefined'
      getClinics().then(mapNAFtoClinic).then(filterClinicsByNAF)
    else
      filterClinicsByNAF()

  $(document).on "click", "#medicaid_filter", ->
    attr = $('#patient_clinic_id > option').last().attr 'data-medicaid'
    if typeof attr == 'undefined'
      getClinics().then(mapMedicaidToClinic).then(filterClinicsByMedicaid)
    else
      filterClinicsByMedicaid()      

$(document).on 'ready page:load', ready
