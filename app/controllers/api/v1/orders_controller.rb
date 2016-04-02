class Api::V1::OrdersController < ApplicationController
  before_action :user_matches?, only: [:show, :create]

  PER_PAGE_DEFAULT = 25

  def index
    orders = current_user.orders.page(params[:page]).per(params[:per_page])
    render json: orders, meta: pagination(orders, params[:per_page] || PER_PAGE_DEFAULT)
  end

  def show
    order = current_user.orders.find_by(id: params[:id])
    if order
      render json: order, root: false
    else
      render json: { errors: 'order not found or user not owner' }, status: 404
    end
  end

  def create
    order = current_user.orders.build
    order.build_placements_with_product_ids_and_quantities(params[:order][:product_ids_and_quantities])
    if order.save
      order.reload
      OrderMailer.send_confirmation(order).deliver_now
      render json: order, status: 201, location: [:api, current_user, order], root: false
    else
      render json: { errors: order.errors }, status: 422
    end
  end
end
