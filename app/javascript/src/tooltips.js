// Helper tooltips.
import * as bootstrap from 'bootstrap';

export const activateTooltips = () => {
  // Regular spans — use Bootstrap 5 native API
  document.querySelectorAll('.daria-tooltip').forEach(el => {
    if (!bootstrap.Tooltip.getInstance(el)) {
      new bootstrap.Tooltip(el);
    }
  });

  // Some evil magic for things attached to labels with rails-bootstrap-form
  document.querySelectorAll(".tooltip-header-input:not(:has(span.tooltip-header-help))").forEach(el => {
    el.insertAdjacentHTML('beforeend', ' <span class="tooltip-header-help">(?)</span>');
  });
  document.querySelectorAll('.tooltip-header-input').forEach(label => {
    const formGroup = label.closest('.mb-3') || label.closest('.form-group');
    if (!formGroup) return;
    const input = formGroup.querySelector('.form-control');
    if (!input) return;
    const helpSpan = formGroup.querySelector('.tooltip-header-help');
    if (helpSpan && !bootstrap.Tooltip.getInstance(helpSpan)) {
      new bootstrap.Tooltip(helpSpan, {
        html: true,
        placement: 'bottom',
        title: input.dataset.tooltipText
      });
    }
  });

  // Similarly evil magic for checkboxes
  document.querySelectorAll(".tooltip-header-checkbox:not(:has(span.tooltip-header-help))").forEach(el => {
    el.insertAdjacentHTML('beforeend', ' <span class="tooltip-header-help">(?)</span>');
  });
  document.querySelectorAll('.tooltip-header-checkbox').forEach(el => {
    const checkbox = el.parentElement?.querySelector('input[type=checkbox]');
    const helpSpan = el.parentElement?.querySelector('span.tooltip-header-help');
    if (checkbox && helpSpan && !bootstrap.Tooltip.getInstance(helpSpan)) {
      new bootstrap.Tooltip(helpSpan, {
        html: true,
        placement: 'bottom',
        title: checkbox.dataset.tooltipText,
      });
    }
  });

};

document.addEventListener('DOMContentLoaded', activateTooltips);
document.addEventListener('show.bs.modal', activateTooltips);
