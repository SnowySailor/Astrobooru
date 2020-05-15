defmodule Philomena.Backblaze.Requests do
  use Retry
  require Logger

  def get_raw!(endpoint, auth, headers \\ %{}) do    
    headers = add_backblaze_headers(headers, auth)

    retry with: constant_backoff(1_000) |> Stream.take(5), rescue_only: [HTTPoison.Error, CaseClauseError] do
      endpoint
      |> HTTPoison.get!(headers)
      |> parse_response!()
    after
      resp ->
        resp
    else
      err ->
        raise err
    end
  end

  def get!(endpoint, auth, headers \\ %{}) do
    url =
      auth.apiUrl
      |> Path.join("/b2api/v2/")
      |> Path.join(endpoint)
    get_raw!(url, auth, headers)
  end

  def post_raw!(endpoint, body, auth, headers \\ %{}) do
    headers = add_backblaze_headers(headers, auth)

    retry with: constant_backoff(1_000) |> Stream.take(5), rescue_only: [HTTPoison.Error, CaseClauseError] do
      endpoint
      |> HTTPoison.post!(body, headers)
      |> parse_response!()
    after
      resp ->
        resp
    else
      err ->
        raise err
    end
  end

  def post!(endpoint, body, auth, headers \\ %{}) do
    url =
      auth.apiUrl
      |> Path.join("/b2api/v2/")
      |> Path.join(endpoint)
    post_raw!(url, body, auth, headers)
  end

  defp parse_response!(
        %HTTPoison.Response{status_code: status_code, body: body} = response
      ) do
    IO.inspect(response)
    case status_code do
      n when n in [200, 201] ->
        Jason.decode!(body, keys: :atoms)

      n when n in [202, 204] ->
        %{}

      _ ->
        Logger.error(inspect(response))
        raise CaseClauseError, [status_code]
    end
  end

  defp add_backblaze_headers(headers, auth) do
    Map.new()
    |> Map.put("Authorization", auth.authorizationToken)
    |> Map.merge(headers)
    |> Map.to_list()
  end
end
