class Tool::Presenter::EarlyMortgagePayoffVsInvestingCalculator < Tool::Presenter
  attribute :loan_amount, :tool_float, default: 0
  attribute :loan_term, :tool_integer, default: 0
  attribute :interest_rate, :tool_percentage, default: 0
  attribute :additional_payment, :tool_float, default: 0
  attribute :annual_investment_return, :tool_percentage, default: 0
  attribute :elapsed_time, :tool_integer, default: 0

  def blank?
    [ loan_amount, loan_term, interest_rate, additional_payment, annual_investment_return ].all?(&:zero?)
  end

  def interest_savings
    (total_interest - total_interest_with_extra_payments).round(2)
  end

  def months_saved
    (loan_term * 12 - months_to_payoff).round(0)
  end

  def new_payoff_date
    original_payoff_date - months_saved.months
  end

  def investment_balance
    calculate_investment_balance
  end

  def net_difference
    (investment_balance - interest_savings).round(2)
  end

  def legend_data
    {
      mortgage: {
        name: "Mortgage Interest Savings",
        fillClass: "fill-green-500",
        strokeClass: "stroke-green-500"
      },
      invested: {
        name: "Investment Growth",
        fillClass: "fill-blue-500",
        strokeClass: "stroke-blue-500"
      }
    }
  end

  def plot_data
    @plot_data ||= generate_plot_data
  end

  def total_payments
    (loan_amount + total_interest).round(2)
  end

  def original_payoff_date
    Date.today + (loan_term * 12).months
  end

  def months_saved_formatted
    years = months_saved / 12
    remaining_months = months_saved % 12
    "#{years} years #{remaining_months} months"
  end

  def active_record
    @active_record ||= Tool.find_by!(slug: "early-mortgage-payoff-vs-investing-calculator")
  end

  def monthly_payment
    @monthly_payment ||= calculate_monthly_payment(loan_amount, interest_rate / 100 / 12, loan_term * 12)
  end

  def total_interest
    (monthly_payment * loan_term * 12 - loan_amount).round(2)
  end

  def total_interest_with_extra_payments
    (calculate_total_interest_with_extra - loan_amount).round(2)
  end

  def total_payments_with_extra
    (loan_amount + total_interest_with_extra_payments).round(2)
  end

  def months_to_payoff
    calculate_months_to_payoff
  end

  def calculate_monthly_payment(principal, monthly_rate, num_payments)
    (principal * monthly_rate * (1 + monthly_rate)**num_payments) / ((1 + monthly_rate)**num_payments - 1)
  end

  def calculate_months_to_payoff
    balance = loan_amount
    months = 0
    monthly_rate = interest_rate / 100 / 12

    while balance > 0
      interest = balance * monthly_rate
      principal = [ monthly_payment + additional_payment - interest, balance ].min
      balance -= principal
      months += 1
    end

    months
  end

  def generate_plot_data
    data = []
    balance = loan_amount
    investment_balance = 0
    total_interest_paid = 0
    monthly_rate = interest_rate / 100.0 / 12.0
    investment_monthly_rate = annual_investment_return / 100.0 / 12.0

    (loan_term * 12).times do |month|
      year = (month / 12.0).ceil

      interest = balance * monthly_rate
      principal = [ monthly_payment + additional_payment - interest, balance ].min
      balance -= principal
      total_interest_paid += interest

      investment_balance = investment_balance * (1 + investment_monthly_rate) + additional_payment
      mortgage_savings = total_interest - total_interest_paid

      data << {
        year: year,
        date: Date.today + year.years,
        mortgage: mortgage_savings,
        invested: investment_balance
      }

      break if balance <= 0
    end

    data
  end

  def net_difference_class
    net_difference < 0 ? "from-red-50" : "from-green-50"
  end

  def icon_class
    net_difference < 0 ? "text-red-600" : "text-green-600"
  end

  def tip_text
    net_difference < 0 ? "Paying off the mortgage early could potentially save you more money versus investing the extra payments" : "Investing the extra payments could potentially yield better returns versus paying off the mortgage early"
  end

  private

  def calculate_investment_balance
    balance = 0
    monthly_rate = annual_investment_return / 100.0 / 12.0
    (elapsed_time * 12).times do
      balance = balance * (1 + monthly_rate) + additional_payment
    end
    balance.round(2)
  end

  def calculate_total_interest_with_extra
    balance = loan_amount
    total_interest_paid = 0
    monthly_rate = interest_rate / 100 / 12

    while balance > 0
      interest = balance * monthly_rate
      principal = [ monthly_payment + additional_payment - interest, balance ].min
      balance -= principal
      total_interest_paid += interest
    end

    total_interest_paid
  end
end
