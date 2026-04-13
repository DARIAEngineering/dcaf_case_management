// Coerce values into numbers, or zero if not set.
const valueToNumber = val => +val || 0;

const getVal = (id) => document.getElementById(id)?.value || '';

// Calculate remaining cash needed based on difference of
// procedure costs vs pledge fields.
const calculateRemainder = () => {
  const total = valueToNumber(getVal('patient_procedure_cost')) + valueToNumber(getVal('patient_ultrasound_cost'));
  const externalPledgeTotal = Array.from(document.querySelectorAll('.external_pledge_amount'))
    .reduce((acc, el) => acc + valueToNumber(el.value), 0);
  const contributions = valueToNumber(getVal('patient_patient_contribution'))
                        + valueToNumber(getVal('patient_naf_pledge'))
                        + valueToNumber(getVal('patient_fund_pledge'))
                        + externalPledgeTotal;
  return total - contributions;
};

// Show or hide amount remaining based on fields.
const updateBalance = () => {
  if (getVal('patient_procedure_cost')) {
    document.querySelectorAll('.outstanding-balance-ctn').forEach(el => el.classList.remove('d-none'));
    const balanceEl = document.getElementById('outstanding-balance');
    if (balanceEl) balanceEl.textContent = `$${calculateRemainder()}`;
    return;
  }
  document.querySelectorAll('.outstanding-balance-ctn').forEach(el => el.classList.add('d-none'));
};

// Relevant fields and identifiers to listen for changes on
const balanceSelectors = '#abortion-information-form input, '
                      + '#external_pledges input, '
                      + '#patient_procedure_cost, '
                      + '#patient_ultrasound_cost, '
                      + '#patient_patient_contribution, '
                      + '#patient_naf_pledge, '
                      + '#patient_fund_pledge';

document.addEventListener('DOMContentLoaded', () => {
  // Listen for changes on balance fields and update balance.
  document.querySelectorAll(balanceSelectors).forEach(el => {
    el.addEventListener('change', updateBalance);
  });

  // Set a timeout on adding new ext pledge to handle db updating and rails appending new field.
  document.getElementById('create-external-pledge')?.addEventListener('click', () => setTimeout(updateBalance, 500));

  // Show the balance on load if patient has a procedure cost.
  if (getVal('patient_procedure_cost')) {
    updateBalance();
  }
});
