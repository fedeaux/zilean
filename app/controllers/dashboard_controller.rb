class DashboardController < ApplicationController
  def index
  end

  def template
    set_template_parameters
    render template_name, layout: false
  end

  private
  def template_name
    parts = params[:name].split('/')
    "/#{parts[0..-2].join('/')}/_#{parts.last}"
  end

  def set_template_parameters
    @template_params = request.query_parameters.symbolize_keys
  end
end
