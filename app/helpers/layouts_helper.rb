module LayoutsHelper
  def flash_msg(name, msg)
    close_glyph = tag :span, class: ['glyphicon', 'glyphicon-remove'],
                aria: { hidden: true }
    btn = content_tag :button, close_glyph, type: 'button', class: 'close',
                               data: { dismiss: 'alert' }, 
                               aria: { hidden: true }

    glyph = tag :span, class: ['glyphicon', 'flash-glyphicon', alert_glyphicon_for(name)],
                aria: { hidden: true }
    body = content_tag :span, msg, id: "flash_#{name}"
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
    return 'glyphicon-ok-sign' if name.to_s == 'notice'
    'glyphicon-exclamation-sign'
  end
end
