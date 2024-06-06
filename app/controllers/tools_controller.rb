class ToolsController < ApplicationController
  def index
    @tools = Tool.all
  end

  def show
    @tool = Tool.find_by(slug: params[:id])
  end

  def roi_calculator
  end
end
