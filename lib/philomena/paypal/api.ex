defmodule Philomena.Paypal.API do
  alias Philomena.Paypal.Request

  def get_subscription_options() do
  end

  def get_products() do
  end

  def create_subscription(subscription) do
    body = Jason.encode!(subscription)
    Request.post("/v1/billing/subscriptions", body)
  end

  def create_order(order) do
    body = Jason.encode!(order)
    Request.post("/v2/checkout/orders", body)
  end

  def create_product(product) do
    body = Jason.encode!(product)
    Request.post("/v1/catalogs/products", body)
  end

  def delete_product(product_id) do
  end

  def update_product(product) do
  end
end
