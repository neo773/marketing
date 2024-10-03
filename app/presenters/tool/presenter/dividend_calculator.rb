class Tool::Presenter::DividendCalculator < Tool::Presenter
  attribute :stock_price, :tool_float, default: 0.0
  attribute :dividend_yield, :tool_percentage, default: 0.0
  attribute :total_invested, :tool_float, default: 0.0
  attribute :investment_duration, :tool_integer, default: 0, min: 0
  attribute :dividend_reinvestment_frequency, :string, default: "yearly"


  def blank?
    [ stock_price, dividend_yield, total_invested, investment_duration ].all?(&:zero?)
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

  def final_investment_value
    yearly_data_points.last[:currentTotalValue].round(2)
  end

  def initial_investment
    total_invested
  end

  def profit
    (final_investment_value - total_invested).round(2)
  end

  def annual_return
    ((final_investment_value / total_invested) ** (1.0 / investment_duration) - 1) * 100
  end

  def yearly_dividends
    (total_invested * dividend_yield).round(2)
  end

  private

  def active_record
    @active_record ||= Tool.find_by! slug: "dividend-calculator"
  end

  def yearly_data_points
    @yearly_data_points ||= calculate_yearly_data_points
  end

  def calculate_yearly_data_points
    points = []
    current_value = total_invested
    current_shares = total_invested / stock_price

    (0..investment_duration).each do |year|
      date = Date.current + year.years
      points << { year: year, date: date, currentTotalValue: current_value }

      reinvestment_times = reinvestment_frequency_multiplier
      reinvestment_times.times do
        dividend_amount = current_shares * stock_price * dividend_yield / reinvestment_times
        additional_shares = dividend_amount / stock_price
        current_shares += additional_shares
      end

      current_value = current_shares * stock_price
    end

    points
  end

  def reinvestment_frequency_multiplier
    case dividend_reinvestment_frequency
    when "monthly" then 12
    when "quarterly" then 4
    else 1
    end
  end
end
