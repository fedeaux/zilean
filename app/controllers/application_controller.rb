class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  around_action :set_timezone

  def set_timezone
    if current_user
      Time.use_zone(current_user.timezone) {
        yield
      }
    else
      yield
    end
  end
end
