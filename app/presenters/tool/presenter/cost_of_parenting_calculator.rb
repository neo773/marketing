class Tool::Presenter::CostOfParentingCalculator < Tool::Presenter
  attribute :yearly_household_income, :tool_float, default: 0.0
  attribute :children, :tool_integer, default: 0
  attribute :estimated_monthly_expenses, :tool_float, default: 0.0
  attribute :one_time_expenses, :tool_float, default: 0.0

  10.times do |i|
    attribute :"child_#{i + 1}_will_need_daycare", :tool_boolean, default: false
    attribute :"child_#{i + 1}_will_go_to_private_school", :tool_boolean, default: false
    attribute :"child_#{i + 1}_will_go_to_college", :tool_boolean, default: false
    attribute :"child_#{i + 1}_will_need_private_tutoring", :tool_boolean, default: false
    attribute :"child_#{i + 1}_will_go_to_summer_camp", :tool_boolean, default: false
    attribute :"child_#{i + 1}_will_play_sports", :tool_boolean, default: false
  end

  def blank?
    [ yearly_household_income, children, estimated_monthly_expenses, one_time_expenses ].all?(&:zero?)
  end

  def total_cost_per_child
    total_cost / children
  end

  def total_cost
    children.times.sum do |i|
      child_cost = (estimated_monthly_expenses * 12 * 18) + one_time_expenses
      child_cost = (estimated_monthly_expenses * 12 * 18) + one_time_expenses
      child_cost += calculate_daycare_cost if public_send(:"child_#{i + 1}_will_need_daycare")
      child_cost += calculate_private_school_cost if public_send(:"child_#{i + 1}_will_go_to_private_school")
      child_cost += calculate_college_cost if public_send(:"child_#{i + 1}_will_go_to_college")
      child_cost += calculate_private_tutoring_cost if public_send(:"child_#{i + 1}_will_need_private_tutoring")
      child_cost += calculate_summer_camp_cost if public_send(:"child_#{i + 1}_will_go_to_summer_camp")
      child_cost += calculate_sports_cost if public_send(:"child_#{i + 1}_will_play_sports")
      child_cost
    end
  end

  def yearly_cost
    total_cost / 18
  end

  def monthly_cost
    yearly_cost / 12
  end

  def daily_cost
    yearly_cost / 365
  end

  def percentage_of_income
    (yearly_cost / yearly_household_income) * 100
  end

  def monthly_income_after_expenses
    (yearly_household_income / 12) - monthly_cost
  end

  def daycare_cost_per_child
    calculate_daycare_cost
  end

  def college_cost_per_child
    calculate_college_cost
  end

  def extracurricular_cost_per_child
    calculate_sports_cost
  end

  private

  def active_record
    @active_record ||= Tool.find_by! slug: "cost-of-parenting-calculator"
  end

  def calculate_daycare_cost
    182112.33
  end

  def calculate_private_school_cost
    100000.00
  end

  def calculate_college_cost
    244112.96
  end

  def calculate_private_tutoring_cost
    100000.00
  end

  def calculate_summer_camp_cost
    100000.00
  end

  def calculate_sports_cost
    54000.00
  end
end
