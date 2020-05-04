defmodule Philomena.Astrometry.Request do
  require HTTPoison.Retry
  alias HTTPoison.Retry
  require Logger
  alias Logger

  @default_opts [timeout: 300_000, recv_timeout: 300_000]

  def get(endpoint, headers \\ [], opts \\ @default_opts) do
    get_astrometry_api_base_url()
    |> Path.join(endpoint)
    |> HTTPoison.get(headers, opts)
    |> Retry.autoretry(max_attempts: 1, wait: 0)
    |> parse_response()
  end

  def post(endpoint, body, headers \\ [], opts \\ @default_opts) do
    get_astrometry_api_base_url()
    |> Path.join(endpoint)
    |> HTTPoison.post(body, headers, opts)
    |> Retry.autoretry(max_attempts: 1, wait: 0)
    |> parse_response()
  end

  def get!(endpoint, headers \\ [], opts \\ @default_opts) do
    get_astrometry_api_base_url()
    |> URI.merge(endpoint)
    |> HTTPoison.get!(headers, opts)
    |> Retry.autoretry(max_attempts: 1, wait: 0)
    |> parse_response!()
  end

  def post!(endpoint, body, headers \\ [], opts \\ @default_opts) do
    get_astrometry_api_base_url()
    |> URI.merge(endpoint)
    |> HTTPoison.post!(body, headers, opts)
    |> Retry.autoretry(max_attempts: 1, wait: 0)
    |> parse_response!()
  end

  defp parse_response!(%HTTPoison.Response{status_code: status_code, body: body} = response) do
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

  defp get_astrometry_api_base_url(),
    do: Application.get_env(:philomena, :astrometry_api_base_url)
end
