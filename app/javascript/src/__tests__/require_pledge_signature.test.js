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
  return import('../../app/javascript/src/require_pledge_signature');
};

describe('require_pledge_signature', () => {
  const buildPledgeForm = (caseManagerName = '') => {
    document.body.innerHTML = `
      <form id="generate-pledge-form" action="/pledges">
        <input id="case_manager_name" value="${caseManagerName}">
        <div class="alert" style="display: none;">Please sign the pledge.</div>
        <button type="submit">Generate Pledge</button>
      </form>
    `;
  };

  it('allows form submission when case_manager_name is filled', async () => {
    buildPledgeForm('Jane Doe');
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const form = document.getElementById('generate-pledge-form');
    const event = new Event('submit', { bubbles: true, cancelable: true });
    const result = form.dispatchEvent(event);

    // Event was not prevented
    expect(result).toBe(true);
  });

  it('prevents submission when case_manager_name is empty', async () => {
    buildPledgeForm('');
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const form = document.getElementById('generate-pledge-form');
    const event = new Event('submit', { bubbles: true, cancelable: true });
    const result = form.dispatchEvent(event);

    expect(result).toBe(false);
  });

  it('shows the alert when submission is prevented', async () => {
    buildPledgeForm('');
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const form = document.getElementById('generate-pledge-form');
    form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));

    const alert = form.querySelector('.alert');
    expect(alert.style.display).toBe('');
  });

  it('does not show alert when name is provided', async () => {
    buildPledgeForm('Jane');
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const form = document.getElementById('generate-pledge-form');
    form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));

    const alert = form.querySelector('.alert');
    expect(alert.style.display).toBe('none');
  });

  it('does not interfere with other forms', async () => {
    document.body.innerHTML = `
      <form id="other-form" action="/other">
        <button type="submit">Submit</button>
      </form>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const form = document.getElementById('other-form');
    const event = new Event('submit', { bubbles: true, cancelable: true });
    const result = form.dispatchEvent(event);

    expect(result).toBe(true);
  });

  it('handles missing case_manager_name element', async () => {
    document.body.innerHTML = `
      <form id="generate-pledge-form">
        <div class="alert" style="display: none;">Error</div>
        <button type="submit">Generate</button>
      </form>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const form = document.getElementById('generate-pledge-form');
    const event = new Event('submit', { bubbles: true, cancelable: true });
    const result = form.dispatchEvent(event);

    // case_manager_name is null, so value is falsy → prevented
    expect(result).toBe(false);
  });

  it('handles missing alert element gracefully', async () => {
    document.body.innerHTML = `
      <form id="generate-pledge-form">
        <input id="case_manager_name" value="">
        <button type="submit">Generate</button>
      </form>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    expect(() => {
      const form = document.getElementById('generate-pledge-form');
      form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));
    }).not.toThrow();
  });
});
