class Tool::Presenter::SpeculatorCalculator < Tool::Presenter
  attribute :asset, :string
  attribute :predicted_value, :tool_float
  attribute :investment_amount, :tool_float, default: 1000.0

  def blank?
    [asset, predicted_value, investment_amount].any?(&:blank?)
  end

  def searchable_assets
    @searchable_assets ||= [
      { name: "Bitcoin (BTC)", value: "BTC" },
      { name: "Ethereum (ETH)", value: "ETH" },
      { name: "Apple Inc. (AAPL)", value: "AAPL" },
      { name: "Tesla, Inc. (TSLA)", value: "TSLA" }
    ]
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