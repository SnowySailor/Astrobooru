defmodule PhilomenaWeb.PremiumSubscription.PaypalReturnController do
  use PhilomenaWeb, :controller
  import Philomena.Paypal.HookHandlers.BillingSubscription
  alias Philomena.Paypal.API

  def index(conn, %{"subscription_id" => id}) do
    API.get_subscription(id)
    |> get_start_time()
    |> case do
      {:ok, time, 0} ->
        activated(id, time)

      _ ->
        {:error, nil}
    end
    |> case do
      {:error, _message} ->
        conn
        |> put_flash(:error, "Error activating your subscription; please contact us for support")

      _ ->
        conn
        |> put_flash(:info, "Subscription successfully activated")
    end
    |> redirect(external: Routes.activity_path(conn, :index))
  end

  defp get_start_time({:ok, %{start_time: time, status: "ACTIVE"}}) do
    DateTime.from_iso8601(time)
  end

  defp get_start_time(_data),
    do: nil
end
