# Pertaining to tooltips

$(document).on 'turbolinks:load', ->
  # For regular spans
  $('.daria-tooltip').each ->
    $(@).tooltip({
      html: true,
      placement: 'bottom',
      title: $(@).data('tooltip-text')
    })

  # Some evil magic for things attached to labels with rails-bootstrap-form
  $('.tooltip-header-input').append(' <span class="tooltip-header-help">(?)</span>')
  $('.tooltip-header-input').parent('.form-group' ).find('.form-control').each ->
    $(@).parents( '.form-group' ).find( '.tooltip-header-help' ).tooltip({
      html: true,
      placement: 'bottom',
      title: $(@).data('tooltip-text')
    })

  # Some even eviller magic for checkboxes
  $('.tooltip-header-checkbox').append(' <span class="tooltip-header-help">(?)</span>')
  $('.tooltip-header-checkbox').each ->
    text = $(@).parent().find('input[type=checkbox]').data('tooltip-text')
    $(@).parent().find( 'span.tooltip-header-help' ).tooltip({
      html: true,
      placement: 'bottom',
      title: text
    })
