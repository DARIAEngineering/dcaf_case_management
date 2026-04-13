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
  return import('../../app/javascript/src/clinics');
};

const buildClinicSelect = () => {
  document.body.innerHTML = `
    <select id="patient_clinic_id">
      <option value="1" data-naf="true" data-medicaid="true">Clinic A</option>
      <option value="2" data-naf="false" data-medicaid="true">Clinic B</option>
      <option value="3" data-naf="true" data-medicaid="false">Clinic C</option>
      <option value="4" data-naf="false" data-medicaid="false">Clinic D</option>
    </select>
    <input type="checkbox" id="patient_naf_filter">
    <input type="checkbox" id="patient_medicaid_filter">
  `;
};

describe('filterClinicsByNAF', () => {
  it('disables options with data-naf="false" when NAF filter is checked', async () => {
    buildClinicSelect();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const nafFilter = document.getElementById('patient_naf_filter');
    nafFilter.checked = true;
    nafFilter.click();

    const options = document.querySelectorAll('#patient_clinic_id > option');
    expect(options[0].disabled).toBe(false); // naf=true
    expect(options[1].disabled).toBe(true);  // naf=false
    expect(options[2].disabled).toBe(false); // naf=true
    expect(options[3].disabled).toBe(true);  // naf=false
  });

  it('re-enables options when NAF filter is unchecked', async () => {
    buildClinicSelect();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const nafFilter = document.getElementById('patient_naf_filter');

    // Check
    nafFilter.checked = true;
    nafFilter.click();

    // Uncheck
    nafFilter.checked = false;
    nafFilter.click();

    const options = document.querySelectorAll('#patient_clinic_id > option');
    options.forEach(opt => {
      expect(opt.disabled).toBe(false);
    });
  });
});

describe('filterClinicsByMedicaid', () => {
  it('disables options with data-medicaid="false" when Medicaid filter is checked', async () => {
    buildClinicSelect();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const medicaidFilter = document.getElementById('patient_medicaid_filter');
    medicaidFilter.checked = true;
    medicaidFilter.click();

    const options = document.querySelectorAll('#patient_clinic_id > option');
    expect(options[0].disabled).toBe(false); // medicaid=true
    expect(options[1].disabled).toBe(false); // medicaid=true
    expect(options[2].disabled).toBe(true);  // medicaid=false
    expect(options[3].disabled).toBe(true);  // medicaid=false
  });

  it('re-enables options when Medicaid filter is unchecked', async () => {
    buildClinicSelect();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const medicaidFilter = document.getElementById('patient_medicaid_filter');

    medicaidFilter.checked = true;
    medicaidFilter.click();

    medicaidFilter.checked = false;
    medicaidFilter.click();

    const options = document.querySelectorAll('#patient_clinic_id > option');
    options.forEach(opt => {
      expect(opt.disabled).toBe(false);
    });
  });
});

describe('combined filters', () => {
  it('applies both filters simultaneously', async () => {
    buildClinicSelect();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const nafFilter = document.getElementById('patient_naf_filter');
    const medicaidFilter = document.getElementById('patient_medicaid_filter');

    nafFilter.checked = true;
    nafFilter.click();

    medicaidFilter.checked = true;
    medicaidFilter.click();

    const options = document.querySelectorAll('#patient_clinic_id > option');
    expect(options[0].disabled).toBe(false); // both true
    expect(options[1].disabled).toBe(true);  // naf=false
    expect(options[2].disabled).toBe(true);  // medicaid=false
    expect(options[3].disabled).toBe(true);  // both false
  });

  it('does not affect options without data attributes', async () => {
    document.body.innerHTML = `
      <select id="patient_clinic_id">
        <option value="">Select a clinic</option>
        <option value="1" data-naf="false" data-medicaid="false">Clinic A</option>
      </select>
      <input type="checkbox" id="patient_naf_filter">
      <input type="checkbox" id="patient_medicaid_filter">
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const nafFilter = document.getElementById('patient_naf_filter');
    nafFilter.checked = true;
    nafFilter.click();

    const options = document.querySelectorAll('#patient_clinic_id > option');
    expect(options[0].disabled).toBe(false); // no data-naf
    expect(options[1].disabled).toBe(true);  // naf=false
  });

  it('does nothing when filter checkbox is missing', async () => {
    document.body.innerHTML = `
      <select id="patient_clinic_id">
        <option value="1" data-naf="false">Clinic A</option>
      </select>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    // No checkbox to click — just ensure no errors
    expect(document.querySelector('#patient_clinic_id > option').disabled).toBe(false);
  });
});
