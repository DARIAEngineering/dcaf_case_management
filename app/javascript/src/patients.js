// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

const markFulfilledWhenFieldsChecked = () => {
  const pledgeFields = [
    '#patient_fulfillment_fund_payout',
    '#patient_fulfillment_check_number',
    '#patient_fulfillment_gestation_at_procedure',
    '#patient_fulfillment_date_of_check',
    '#patient_fulfillment_procedure_date',
  ];

  let i = 0;
  let empty = true;
  const el = $('#patient_fulfillment_fulfilled');

  // TODO refactor this so it's cleaner
  while (i < pledgeFields.length) {
    if ($(pledgeFields[i]).val().length > 0) {
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
  return null;
};

$(document).on('turbolinks:load', () => {
  $(document).on("click", "#toggle-call-log", () => {
    $(".old-calls").toggleClass("hidden");
    const html = $(".old-calls").hasClass("hidden") ? "View all calls" : "Limit list";
    return $("#toggle-call-log").html(html);
  });

  $(document).on("change", ".edit_patient", () => {
    return $(this).submit();
  });

  $(document).on("change", ".edit_practical_support", () => {
    return $(this).submit();
  });

  $(document).on("change", "#pledge_fulfillment_form", () => {
    markFulfilledWhenFieldsChecked();
    return $(this).submit();
  });

  $(document).on("change", ".edit_external_pledge", () => {
    return $(this).submit();
  });

  return $(document).on("submit", "#generate-pledge-form form", () => {
    if($("#case_manager_name").val()) {
      return true;
    } else {
      $("#generate-pledge-form .alert").show();
      return false;
    }
  });
});
