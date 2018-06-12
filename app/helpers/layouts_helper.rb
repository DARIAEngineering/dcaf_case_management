module LayoutsHelper
  def flash_msg(name, msg)
    btn = content_tag :button, '&times;', type: 'button', class: 'close',
                               data: { dismiss: 'alert' }, 
                               aria: { hidden: true }
    glyph = tag :span, class: ['glyphicon', alert_glyphicon_for(name)],
                aria: { hidden: true }
    body = content_tag :div, msg, id: "flash_#{name}"
    content = safe_join [btn, glyph, body], ''

    content_tag :div, content, class: ['alert', alert_type_for(name)],
                               style: alert_style_for(name)
  end

  private

  def alert_type_for(name)
    name.to_s == 'notice' ? 'alert-success' : 'alert-danger'
  end

  def alert_style_for(name)
    return 'check' if name.to_s == 'notice'
    'danger'
  end

  def alert_glyphicon_for(name)
    return 'glyphicon-check' if name.to_s == 'notice'
    'glyphicon-exclamation'
  end
end
