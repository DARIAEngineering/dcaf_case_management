// Helper tooltips.
export const activateTooltips = () => {
  // Regular spans
  $(".daria-tooltip").tooltip();
  // Some evil magic for things attached to labels with rails-bootstrap-form
  $(".tooltip-header-input:not(:has(span.tooltip-header-help))").append(
    ' <span class="tooltip-header-help">(?)</span>'
  );
  $(".tooltip-header-input")
    .parent(".form-group")
    .find(".form-control")
    .each((_, x) => {
      $(x)
        .parents(".form-group")
        .find(".tooltip-header-help")
        .tooltip({
          html: true,
          placement: "bottom",
          title: $(x).data("tooltip-text"),
        });
    });

  // Similarly evil magic for checkboxes
  $(".tooltip-header-checkbox:not(:has(span.tooltip-header-help))").append(
    ' <span class="tooltip-header-help">(?)</span>'
  );
  $(".tooltip-header-checkbox").each((_, x) => {
    let text = $(x).parent().find("input[type=checkbox]").data("tooltip-text");
    $(x).parent().find("span.tooltip-header-help").tooltip({
      html: true,
      placement: "bottom",
      title: text,
    });
  });
};

$(document).on("DOMContentLoaded", activateTooltips);
