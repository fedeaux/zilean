class DashboardController < ApplicationController
  skip_before_action :authenticate_user!, only: [:digest]

  def index
  end

  def digest
    @digest = []

    User.all.each do |user|
      @digest << {
        user: user,
        activities: user.activities,
        log_entries: user.log_entries
      }
    end

    render json: @digest
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
