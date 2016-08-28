class DashboardController < ApplicationController
  def index
  end

  def template
    render template_name, layout: false
  end

  private
  def template_name
    parts = params[:name].split('/')
    "#{parts[0..-2].join('/')}/_#{parts.last}"
  end
end
