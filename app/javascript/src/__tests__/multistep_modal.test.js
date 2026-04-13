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
  return import('../../app/javascript/src/multistep_modal');
};

const buildModal = (id = 'test-modal', stepCount = 3) => {
  const steps = Array.from({ length: stepCount }, (_, i) =>
    `<div class="modal-step" data-step="${i}">Step ${i}</div>`
  ).join('');

  document.body.innerHTML = `
    <div id="${id}" class="modal">
      <div class="modal-dialog">
        <div class="modal-content">
          ${steps}
          <button class="next-step">Next</button>
          <button class="prev-step">Prev</button>
        </div>
      </div>
    </div>
  `;
};

describe('activateMultiModal', () => {
  it('shows only the first step on initialization', async () => {
    buildModal();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const steps = document.querySelectorAll('.modal-step');
    expect(steps[0].style.display).toBe('');
    expect(steps[1].style.display).toBe('none');
    expect(steps[2].style.display).toBe('none');
  });

  it('advances to the next step on next-step click', async () => {
    buildModal();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    document.querySelector('.next-step').click();

    const steps = document.querySelectorAll('.modal-step');
    expect(steps[0].style.display).toBe('none');
    expect(steps[1].style.display).toBe('');
    expect(steps[2].style.display).toBe('none');
  });

  it('goes back to the previous step on prev-step click', async () => {
    buildModal();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    document.querySelector('.next-step').click(); // step 1
    document.querySelector('.prev-step').click(); // back to step 0

    const steps = document.querySelectorAll('.modal-step');
    expect(steps[0].style.display).toBe('');
    expect(steps[1].style.display).toBe('none');
  });

  it('does not advance past the last step', async () => {
    buildModal('test-modal', 2);
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const next = document.querySelector('.next-step');
    next.click(); // step 1 (last)
    next.click(); // should stay at step 1

    const steps = document.querySelectorAll('.modal-step');
    expect(steps[0].style.display).toBe('none');
    expect(steps[1].style.display).toBe('');
  });

  it('does not go before the first step', async () => {
    buildModal();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    document.querySelector('.prev-step').click(); // already at 0

    const steps = document.querySelectorAll('.modal-step');
    expect(steps[0].style.display).toBe('');
    expect(steps[1].style.display).toBe('none');
  });

  it('resets to step 0 on show.bs.modal event', async () => {
    buildModal();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    // Navigate to step 2
    document.querySelector('.next-step').click();
    document.querySelector('.next-step').click();

    const steps = document.querySelectorAll('.modal-step');
    expect(steps[2].style.display).toBe('');

    // Trigger modal show
    const modal = document.getElementById('test-modal');
    modal.dispatchEvent(new Event('show.bs.modal'));

    expect(steps[0].style.display).toBe('');
    expect(steps[1].style.display).toBe('none');
    expect(steps[2].style.display).toBe('none');
  });

  it('handles modals with no steps gracefully', async () => {
    document.body.innerHTML = '<div id="empty-modal" class="modal"></div>';
    await loadModule();

    expect(() => {
      document.dispatchEvent(new Event('DOMContentLoaded'));
    }).not.toThrow();
  });

  it('works with next-step button inside nested elements', async () => {
    document.body.innerHTML = `
      <div id="nested-modal" class="modal">
        <div class="modal-step">Step 0</div>
        <div class="modal-step">Step 1</div>
        <button class="next-step"><span class="icon">→</span></button>
      </div>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    // Click the inner span — event delegation via closest('.next-step')
    document.querySelector('.next-step .icon').click();

    const steps = document.querySelectorAll('.modal-step');
    expect(steps[0].style.display).toBe('none');
    expect(steps[1].style.display).toBe('');
  });

  it('navigates through all steps sequentially', async () => {
    buildModal('test-modal', 4);
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const next = document.querySelector('.next-step');
    const steps = document.querySelectorAll('.modal-step');

    for (let i = 0; i < 3; i++) {
      next.click();
      expect(steps[i].style.display).toBe('none');
      expect(steps[i + 1].style.display).toBe('');
    }
  });
});
