defmodule Philomena.Paypal.CreateProduct do
  defstruct [
    :id,
    :name,
    :description,
    :type,
    :category,
    :image_url,
    :home_url,
    :links,
    :create_time,
    :update_time
  ]
end
