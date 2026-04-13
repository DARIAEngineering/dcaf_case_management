/**
 * @jest-environment jsdom
 */

beforeEach(() => {
  document.body.innerHTML = '';
});

afterEach(() => {
  document.body.innerHTML = '';
});

const loadModule = () => {
  jest.resetModules();
  return import('../../app/javascript/src/autosave');
};

describe('autosave', () => {
  it('submits edit_patient form on change', async () => {
    document.body.innerHTML = `
      <form class="edit_patient" id="edit_patient_1">
        <input id="field1" value="old">
      </form>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const form = document.querySelector('.edit_patient');
    form.requestSubmit = jest.fn();

    const input = document.getElementById('field1');
    input.value = 'new';
    input.dispatchEvent(new Event('change', { bubbles: true }));

    expect(form.requestSubmit).toHaveBeenCalledTimes(1);
  });

  it('submits edit_practical_support form on change', async () => {
    document.body.innerHTML = `
      <form class="edit_practical_support" id="support_1">
        <input id="support_field" value="old">
      </form>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const form = document.querySelector('.edit_practical_support');
    form.requestSubmit = jest.fn();

    document.getElementById('support_field').dispatchEvent(new Event('change', { bubbles: true }));
    expect(form.requestSubmit).toHaveBeenCalledTimes(1);
  });

  it('submits edit_external_pledge form on change', async () => {
    document.body.innerHTML = `
      <form class="edit_external_pledge" id="pledge_1">
        <input id="pledge_field" value="100">
      </form>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const form = document.querySelector('.edit_external_pledge');
    form.requestSubmit = jest.fn();

    document.getElementById('pledge_field').dispatchEvent(new Event('change', { bubbles: true }));
    expect(form.requestSubmit).toHaveBeenCalledTimes(1);
  });

  it('does NOT submit when form id contains pledge_fulfillment', async () => {
    document.body.innerHTML = `
      <form class="edit_patient" id="pledge_fulfillment_edit_patient">
        <input id="field1" value="old">
      </form>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const form = document.querySelector('.edit_patient');
    form.requestSubmit = jest.fn();

    document.getElementById('field1').dispatchEvent(new Event('change', { bubbles: true }));
    expect(form.requestSubmit).not.toHaveBeenCalled();
  });

  it('does not submit unrelated forms', async () => {
    document.body.innerHTML = `
      <form class="new_patient" id="new_patient_form">
        <input id="field1" value="val">
      </form>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const form = document.querySelector('.new_patient');
    form.requestSubmit = jest.fn();

    document.getElementById('field1').dispatchEvent(new Event('change', { bubbles: true }));
    expect(form.requestSubmit).not.toHaveBeenCalled();
  });
});

describe('autosave – fulfillment form', () => {
  const buildFulfillmentForm = (fieldValues = {}) => {
    document.body.innerHTML = `
      <form id="pledge_fulfillment_form">
        <input type="checkbox" id="patient_fulfillment_attributes_fulfilled">
        <input id="patient_fulfillment_attributes_fund_payout" value="${fieldValues.fundPayout || ''}">
        <input id="patient_fulfillment_attributes_check_number" value="${fieldValues.checkNumber || ''}">
        <input id="patient_fulfillment_attributes_gestation_at_procedure" value="${fieldValues.gestation || ''}">
        <input id="patient_fulfillment_attributes_date_of_check" value="${fieldValues.dateOfCheck || ''}">
        <input id="patient_fulfillment_attributes_procedure_date" value="${fieldValues.procedureDate || ''}">
      </form>
    `;
  };

  it('submits fulfillment form on change', async () => {
    buildFulfillmentForm();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const form = document.getElementById('pledge_fulfillment_form');
    form.requestSubmit = jest.fn();

    const input = document.getElementById('patient_fulfillment_attributes_fund_payout');
    input.value = '500';
    input.dispatchEvent(new Event('change', { bubbles: true }));

    expect(form.requestSubmit).toHaveBeenCalledTimes(1);
  });

  it('checks fulfilled checkbox when any fulfillment field has value', async () => {
    buildFulfillmentForm({ fundPayout: '500' });
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const form = document.getElementById('pledge_fulfillment_form');
    form.requestSubmit = jest.fn();

    const input = document.getElementById('patient_fulfillment_attributes_fund_payout');
    input.dispatchEvent(new Event('change', { bubbles: true }));

    expect(document.getElementById('patient_fulfillment_attributes_fulfilled').checked).toBe(true);
  });

  it('unchecks fulfilled checkbox when all fulfillment fields are empty', async () => {
    buildFulfillmentForm();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const checkbox = document.getElementById('patient_fulfillment_attributes_fulfilled');
    checkbox.checked = true; // pre-check

    const form = document.getElementById('pledge_fulfillment_form');
    form.requestSubmit = jest.fn();

    const input = document.getElementById('patient_fulfillment_attributes_fund_payout');
    input.dispatchEvent(new Event('change', { bubbles: true }));

    expect(checkbox.checked).toBe(false);
  });

  it('checks fulfilled when multiple fields have values', async () => {
    buildFulfillmentForm({ fundPayout: '500', checkNumber: '12345' });
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const form = document.getElementById('pledge_fulfillment_form');
    form.requestSubmit = jest.fn();

    document.getElementById('patient_fulfillment_attributes_check_number')
      .dispatchEvent(new Event('change', { bubbles: true }));

    expect(document.getElementById('patient_fulfillment_attributes_fulfilled').checked).toBe(true);
  });

  it('handles missing fulfilled checkbox gracefully', async () => {
    document.body.innerHTML = `
      <form id="pledge_fulfillment_form">
        <input id="patient_fulfillment_attributes_fund_payout" value="500">
      </form>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const form = document.getElementById('pledge_fulfillment_form');
    form.requestSubmit = jest.fn();

    expect(() => {
      document.getElementById('patient_fulfillment_attributes_fund_payout')
        .dispatchEvent(new Event('change', { bubbles: true }));
    }).not.toThrow();
  });
});
