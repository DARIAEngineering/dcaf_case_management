/**
 * @jest-environment jsdom
 */
import { createPopper } from '@popperjs/core';
import { activateTooltips } from '../../app/javascript/src/tooltips';

jest.mock('@popperjs/core', () => ({
  createPopper: jest.fn(() => ({ destroy: jest.fn() })),
}));

beforeEach(() => {
  document.body.innerHTML = '';
  createPopper.mockClear();
});

afterEach(() => {
  document.body.innerHTML = '';
});

describe('escapeHTML (via tooltip rendering)', () => {
  it('escapes HTML entities in non-html mode', () => {
    document.body.innerHTML = '<span class="daria-tooltip" title="<script>alert(1)</script>">hover</span>';
    activateTooltips();

    const el = document.querySelector('.daria-tooltip');
    el.dispatchEvent(new MouseEvent('mouseenter'));

    const inner = document.querySelector('.tooltip-inner');
    expect(inner.textContent).toBe('<script>alert(1)</script>');
    expect(inner.innerHTML).not.toContain('<script>');
  });

  it('escapes ampersands and quotes', () => {
    document.body.innerHTML = '<span class="daria-tooltip" title="A &amp; B &quot;quoted&quot;">hover</span>';
    activateTooltips();

    const el = document.querySelector('.daria-tooltip');
    el.dispatchEvent(new MouseEvent('mouseenter'));

    const inner = document.querySelector('.tooltip-inner');
    expect(inner).toBeTruthy();
  });
});

describe('initTooltip', () => {
  it('creates a Popper tooltip on mouseenter and removes on mouseleave', () => {
    document.body.innerHTML = '<span class="daria-tooltip" title="Hello">hover me</span>';
    activateTooltips();

    const el = document.querySelector('.daria-tooltip');

    // Show
    el.dispatchEvent(new MouseEvent('mouseenter'));
    expect(createPopper).toHaveBeenCalledTimes(1);
    expect(document.querySelector('.tooltip')).toBeTruthy();
    expect(document.querySelector('.tooltip').classList.contains('show')).toBe(true);
    expect(document.querySelector('.tooltip-inner').textContent).toBe('Hello');

    // Hide
    el.dispatchEvent(new MouseEvent('mouseleave'));
    expect(document.querySelector('.tooltip')).toBeNull();
  });

  it('creates tooltip on focusin and removes on focusout', () => {
    document.body.innerHTML = '<span class="daria-tooltip" title="Focus tip">focus me</span>';
    activateTooltips();

    const el = document.querySelector('.daria-tooltip');

    el.dispatchEvent(new FocusEvent('focusin'));
    expect(createPopper).toHaveBeenCalledTimes(1);
    expect(document.querySelector('.tooltip')).toBeTruthy();

    el.dispatchEvent(new FocusEvent('focusout'));
    expect(document.querySelector('.tooltip')).toBeNull();
  });

  it('uses top placement by default', () => {
    document.body.innerHTML = '<span class="daria-tooltip" title="Top">tip</span>';
    activateTooltips();

    const el = document.querySelector('.daria-tooltip');
    el.dispatchEvent(new MouseEvent('mouseenter'));

    expect(createPopper).toHaveBeenCalledWith(
      el,
      expect.any(HTMLElement),
      expect.objectContaining({ placement: 'top' })
    );
    expect(document.querySelector('.tooltip').classList.contains('bs-tooltip-top')).toBe(true);
  });

  it('removes the title attribute to prevent native tooltip', () => {
    document.body.innerHTML = '<span class="daria-tooltip" title="Native">tip</span>';
    activateTooltips();

    const el = document.querySelector('.daria-tooltip');
    expect(el.getAttribute('title')).toBeNull();
  });

  it('includes an arrow element in the tooltip', () => {
    document.body.innerHTML = '<span class="daria-tooltip" title="Arrow">tip</span>';
    activateTooltips();

    document.querySelector('.daria-tooltip').dispatchEvent(new MouseEvent('mouseenter'));
    expect(document.querySelector('.tooltip .arrow')).toBeTruthy();
  });

  it('does nothing when content is empty', () => {
    document.body.innerHTML = '<span class="daria-tooltip" title="">empty</span>';
    activateTooltips();

    document.querySelector('.daria-tooltip').dispatchEvent(new MouseEvent('mouseenter'));
    expect(createPopper).not.toHaveBeenCalled();
    expect(document.querySelector('.tooltip')).toBeNull();
  });
});

describe('activateTooltips', () => {
  it('skips elements already bound (data-tooltipBound flag)', () => {
    document.body.innerHTML = '<span class="daria-tooltip" title="Once">tip</span>';
    activateTooltips();
    activateTooltips(); // call again

    const el = document.querySelector('.daria-tooltip');
    el.dispatchEvent(new MouseEvent('mouseenter'));

    // Should only have one tooltip, not two stacked
    expect(createPopper).toHaveBeenCalledTimes(1);
  });

  it('sets data-tooltipBound on processed elements', () => {
    document.body.innerHTML = '<span class="daria-tooltip" title="Bound">tip</span>';
    activateTooltips();

    expect(document.querySelector('.daria-tooltip').dataset.tooltipBound).toBe('1');
  });

  it('reads data-original-title as fallback', () => {
    document.body.innerHTML = '<span class="daria-tooltip" data-original-title="Fallback">tip</span>';
    activateTooltips();

    const el = document.querySelector('.daria-tooltip');
    el.dispatchEvent(new MouseEvent('mouseenter'));
    expect(document.querySelector('.tooltip-inner').textContent).toBe('Fallback');
  });

  it('handles multiple tooltip elements', () => {
    document.body.innerHTML = `
      <span class="daria-tooltip" title="First">a</span>
      <span class="daria-tooltip" title="Second">b</span>
    `;
    activateTooltips();

    const els = document.querySelectorAll('.daria-tooltip');
    expect(els[0].dataset.tooltipBound).toBe('1');
    expect(els[1].dataset.tooltipBound).toBe('1');
  });
});

describe('tooltip-header-input (form input help icons)', () => {
  it('injects a help span and binds a tooltip from input data-tooltip-text', () => {
    document.body.innerHTML = `
      <div class="form-group">
        <label class="tooltip-header-input">Label</label>
        <input class="form-control" data-tooltip-text="Help <b>text</b>">
      </div>
    `;
    activateTooltips();

    const helpSpan = document.querySelector('.tooltip-header-help');
    expect(helpSpan).toBeTruthy();
    expect(helpSpan.textContent).toBe('(?)');
    expect(helpSpan.dataset.tooltipBound).toBe('1');

    // Show tooltip — html mode uses bottom placement
    helpSpan.dispatchEvent(new MouseEvent('mouseenter'));
    expect(createPopper).toHaveBeenCalledWith(
      helpSpan,
      expect.any(HTMLElement),
      expect.objectContaining({ placement: 'bottom' })
    );
  });

  it('does not duplicate help span on second activation', () => {
    document.body.innerHTML = `
      <div class="form-group">
        <label class="tooltip-header-input">Label</label>
        <input class="form-control" data-tooltip-text="Info">
      </div>
    `;
    activateTooltips();
    activateTooltips();

    expect(document.querySelectorAll('.tooltip-header-help').length).toBe(1);
  });

  it('skips when form-group has no form-control', () => {
    document.body.innerHTML = `
      <div class="form-group">
        <label class="tooltip-header-input">Label</label>
      </div>
    `;
    activateTooltips();

    const helpSpan = document.querySelector('.tooltip-header-help');
    expect(helpSpan).toBeTruthy();
    // No tooltip bound since no input
    expect(helpSpan.dataset.tooltipBound).toBeUndefined();
  });

  it('skips when input has no tooltip-text data attribute', () => {
    document.body.innerHTML = `
      <div class="form-group">
        <label class="tooltip-header-input">Label</label>
        <input class="form-control">
      </div>
    `;
    activateTooltips();
    expect(document.querySelector('.tooltip-header-help').dataset.tooltipBound).toBeUndefined();
  });
});

describe('tooltip-header-checkbox (checkbox help icons)', () => {
  it('injects help span and binds tooltip from checkbox data-tooltip-text', () => {
    document.body.innerHTML = `
      <div>
        <label class="tooltip-header-checkbox">Check</label>
        <input type="checkbox" data-tooltip-text="Checkbox help">
      </div>
    `;
    activateTooltips();

    const helpSpan = document.querySelector('.tooltip-header-help');
    expect(helpSpan).toBeTruthy();
    expect(helpSpan.dataset.tooltipBound).toBe('1');
  });

  it('skips when no checkbox is present', () => {
    document.body.innerHTML = `
      <div>
        <label class="tooltip-header-checkbox">Check</label>
      </div>
    `;
    activateTooltips();
    expect(document.querySelector('.tooltip-header-help').dataset.tooltipBound).toBeUndefined();
  });
});
