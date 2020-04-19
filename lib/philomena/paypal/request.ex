defmodule Philomena.Paypal.Request do
  require HTTPoison.Retry
  alias HTTPoison.Retry
  alias Philomena.Paypal.Authentication

  def get(endpoint, headers \\ []) do
    headers = add_paypal_headers(headers)

    get_paypal_api_base_url()
    |> URI.merge(endpoint)
    |> HTTPoison.get!(headers)
    |> Retry.autoretry(max_attempts: 1, wait: 0)
    |> parse_response()
  end

  def post(endpoint, body, headers \\ []) do
    headers = add_paypal_headers(headers)

    get_paypal_api_base_url()
    |> URI.merge(endpoint)
    |> HTTPoison.post!(body, headers)
    |> Retry.autoretry(max_attempts: 1, wait: 0)
    |> parse_response()
  end

  defp parse_response(%HTTPoison.Response{status_code: 201, body: body}),
    do: Jason.decode!(body, keys: :atoms)

  defp parse_response(%HTTPoison.Response{status_code: 200, body: body}),
    do: Jason.decode!(body, keys: :atoms)

  defp wipe_token_if_unauthorized(%HTTPoison.Response{status_code: 401} = resp) do
    Authentication.flush_token_cache()

    %HTTPoison.Response{
      resp
      | request: %HTTPoison.Request{
          resp.request
          | headers: add_paypal_headers(resp.request.headers)
        }
    }
  end

  defp wipe_token_if_unauthorized(resp),
    do: resp

  defp add_paypal_headers(headers) do
    Map.new(headers, fn x -> x end)
    |> Map.put("Content-Type", "application/json")
    |> Map.put("Authorization", "Basic " <> Authentication.create_auth())
    |> Map.to_list()
  end

  defp get_paypal_api_base_url(),
    do: Application.get_env(:philomena, :paypal_api_base_url)

  defp get_paypal_client_id(),
    do: Application.get_env(:philomena, :paypal_client_id)

  defp get_paypal_client_secret(),
    do: Application.get_env(:philomena, :paypal_client_secret)
end
