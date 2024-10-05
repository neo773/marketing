class Tool::Presenter::EarlyMortgagePayoffVsInvestingCalculator < Tool::Presenter
  attribute :loan_amount, :tool_float, default: 500000.0
  attribute :loan_term, :tool_integer, default: 30
  attribute :interest_rate, :tool_percentage, default: 6.20
  attribute :elapsed_time, :tool_integer, default: 0
  attribute :additional_payment, :tool_float, default: 500.0
  attribute :annual_investment_return, :tool_percentage, default: 4.0

  def blank?
    [ loan_amount, loan_term, interest_rate, additional_payment, annual_investment_return ].all?(&:zero?)
  end

  def interest_savings
    original_interest - interest_with_extra_payments
  end

  def new_payoff_date
    Date.today + (loan_term * 12 - months_saved).months
  end

  def investment_balance
    plot_data.last[:contributed].round(2)
  end

  def net_difference
    investment_balance - interest_savings
  end

  def legend_data
    {
      interest: {
        name: "Mortgage early payoff savings",
        fillClass: "fill-green-500",
        strokeClass: "stroke-green-500"
      },
      contributed: {
        name: "Investment account balance",
        fillClass: "fill-blue-500",
        strokeClass: "stroke-blue-500"
      }
    }
  end

  def plot_data
    @plot_data ||= generate_plot_data
  end

  private

  def active_record
    @active_record ||= Tool.find_by!(slug: "early-mortgage-payoff-vs-investing-calculator")
  end

  def original_interest
    monthly_payment * loan_term * 12 - loan_amount
  end

  def interest_with_extra_payments
    total_payments_with_extra - loan_amount
  end

  def monthly_payment
    @monthly_payment ||= calculate_monthly_payment(loan_amount, interest_rate / 100 / 12, loan_term * 12)
  end

  def total_payments_with_extra
    calculate_total_payments_with_extra
  end

  def months_saved
    loan_term * 12 - calculate_months_to_payoff
  end

  def calculate_monthly_payment(principal, monthly_rate, num_payments)
    (principal * monthly_rate * (1 + monthly_rate)**num_payments) / ((1 + monthly_rate)**num_payments - 1)
  end

  def calculate_total_payments_with_extra
    balance = loan_amount
    total_paid = 0
    monthly_rate = interest_rate / 100 / 12

    while balance > 0
      interest = balance * monthly_rate
      principal = [ monthly_payment + additional_payment - interest, balance ].min
      total_paid += principal + interest
      balance -= principal
    end

    total_paid
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
    monthly_rate = interest_rate / 100 / 12
    investment_monthly_rate = annual_investment_return / 100 / 12

    (loan_term * 12).times do |month|
      year = (month / 12.0).ceil

      interest = balance * monthly_rate
      principal = [ monthly_payment + additional_payment - interest, balance ].min
      balance -= principal
      total_interest_paid += interest

      investment_balance = investment_balance * (1 + investment_monthly_rate) + additional_payment
      mortgage_savings = original_interest - total_interest_paid

      data << {
        year: year,
        date: Date.today + year.years,
        interest: mortgage_savings,
        contributed: investment_balance
      }

      break if balance <= 0
    end

    data
  end
end
