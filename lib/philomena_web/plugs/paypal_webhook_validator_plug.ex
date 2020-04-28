defmodule PhilomenaWeb.PaypalWebhookValidatorPlug do
  alias Philomena.Paypal.API
  import Plug.Conn
  import Phoenix.Controller
  import PhilomenaWeb.CacheBodyReader

  def init([]), do: false

  def call(conn, _opts) do
    conn
    |> extract_webhook_signature(conn.params)
    |> API.webhook_signature_valid?()
    |> case do
      true ->
        conn

      false ->
        conn
        |> put_status(:unauthorized)
        |> text("")
        |> halt()
    end
  end

  defp extract_webhook_signature(conn, params) do
    """
    {
      "auth_algo": "#{get_req_header(conn, "paypal-auth-algo") |> Enum.at(0, "")}",
      "cert_url": "#{get_req_header(conn, "paypal-cert-url") |> Enum.at(0, "")}",
      "transmission_id": "#{get_req_header(conn, "paypal-transmission-id") |> Enum.at(0, "")}",
      "transmission_sig": "#{get_req_header(conn, "paypal-transmission-sig") |> Enum.at(0, "")}",
      "transmission_time": "#{get_req_header(conn, "paypal-transmission-time") |> Enum.at(0, "")}",
      "webhook_id": "#{get_webhook_id()}",
      "webhook_event": #{read_cached_body(conn)}
    }
    """
  end

  defp get_webhook_id() do
    Application.get_env(:philomena, :paypal_webhook_id)
  end
end
