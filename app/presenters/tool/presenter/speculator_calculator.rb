class Tool::Presenter::SpeculatorCalculator < Tool::Presenter
  attribute :asset, :string
  attribute :predicted_value, :tool_float
  attribute :investment_amount, :tool_float, default: 1000.0

  def blank?
    [asset, predicted_value, investment_amount].any?(&:blank?)
  end

  def searchable_stocks
    @searchable_stocks ||= Stock.select(:name, :symbol).map do |stock|
      { name: stock.name, value: stock.symbol }
    end
  end

  def future_value
    investment_amount * (predicted_value / current_price)
  end

  def gain
    future_value - investment_amount
  end

  def multiple
    predicted_value / current_price
  end

  def trend_class
    gain >= 0 ? "from-green-50" : "from-red-50"
  end

  def multiple_class
    gain >= 0 ? "text-green-500 text-4xl font-medium" : "text-red-500 text-4xl font-medium"
  end

  def gain_or_loss_label
    gain >= 0 ? "Your gain" : "Your loss"
  end

  def gain_or_loss_sign
    gain >= 0 ? "+" : ""
  end

  def asset_name
    searchable_stocks.find { |a| a[:value] == asset }&.dig(:name) || "Unknown Asset"
  end

  def asset_ticker
    searchable_stocks.find { |a| a[:value] == asset }&.dig(:value) || "Unknown Asset"
  end

  def multiple_sign
    gain <= 0 ? "-" : ""
  end

  private

  def active_record
    @active_record ||= Tool.find_by!(slug: "speculator-calculator")
  end

  def current_price
    # This should be replaced with actual API call to get current price
    case asset
    when "BTC" then 30000
    when "ETH" then 2000
    when "AAPL" then 150
    when "TSLA" then 200
    else 1
    end
  end
end