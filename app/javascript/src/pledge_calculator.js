// Coerce values into numbers, or zero if not set.
const valueToNumber = val => +val || 0;

// Calculate remaining cash needed based on difference of
// procedure costs vs pledge fields.
const calculateRemainder = () => {
  const total = valueToNumber($('#patient_procedure_cost').val());
  const contributions = valueToNumber($('#patient_patient_contribution').val())
                        + valueToNumber($('#patient_naf_pledge').val())
                        + valueToNumber($('#patient_fund_pledge').val())
                        + valueToNumber($('.external_pledge_amount').toArray().reduce((acc, next) => {
                          return acc + valueToNumber($(next).val());
                        }, 0));
  return total - contributions;
};

// Show or hide amount remaining based on fields.
const updateBalance = () => {
  if ($('#patient_procedure_cost').val()) {
    // Show remainder if patient procedure cost is known.
    $('.outstanding-balance-ctn').removeClass('d-none');
    return $('#outstanding-balance').text(`$${calculateRemainder()}`);
  }
  // Hide if there isn't a procedure cost.
  return $('.outstanding-balance-ctn').addClass('d-none');
};


// Relevant fields and identifiers to listen for changes on
const balanceFields = '#abortion-information-form input, '
                      + '#external_pledges input, '
                      + '#patient_procedure_cost, '
                      + '#patient_patient_contribution, '
                      + '#patient_naf_pledge, '
                      + '#patient_fund_pledge';

$(document).on('DOMContentLoaded', () => {
  // Listen for changes on balancefields and update balance.
  $(balanceFields).on('change', updateBalance);

  // Set a timeout on adding new ext pledge to handle db updating and rails appending new field.
  $('#create-external-pledge').on('click', () => setTimeout(updateBalance, 500));

  // Show the balance on load if patient has a procedure cost.
  if ($('#patient_procedure_cost').val()) {
    updateBalance();
  }
});
