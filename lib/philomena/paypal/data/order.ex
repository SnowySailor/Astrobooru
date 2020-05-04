defmodule Philomena.Paypal.Order do
  defstruct [
    :product_id,
    :name,
    :description,
    :status,
    :billing_cycles,
    :payment_preferences,
    :taxes
  ]
end