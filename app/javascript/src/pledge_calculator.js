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
    $('.outstanding-balance-ctn').removeClass('hidden');
    return $('#outstanding-balance').text(`${calculateRemainder()}`);
  }
  // Hide if there isn't a procedure cost.
  return $('.outstanding-balance-ctn').addClass('hidden');
};


// Relevant fields and identifiers to listen for changes on
const balanceFields = '#abortion-information-form input, '
                      + '#external_pledges input, '
                      + '#patient_procedure_cost, '
                      + '#patient_patient_contribution, '
                      + '#patient_naf_pledge, '
                      + '#patient_fund_pledge';

$(document).on('turblinks:load', () => {
  $(balanceFields).on('change', () => {
    updateBalance();
  });
});
