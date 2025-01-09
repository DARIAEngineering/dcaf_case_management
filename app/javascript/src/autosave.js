// Autosave on patient forms.
const fulfillmentFields = [
  '#patient_fulfillment_attributes_fund_payout',
  '#patient_fulfillment_attributes_check_number',
  '#patient_fulfillment_attributes_gestation_at_procedure',
  '#patient_fulfillment_attributes_date_of_check',
  '#patient_fulfillment_attributes_procedure_date',
]

const _markFulfilledWhenFieldsChecked = () => {
  const fulfillmentCheckbox = $('#patient_fulfillment_attributes_fulfilled');
  let check = false
  fulfillmentFields.forEach((field) => {
    const hasData = $(field).val().length > 0;
    if (hasData) {
      check = true;
    }
  });
  fulfillmentCheckbox.prop('checked', check);
};

const activateAutosave = () => {
  // Main patient form
  $(document).on("change", ".edit_patient", function() {
    $(this).submit();
  });

  // Practical support form
  $(document).on("change", ".edit_practical_support", function() {
    $(this).submit();
  });

  // Ext pledge form
  $(document).on("change", ".edit_external_pledge", function() {
    $(this).submit();
  });

  // Fulfillment form
  // If any of the fields are chekced, mark the Fulfilled checkbox too
  $(document).on("change", "#pledge_fulfillment_form", function() {
    _markFulfilledWhenFieldsChecked();
    $(this).submit();
  });
};

$(document).on('DOMContentLoaded', activateAutosave);
