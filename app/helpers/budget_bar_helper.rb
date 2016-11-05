module BudgetBarHelper
  def budget_bar(expenditures)
    expenditures = { pledged: 500, sent: 1250 }

    content_tag :div, id: 'budget_bar' do
      content_tag :div, class: 'progress' do
        progress_bars expenditures
      end
    end
  end

  private

  def progress_bar(type, value)
    content_tag :div, class: progress_bar_class(type),
                      style: width(value) do
      value.to_s
    end
  end

  def progress_bars(expenditures)
    set = [:pledged, :sent]
    bars = set.map do |type|
      progress_bar type, expenditures[type]
    end
    safe_join bars, ''
  end

  def progress_bar_class(type)
    color = type == :pledged ? 'warning' : 'success'
    "progress-bar progress-bar-#{color} progress-bar-striped"
  end

  def width(value)
    "width: #{to_pct(value)}%"
  end

  def to_pct(value)
    pct = (value.to_f / 1_350.to_f) * 100
    pct.round.to_s
  end
end

# <div class="progress_bar progress-bar-warning progress-bar-striped" style="width: 30%">100</div>