defmodule Philomena.Paypal.CreateSubscription do
  defstruct [
    :plan_id,
    :start_tmie,
    :quantity,
    :shipping_amount,
    :subscriber,
    :application_context
  ]
end
