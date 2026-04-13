// Helper tooltips — vanilla JS replacement (no jQuery).
// Uses @popperjs/core for positioning and Bootstrap 4 CSS classes for styling.
import { createPopper } from '@popperjs/core';

function initTooltip(el, content, options = {}) {
  if (!content) return;

  // Stash title so the native browser tooltip doesn't also appear
  el.removeAttribute('title');

  let tooltipEl = null;
  let popper = null;

  const show = () => {
    const placement = options.placement || 'top';
    tooltipEl = document.createElement('div');
    tooltipEl.className = `tooltip bs-tooltip-${placement} show`;
    tooltipEl.setAttribute('role', 'tooltip');
    tooltipEl.innerHTML =
      '<div class="arrow"></div>' +
      `<div class="tooltip-inner">${options.html ? content : escapeHTML(content)}</div>`;
    document.body.appendChild(tooltipEl);
    popper = createPopper(el, tooltipEl, {
      placement: placement,
      modifiers: [{ name: 'offset', options: { offset: [0, 8] } }],
    });
  };

  const hide = () => {
    if (popper) { popper.destroy(); popper = null; }
    if (tooltipEl) { tooltipEl.remove(); tooltipEl = null; }
  };

  el.addEventListener('mouseenter', show);
  el.addEventListener('mouseleave', hide);
  el.addEventListener('focusin', show);
  el.addEventListener('focusout', hide);
}

function escapeHTML(str) {
  const div = document.createElement('div');
  div.appendChild(document.createTextNode(str));
  return div.innerHTML;
}

export const activateTooltips = () => {
  // Regular spans
  document.querySelectorAll('.daria-tooltip').forEach(el => {
    if (el.dataset.tooltipBound) return;
    el.dataset.tooltipBound = '1';
    const text = el.getAttribute('title') || el.getAttribute('data-original-title') || '';
    initTooltip(el, text);
  });

  // Help icons for form inputs (rails-bootstrap-form labels)
  document.querySelectorAll('.tooltip-header-input').forEach(header => {
    if (!header.querySelector('span.tooltip-header-help')) {
      header.insertAdjacentHTML('beforeend', ' <span class="tooltip-header-help">(?)</span>');
    }
    const formGroup = header.closest('.form-group');
    if (!formGroup) return;
    const input = formGroup.querySelector('.form-control');
    if (!input) return;
    const text = input.dataset.tooltipText;
    if (!text) return;
    const helpSpan = formGroup.querySelector('.tooltip-header-help');
    if (!helpSpan || helpSpan.dataset.tooltipBound) return;
    helpSpan.dataset.tooltipBound = '1';
    initTooltip(helpSpan, text, { html: true, placement: 'bottom' });
  });

  // Help icons for checkboxes
  document.querySelectorAll('.tooltip-header-checkbox').forEach(header => {
    if (!header.querySelector('span.tooltip-header-help')) {
      header.insertAdjacentHTML('beforeend', ' <span class="tooltip-header-help">(?)</span>');
    }
    const parent = header.parentElement;
    if (!parent) return;
    const checkbox = parent.querySelector('input[type=checkbox]');
    if (!checkbox) return;
    const text = checkbox.dataset.tooltipText;
    if (!text) return;
    const helpSpan = parent.querySelector('span.tooltip-header-help');
    if (!helpSpan || helpSpan.dataset.tooltipBound) return;
    helpSpan.dataset.tooltipBound = '1';
    initTooltip(helpSpan, text, { html: true, placement: 'bottom' });
  });
};

// Activate on initial load, Turbo navigations, and modal opens
document.addEventListener('DOMContentLoaded', activateTooltips);
document.addEventListener('turbo:load', activateTooltips);
document.addEventListener('show.bs.modal', (e) => {
  if (e.target.classList.contains('modal')) activateTooltips();
}, true);
