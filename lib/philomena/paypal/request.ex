defmodule Philomena.Paypal.Request do
  require HTTPoison.Retry
  alias HTTPoison.Retry
  alias Philomena.Paypal.Authentication

  def get(endpoint, headers \\ []) do
    headers = add_paypal_headers(headers)

    get_paypal_api_base_url()
    |> Path.join(endpoint)
    |> HTTPoison.get(headers)
    |> Retry.autoretry(max_attempts: 1, wait: 0)
    |> parse_response()
  end

  def post(endpoint, body, headers \\ []) do
    headers = add_paypal_headers(headers)

    get_paypal_api_base_url()
    |> Path.join(endpoint)
    |> HTTPoison.post(body, headers)
    |> Retry.autoretry(max_attempts: 1, wait: 0)
    |> parse_response()
  end

  def get!(endpoint, headers \\ []) do
    headers = add_paypal_headers(headers)

    get_paypal_api_base_url()
    |> URI.merge(endpoint)
    |> HTTPoison.get!(headers)
    |> Retry.autoretry(max_attempts: 1, wait: 0)
    |> parse_response!()
  end

  def post!(endpoint, body, headers \\ []) do
    headers = add_paypal_headers(headers)

    get_paypal_api_base_url()
    |> URI.merge(endpoint)
    |> HTTPoison.post!(body, headers)
    |> Retry.autoretry(max_attempts: 1, wait: 0)
    |> parse_response!()
  end

  defp parse_response!({:ok, %HTTPoison.Response{status_code: status_code, body: body} = response}) do
    case status_code do
      n when n in [200, 201] ->
        Jason.decode!(body, keys: :atoms)
      n when n in [204] ->
        %{}
      _ ->
        {:error, response}
    end
  end

  defp parse_response({:ok, %HTTPoison.Response{status_code: status_code, body: body} = response}) do
    case status_code do
      n when n in [200, 201] ->
        case Jason.decode(body, keys: :atoms) do
          {:ok, data} -> {:ok, data}
          _ -> {:parse_error, %{}}
        end
      n when n in [204] ->
        {:ok, %{}}
      _ ->
        {:error, response}
    end
  end

  defp parse_response({_, response}),
    do: {:request_failure, response}

  defp add_paypal_headers(headers) do
    Map.new(headers, fn x -> x end)
    |> Map.put("Content-Type", "application/json")
    |> Map.put("Authorization", "Basic " <> Authentication.create_auth())
    |> Map.to_list()
  end

  defp get_paypal_api_base_url(),
    do: Application.get_env(:philomena, :paypal_api_base_url)
end
