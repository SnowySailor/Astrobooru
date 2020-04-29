defmodule Philomena.Paypal.CreateOrder do
  defstruct [:id, :intent, :purchase_units]
end
