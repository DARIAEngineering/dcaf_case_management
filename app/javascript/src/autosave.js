// Autosave on patient forms.
const fulfillmentFields = [
  '#patient_fulfillment_attributes_fund_payout',
  '#patient_fulfillment_attributes_check_number',
  '#patient_fulfillment_attributes_gestation_at_procedure',
  '#patient_fulfillment_attributes_date_of_check',
  '#patient_fulfillment_attributes_procedure_date',
]

const _markFulfilledWhenFieldsChecked = () => {
  const fulfillmentCheckbox = document.getElementById('patient_fulfillment_attributes_fulfilled');
  let check = false;
  fulfillmentFields.forEach((field) => {
    const el = document.querySelector(field);
    if (el && el.value.length > 0) {
      check = true;
    }
  });
  if (fulfillmentCheckbox) fulfillmentCheckbox.checked = check;
};

const activateAutosave = () => {
  // Delegated change handlers for auto-submitting forms
  document.addEventListener('change', (e) => {
    const form = e.target.closest('.edit_patient, .edit_practical_support, .edit_external_pledge');
    if (form && !form.id.includes('pledge_fulfillment')) {
      form.requestSubmit();
      return;
    }

    // Fulfillment form
    if (e.target.closest('#pledge_fulfillment_form')) {
      _markFulfilledWhenFieldsChecked();
      e.target.closest('#pledge_fulfillment_form').requestSubmit();
    }
  });
};

document.addEventListener('DOMContentLoaded', activateAutosave);
