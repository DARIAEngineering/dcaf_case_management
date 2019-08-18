// This function is much more complex than it needs to be and we should simplify it!
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
  $(document).on('click', '#toggle-call-log', () => {
    $('.old-calls').toggleClass('hidden');
    const html = $('.old-calls').hasClass('hidden') ? 'View all calls' : 'Limit list';
    return $('#toggle-call-log').html(html);
  });

  $(document).on('change', '.edit_patient', function smbt() {
    $.rails.fire($(this), 'submit');
  });

  $(document).on('change', '.edit_practical_support', function smbt() {
    $.rails.fire($(this), 'submit');
  });

  $(document).on('change', '#pledge_fulfillment_form', function smbt() {
    markFulfilledWhenFieldsChecked();
    $.rails.fire($(this), 'submit');
  });

  $(document).on('change', '.edit_external_pledge', function sbmt() {
    $.rails.fire($(this), 'submit');
  });

  return $(document).on('submit', '#generate-pledge-form form', () => {
    if ($('#case_manager_name').val()) {
      return true;
    }
    $('#generate-pledge-form .alert').show();
    return false;
  });
});
