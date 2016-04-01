class ProductQuery
  attr_reader :query_params, :products

  def initialize(query_params = {}, products = Product.all)
    @query_params = query_params
    @products = products
  end

  def search
    product_ids(query_params[:product_ids]) if query_params[:product_ids].present?
    keyword(query_params[:keyword]) if query_params[:keyword].present?
    min_price(query_params[:min_price].to_f) if query_params[:min_price].present?
    max_price(query_params[:max_price].to_f) if query_params[:max_price].present?
    products.order(:updated_at)
  end

  private

  def product_ids(product_ids)
    @products = products.where(id: query_params[:product_ids])
  end

  def keyword(title_keyword)
    @products = products.where('title ILIKE ?', "%#{title_keyword}%")
  end

  def min_price(price)
    @products = products.where('price >= ?', price)
  end

  def max_price(price)
    @products = products.where('price <= ?', price)
  end
end
