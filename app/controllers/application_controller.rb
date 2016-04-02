class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  include Authenticable

  # Defines default serializer options for active model serializers
  def default_serializer_options
    { root: false }
  end

  # Checks if user from params is equal to current_user
  def user_matches?
    unless current_user == User.find_by(id: params[:user_id])
      render json: { errors: 'Url mismatch' }, status: 400
    end
  end
end
