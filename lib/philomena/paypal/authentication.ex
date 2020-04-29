defmodule Philomena.Paypal.Authentication do
  def create_auth() do
    (get_paypal_client_id() <> ":" <> get_paypal_client_secret())
    |> Base.encode64()
  end

  defp get_paypal_client_id(),
    do: Application.get_env(:philomena, :paypal_client_id)

  defp get_paypal_client_secret(),
    do: Application.get_env(:philomena, :paypal_client_secret)
end
