// Helper tooltips - uses Bootstrap 5 Tooltip API.
export const activateTooltips = () => {
  // Regular spans
  document.querySelectorAll('.daria-tooltip').forEach(el => {
    if (!bootstrap.Tooltip.getInstance(el)) new bootstrap.Tooltip(el);
  });

  // Some evil magic for things attached to labels with rails-bootstrap-form
  $(".tooltip-header-input:not(:has(span.tooltip-header-help))").append(' <span class="tooltip-header-help">(?)</span>');
  $('.tooltip-header-input').parent('.form-group').find('.form-control').each((_, x) => {
    var helpEl = $(x).parents('.form-group').find('.tooltip-header-help')[0];
    if (helpEl && !bootstrap.Tooltip.getInstance(helpEl)) {
      new bootstrap.Tooltip(helpEl, {
        html: true,
        placement: 'bottom',
        title: $(x).data('tooltip-text')
      });
    }
  });

  // Similarly evil magic for checkboxes
  $(".tooltip-header-checkbox:not(:has(span.tooltip-header-help))").append(' <span class="tooltip-header-help">(?)</span>');
  $('.tooltip-header-checkbox').each((_, x) => {
    let text = $(x).parent().find('input[type=checkbox]').data('tooltip-text');
    var helpEl = $(x).parent().find('span.tooltip-header-help')[0];
    if (helpEl && !bootstrap.Tooltip.getInstance(helpEl)) {
      new bootstrap.Tooltip(helpEl, {
        html: true,
        placement: 'bottom',
        title: text,
      });
    }
  });

};

$(document).on('DOMContentLoaded', activateTooltips);
$('.modal').on('show.bs.modal', activateTooltips);
