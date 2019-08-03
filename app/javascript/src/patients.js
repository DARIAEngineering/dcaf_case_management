// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

const markFulfilledWhenFieldsChecked = function() {
  const pledge_fields = [
    '#patient_fulfillment_fund_payout',
    '#patient_fulfillment_check_number',
    '#patient_fulfillment_gestation_at_procedure',
    '#patient_fulfillment_date_of_check',
    '#patient_fulfillment_procedure_date'
  ];

  let i = 0;
  let empty = true;
  const el = $('#patient_fulfillment_fulfilled');

  while (i < pledge_fields.length) {
    if ($(pledge_fields[i]).val().length > 0) {
      empty = false;
      if (el.prop('checked')) {
        break;
      } else {
        el.prop('checked', true);
      }
      i++;
    } else {
      i++;
    }
  }
  if (empty === true) {
    return el.prop('checked', false);
  }
};

$(document).on('turbolinks:load', function() {
  $(document).on("click", "#toggle-call-log", function() {
    $(".old-calls").toggleClass("hidden");
    const html = $(".old-calls").hasClass("hidden") ? "View all calls" : "Limit list";
    return $("#toggle-call-log").html(html);
  });

  $(document).on("change", ".edit_patient", function() {
    return $(this).submit();
  });

  $(document).on("change", ".edit_practical_support", function() {
    return $(this).submit();
  });

  $(document).on("change", "#pledge_fulfillment_form", function() {
    markFulfilledWhenFieldsChecked();
    return $(this).submit();
  });

  $(document).on("change", ".edit_external_pledge", function() {
    return $(this).submit();
  });

  return $(document).on("submit", "#generate-pledge-form form", function() {
    if($("#case_manager_name").val()) {
      return true;
    } else {
      $("#generate-pledge-form .alert").show();
      return false;
    }
  });
});
