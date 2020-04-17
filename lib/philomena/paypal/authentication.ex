defmodule Philomena.Paypal.Authentication do
  @token_key "paypal_authorization"

  def get_token() do
    case Redix.command(:redix, ["GET", @token_key]) do
      {:ok, nil} -> request_new_authorization()
      {:ok, token} -> Branca.decode!(token)
    end
  end

  def request_new_authorization() do
    case get_new_authorization() do
      {token, expiry} -> set_token(token, expiry)
    end
  end

  def set_token(token, expiry) do
    with {:ok, _ok} <- Redix.command(:redix, ["SET", @token_key, Branca.encode!(token)]),
         {:ok, _ok} <- Redix.command(:redix, ["EXPIRE", @token_key, expiry - 300]) do
      token
    end
  end

  def get_new_authorization() do
    headers = [{"Authorization", "Basic " <> create_auth()}]
    resp = HTTPoison.post(
      get_paypal_api_base_url() <> "oauth2/token",
      "grant_type=client_credentials",
      headers
    )

    case resp do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} -> parse_response(body)
    end
  end

  def create_auth() do
    get_paypal_client_id() <> ":" <> get_paypal_client_secret()
    |> Base.encode64()
  end

  def parse_response(body) do
    case Jason.decode(body, keys: :atoms) do
      {:ok, %{access_token: token, expires_in: expiry}} -> {token, expiry}
    end
  end

  def flush_token_cache() do
    Redix.command!(:redix, ["DEL", @token_key])
  end

  defp get_paypal_client_id(),
    do: Application.get_env(:philomena, :paypal_client_id)

  defp get_paypal_client_secret(),
    do: Application.get_env(:philomena, :paypal_client_secret)

  defp get_paypal_api_base_url(),
    do: Application.get_env(:philomena, :paypal_api_base_url)
end
