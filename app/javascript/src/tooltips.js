// Pertaining to tooltips
$(document).on('turbolinks:load', () => {
  const tooltipSpan = ' <span class="tooltip-header-help">(?)</span>';
  // For regular spans
  $('.daria-tooltip').tooltip();

  // Some evil magic for things attached to labels with rails-bootstrap-form
  $('.tooltip-header-input').each(function() {
    $(this).append(tooltipSpan);
    const text = $(this).parent().find('input')[0].dataset.tooltipText;
    return $(this).parent().find('span.tooltip-header-help').tooltip({
      html: true,
      placement: 'bottom',
      title: text,
    });
  });

  // Some even eviller magic for checkboxes
  $('.tooltip-header-checkbox').each(function() {
    $(this).append(tooltipSpan);
    const text = $(this).parent().find('input[type=checkbox]')[0].dataset.tooltipText;
    return $(this).parent().find('span.tooltip-header-help').tooltip({
      html: true,
      placement: 'bottom',
      title: text,
    });
  });
});
