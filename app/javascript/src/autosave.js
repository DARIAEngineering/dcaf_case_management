// Autosave on patient forms.


// // $(document).on 'turbolinks:load', ->
//   // $(document).on "click", "#toggle-call-log", ->
//   //   $(".old-calls").toggleClass("d-none")
//   //   html = if $(".old-calls").hasClass("d-none") then "View all calls" else "Limit list"
//   //   $("#toggle-call-log").html(html)


// markFulfilledWhenFieldsChecked = ->
//   pledge_fields = [
//     '#patient_fulfillment_attributes_fund_payout'
//     '#patient_fulfillment_attributes_check_number'
//     '#patient_fulfillment_attributes_gestation_at_procedure'
//     '#patient_fulfillment_attributes_date_of_check'
//     '#patient_fulfillment_attributes_procedure_date'
//   ]

//   i = 0
//   empty = true
//   el = $('#patient_fulfillment_attributes_fulfilled')

//   while i < pledge_fields.length
//     if $(pledge_fields[i]).val().length > 0
//       empty = false
//       if el.prop 'checked'
//         break;
//       else
//         el.prop 'checked', true
//       i++
//     else
//       i++
//   if empty == true
//     el.prop 'checked', false


const activateAutosave = () => {
  // Main patient form
  $(document).on("change", ".edit_patient", function() {
    $(this).submit();
  });

  // Practical support form
  $(document).on("change", ".edit_practical_support", function() {
    $(this).submit();
  })

  // Fulfillment form
  // If any of the fields are chekced, mark the Fulfilled checkbox too
  $(document).on("change", "#pledge_fulfillment_form", function() {

  }); 


};

    

  // $(document).on "change", "#pledge_fulfillment_form", ->
  //   markFulfilledWhenFieldsChecked()
  //   $(this).submit()

  // $(document).on "change", ".edit_external_pledge", ->
  //   $(this).submit()

  // $(document).on "submit", "#generate-pledge-form form", ->
  //   if($("#case_manager_name").val())
  //     true
  //   else
  //     $("#generate-pledge-form .alert").show()
  //     false


$(document).on('turbolinks:load', activateAutosave);
