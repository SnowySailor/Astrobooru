defmodule PhilomenaWeb.PaypalHookController do
  use PhilomenaWeb, :controller
  require Logger
  alias Philomena.Paypal.HookHandlers.BillingSubscription

  def create(conn, params) do
    _ =
      get_resource_type(params)
      |> handle_by_resource_type(params)
      |> log()

    conn
    |> text("")
  end

  defp get_resource_type(event) do
    case event do
      %{"resource_type" => "subscription"} -> "subscription"
      %{"resource" => %{"billing_agreement_id" => _id}} -> "subscription"
      %{"resource_type" => "sale"} -> "sale"
      _ -> "unknown"      
    end
  end

  defp handle_by_resource_type("subscription", %{"event_type" => type} = event) do
    case type do
      "BILLING.SUBSCRIPTION.ACTIVATED" ->
        BillingSubscription.activated(event)
      "PAYMENT.SALE.COMPLETED" ->
        BillingSubscription.sale_completed(event)
      "PAYMENT.SALE.REVERSED" ->
        BillingSubscription.sale_reversed(event)
      "PAYMENT.SALE.REFUNDED" ->
        BillingSubscription.sale_refunded(event)
      _ ->
        {:info, "got event without handled type (#{type}): #{inspect(event)}"}
    end
  end

  defp handle_by_resource_type("sale", %{"event_type" => type} = event) do
    nil
  end

  defp handle_by_resource_type(type, _event),
    do: {:info, "unhandled resource type: #{type}"}

  defp log({:error, message}),
    do: Logger.error(message)

  defp log({:debug, message}),
    do: Logger.debug(message)

  defp log({:warn, message}),
    do: Logger.warn(message)

  defp log({:info, message}),
    do: Logger.info(message)

  defp log(_),
    do: nil
end