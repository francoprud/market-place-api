class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  include Authenticable

  protected

  # Checks if user from params is equal to current_user
  def user_matches?
    unless current_user == User.find_by(id: params[:user_id])
      render json: { errors: 'Url mismatch' }, status: 400
    end
  end

  def pagination(paginated_array, per_page)
    {
      pagination: {
        per_page: params[:per_page],
        total_pages: paginated_array.total_pages,
        total_objects: paginated_array.total_count
      }
    }
  end
end
