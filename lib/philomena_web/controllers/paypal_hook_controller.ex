defmodule PhilomenaWeb.PaypalHookController do
  use PhilomenaWeb, :controller

  require Logger
  import Philomena.Paypal.Hooks.BillingSubscription

  def create(conn, params) do
    _ = handle_webhook(conn, params)

    conn
    |> text("")
  end

  defp handle_webhook(conn, %{event_type: type} = event) do
    case type do
      "BILLING.SUBSCRIPTION.ACTIVATED" ->
        handle_billing_subscription_activated(conn, event)
      _ ->
        Logger.info("got event without handled type (#{type}): #{inspect(event)}")
    end
  end

  defp handle_webhook(_conn, event),
    do: Logger.debug("got event without event_type: #{inspect(event)}")
end