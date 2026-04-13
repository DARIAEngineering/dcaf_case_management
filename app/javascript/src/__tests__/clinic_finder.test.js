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
  return import('../../app/javascript/src/clinic_finder');
};

describe('clinic_finder', () => {
  const buildClinicFinder = () => {
    document.body.innerHTML = `
      <button class="clinic-finder-expand">Find Clinic</button>
      <div id="clinic-finder-search-form" class="d-none">
        <input type="text" placeholder="Search...">
      </div>
    `;
  };

  it('toggles d-none on search form when expand button is clicked', async () => {
    buildClinicFinder();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    document.querySelector('.clinic-finder-expand').click();

    expect(document.getElementById('clinic-finder-search-form').classList.contains('d-none')).toBe(false);
  });

  it('hides search form on second click', async () => {
    buildClinicFinder();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const btn = document.querySelector('.clinic-finder-expand');
    btn.click(); // show
    btn.click(); // hide

    expect(document.getElementById('clinic-finder-search-form').classList.contains('d-none')).toBe(true);
  });

  it('handles click on child element of expand button', async () => {
    document.body.innerHTML = `
      <button class="clinic-finder-expand"><span class="icon">🔍</span></button>
      <div id="clinic-finder-search-form" class="d-none">Form</div>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    document.querySelector('.clinic-finder-expand .icon').click();

    expect(document.getElementById('clinic-finder-search-form').classList.contains('d-none')).toBe(false);
  });

  it('does nothing when search form element is missing', async () => {
    document.body.innerHTML = '<button class="clinic-finder-expand">Find</button>';
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    expect(() => {
      document.querySelector('.clinic-finder-expand').click();
    }).not.toThrow();
  });

  it('does nothing for clicks on unrelated elements', async () => {
    buildClinicFinder();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    document.body.click();

    expect(document.getElementById('clinic-finder-search-form').classList.contains('d-none')).toBe(true);
  });
});
