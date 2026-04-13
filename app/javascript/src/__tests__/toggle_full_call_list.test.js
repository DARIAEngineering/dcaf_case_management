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
  return import('../../app/javascript/src/toggle_full_call_list');
};

describe('toggle_full_call_list', () => {
  const buildCallList = () => {
    document.body.innerHTML = `
      <button id="toggle-call-log">View all calls</button>
      <div class="old-calls d-none">Old call 1</div>
      <div class="old-calls d-none">Old call 2</div>
    `;
  };

  it('removes d-none from old-calls on first click', async () => {
    buildCallList();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    document.getElementById('toggle-call-log').click();

    document.querySelectorAll('.old-calls').forEach(el => {
      expect(el.classList.contains('d-none')).toBe(false);
    });
  });

  it('updates button text to "Limit list" when expanded', async () => {
    buildCallList();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    document.getElementById('toggle-call-log').click();

    expect(document.getElementById('toggle-call-log').innerHTML).toBe('Limit list');
  });

  it('re-adds d-none and resets text on second click', async () => {
    buildCallList();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const btn = document.getElementById('toggle-call-log');
    btn.click(); // expand
    btn.click(); // collapse

    document.querySelectorAll('.old-calls').forEach(el => {
      expect(el.classList.contains('d-none')).toBe(true);
    });
    expect(btn.innerHTML).toBe('View all calls');
  });

  it('toggles correctly through multiple cycles', async () => {
    buildCallList();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const btn = document.getElementById('toggle-call-log');
    for (let i = 0; i < 4; i++) {
      btn.click();
      const hidden = document.querySelector('.old-calls').classList.contains('d-none');
      if (i % 2 === 0) {
        expect(hidden).toBe(false);
        expect(btn.innerHTML).toBe('Limit list');
      } else {
        expect(hidden).toBe(true);
        expect(btn.innerHTML).toBe('View all calls');
      }
    }
  });

  it('handles click on child element of toggle button', async () => {
    document.body.innerHTML = `
      <button id="toggle-call-log"><span class="icon">▼</span> View all calls</button>
      <div class="old-calls d-none">Old call</div>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    document.querySelector('#toggle-call-log .icon').click();

    expect(document.querySelector('.old-calls').classList.contains('d-none')).toBe(false);
  });

  it('does nothing when no old-calls elements exist', async () => {
    document.body.innerHTML = '<button id="toggle-call-log">View all calls</button>';
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    expect(() => {
      document.getElementById('toggle-call-log').click();
    }).not.toThrow();
  });

  it('does nothing for clicks on unrelated elements', async () => {
    buildCallList();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    document.body.click();

    document.querySelectorAll('.old-calls').forEach(el => {
      expect(el.classList.contains('d-none')).toBe(true);
    });
  });
});
