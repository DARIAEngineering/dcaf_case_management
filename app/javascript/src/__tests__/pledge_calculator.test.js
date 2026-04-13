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
  return import('../../app/javascript/src/pledge_calculator');
};

const buildPledgeForm = (overrides = {}) => {
  const defaults = {
    procedureCost: '',
    ultrasoundCost: '',
    patientContribution: '',
    nafPledge: '',
    fundPledge: '',
    externalPledges: [],
  };
  const vals = { ...defaults, ...overrides };

  document.body.innerHTML = `
    <form id="abortion-information-form">
      <input id="patient_procedure_cost" value="${vals.procedureCost}">
      <input id="patient_ultrasound_cost" value="${vals.ultrasoundCost}">
      <input id="patient_patient_contribution" value="${vals.patientContribution}">
      <input id="patient_naf_pledge" value="${vals.nafPledge}">
      <input id="patient_fund_pledge" value="${vals.fundPledge}">
      ${vals.externalPledges.map(v => `<input class="external_pledge_amount" value="${v}">`).join('')}
    </form>
    <div id="external_pledges">
      <button id="create-external-pledge">Add</button>
    </div>
    <div class="outstanding-balance-ctn d-none">
      <span id="outstanding-balance"></span>
    </div>
  `;
};

describe('pledge calculator – updateBalance via change events', () => {
  it('shows the balance container when procedure cost is set', async () => {
    buildPledgeForm({ procedureCost: '500' });
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const ctn = document.querySelector('.outstanding-balance-ctn');
    expect(ctn.classList.contains('d-none')).toBe(false);
  });

  it('hides balance container when procedure cost is empty', async () => {
    buildPledgeForm({ procedureCost: '' });
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const ctn = document.querySelector('.outstanding-balance-ctn');
    expect(ctn.classList.contains('d-none')).toBe(true);
  });

  it('calculates remainder correctly: total - contributions', async () => {
    buildPledgeForm({
      procedureCost: '1000',
      ultrasoundCost: '200',
      patientContribution: '100',
      nafPledge: '300',
      fundPledge: '200',
    });
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    // Remainder = (1000 + 200) - (100 + 300 + 200) = 600
    const balance = document.getElementById('outstanding-balance');
    expect(balance.textContent).toBe('$600');
  });

  it('includes external pledges in the calculation', async () => {
    buildPledgeForm({
      procedureCost: '1000',
      externalPledges: ['100', '200'],
    });
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    // Remainder = 1000 - (100 + 200) = 700
    const balance = document.getElementById('outstanding-balance');
    expect(balance.textContent).toBe('$700');
  });

  it('handles zero contributions', async () => {
    buildPledgeForm({ procedureCost: '500' });
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    expect(document.getElementById('outstanding-balance').textContent).toBe('$500');
  });

  it('shows negative remainder when overfunded', async () => {
    buildPledgeForm({
      procedureCost: '100',
      fundPledge: '500',
    });
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    expect(document.getElementById('outstanding-balance').textContent).toBe('$-400');
  });

  it('treats non-numeric input as zero', async () => {
    buildPledgeForm({
      procedureCost: '500',
      patientContribution: 'abc',
    });
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    expect(document.getElementById('outstanding-balance').textContent).toBe('$500');
  });

  it('recalculates on input change event', async () => {
    buildPledgeForm({ procedureCost: '500' });
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    expect(document.getElementById('outstanding-balance').textContent).toBe('$500');

    // Simulate updating patient contribution
    const input = document.getElementById('patient_patient_contribution');
    input.value = '200';
    input.dispatchEvent(new Event('change', { bubbles: true }));

    expect(document.getElementById('outstanding-balance').textContent).toBe('$300');
  });

  it('updates balance when fund pledge changes', async () => {
    buildPledgeForm({ procedureCost: '1000' });
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const input = document.getElementById('patient_fund_pledge');
    input.value = '400';
    input.dispatchEvent(new Event('change', { bubbles: true }));

    expect(document.getElementById('outstanding-balance').textContent).toBe('$600');
  });

  it('hides balance if procedure cost is cleared via change', async () => {
    buildPledgeForm({ procedureCost: '500' });
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const costInput = document.getElementById('patient_procedure_cost');
    costInput.value = '';
    costInput.dispatchEvent(new Event('change', { bubbles: true }));

    expect(document.querySelector('.outstanding-balance-ctn').classList.contains('d-none')).toBe(true);
  });
});

describe('pledge calculator – edge cases', () => {
  it('does not throw when balance element is missing', async () => {
    document.body.innerHTML = `
      <form id="abortion-information-form">
        <input id="patient_procedure_cost" value="500">
      </form>
      <div class="outstanding-balance-ctn d-none"></div>
    `;
    await loadModule();

    expect(() => {
      document.dispatchEvent(new Event('DOMContentLoaded'));
    }).not.toThrow();
  });

  it('handles missing form inputs gracefully', async () => {
    document.body.innerHTML = '<div></div>';
    await loadModule();

    expect(() => {
      document.dispatchEvent(new Event('DOMContentLoaded'));
    }).not.toThrow();
  });

  it('handles create-external-pledge button click with timeout', async () => {
    jest.useFakeTimers();
    buildPledgeForm({ procedureCost: '500' });
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    document.getElementById('create-external-pledge').click();

    // Add external pledge input dynamically (simulates Rails append)
    const newInput = document.createElement('input');
    newInput.className = 'external_pledge_amount';
    newInput.value = '100';
    document.getElementById('external_pledges').appendChild(newInput);

    jest.advanceTimersByTime(500);

    expect(document.getElementById('outstanding-balance').textContent).toBe('$400');
    jest.useRealTimers();
  });
});
