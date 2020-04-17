defmodule Philomena.Paypal.API do
  require HTTPoison.Retry
  alias HTTPoison.Retry
  alias Philomena.Paypal.Authentication

  def get_subscription_options() do

  end

  def get_products() do
    
  end

  def create_product(product) do
    
  end

  def delete_product(product_id) do
    
  end

  def update_product(product) do
    
  end

  defp get(endpoint, headers \\ []) do
    headers = add_paypal_headers(headers)

    get_paypal_api_base_url()
    |> URI.merge(endpoint)
    |> HTTPoison.get!(headers)
    |> wipe_token_if_unauthorized()
    |> Retry.autoretry(max_attempts: 1, wait: 0)
    |> parse_response()
  end

  defp post(endpoint, body, headers \\ []) do
    headers = add_paypal_headers(headers)

    get_paypal_api_base_url()
    |> URI.merge(endpoint)
    |> HTTPoison.post!(body, headers)
    |> wipe_token_if_unauthorized()
    |> Retry.autoretry(max_attempts: 1, wait: 0)
    |> parse_response()
  end

  defp parse_response(%HTTPoison.Response{status_code: 200, body: body}) do
    Jason.decode!(body, keys: :atoms)
  end

  defp wipe_token_if_unauthorized(%HTTPoison.Response{status_code: 401} = resp) do
    Authentication.flush_token_cache()
    %HTTPoison.Response {
      resp |
      request: %HTTPoison.Request {
        resp.request |
        headers: add_paypal_headers(resp.request.headers)
      }
    }
  end

  defp wipe_token_if_unauthorized(resp),
    do: resp

  defp add_paypal_headers(headers) do
    Map.new(headers, fn x -> x end)
    |> Map.put("Content-Type", "application/json")
    |> Map.put("Authorization", "Bearer " <> Authentication.get_token())
    |> Map.to_list()
  end

  defp get_paypal_api_base_url(),
    do: Application.get_env(:philomena, :paypal_api_base_url)
end