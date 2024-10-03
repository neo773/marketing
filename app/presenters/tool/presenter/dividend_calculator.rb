class Tool::Presenter::DividendCalculator < Tool::Presenter
  attribute :stock_price, :tool_float, default: 0.0
  attribute :dividend_yield, :tool_percentage, default: 0.0
  attribute :total_invested, :tool_float, default: 0.0
  attribute :investment_duration, :tool_integer, default: 0, min: 0
  attribute :dividend_reinvestment_frequency, :string, default: "yearly"

  def blank?
    [ stock_price, dividend_yield, total_invested, investment_duration ].all?(&:zero?)
  end

  def final_investment_value
    yearly_data_points.last[:currentTotalValue].round(2)
  end

  def total_dividends_earned
    yearly_data_points.last[:totalDividendsEarned].round(2)
  end

  def annual_return
    return 0 if investment_duration.zero? || total_invested.zero?
    ((final_investment_value / total_invested)**(1.0 / investment_duration) - 1) * 100
  end

  def plot_data
    yearly_data_points.map do |point|
      {
        year: point[:year],
        date: point[:date],
        currentTotalValue: point[:currentTotalValue].round(2)
      }
    end
  end

  def legend_data
    {
      currentTotalValue: {
        name: "Investment Value",
        fillClass: "fill-pink-500",
        strokeClass: "stroke-pink-500"
      }
    }
  end

  private

  def active_record
    @active_record ||= Tool.find_by! slug: "dividend-calculator"
  end

  def yearly_data_points
    @yearly_data_points ||= begin
      result = [ {
        year: 0,
        date: Date.today,
        currentTotalValue: total_invested,
        totalDividendsEarned: 0
      } ]
      current_value = total_invested
      total_dividends = 0
      shares = total_invested / stock_price

      investment_duration.times do |year|
        dividends_this_year = calculate_dividends(current_value)
        total_dividends += dividends_this_year

        if dividend_reinvestment_frequency == "yearly"
          shares += dividends_this_year / stock_price
          current_value = shares * stock_price
        else
          current_value += dividends_this_year
        end

        result << {
          year: year + 1,
          date: Date.today + (year + 1).years,
          currentTotalValue: current_value,
          totalDividendsEarned: total_dividends
        }
      end

      result
    end
  end

  def calculate_dividends(value)
    case dividend_reinvestment_frequency
    when "monthly"
      12.times.sum { |_| value * (dividend_yield / 12 / 100) }
    when "quarterly"
      4.times.sum { |_| value * (dividend_yield / 4 / 100) }
    else # yearly
      value * (dividend_yield / 100)
    end
  end
end
