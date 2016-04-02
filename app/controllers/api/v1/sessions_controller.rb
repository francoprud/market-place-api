class Api::V1::SessionsController < ApplicationController
  def create
    user = User.find_by(email: email)
    if user && user.valid_password?(password)
      user.generate_authentication_token!
      user.save
      render json: user, status: 200, location: [:api, user], root: false
    else
      render json: { errors: 'Invalid email or password' }, status: 422
    end
  end

  def destroy
    user = User.find_by(auth_token: params[:id])
    if user
      user.generate_authentication_token!
      user.save
    end
    head 204
  end

  private

  def email
    params[:session][:email]
  end

  def password
    params[:session][:password]
  end
end
