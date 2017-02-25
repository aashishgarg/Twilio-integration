class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # ============== Before filters ================= #
  before_action :current_user

  def current_user
    authenticate_or_request_with_http_token do |token, options|
      User.find_by_id(CacheManagement.instance.get_value(token))
    end
  end
end
