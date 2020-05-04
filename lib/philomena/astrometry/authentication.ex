defmodule Philomena.Astrometry.Authentication do
  alias Philomena.Astrometry.Request
  require Logger
  alias Logger

  @retry_timeout 6_000
  @request_delay 5_000

  def get_session() do
    get_session(DateTime.utc_now())
  end

  def get_session(time) do
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    case DateTime.diff(DateTime.utc_now(), time) < @retry_timeout do
      true ->
        case Request.post("login", build_auth_body(), headers) do
          {:ok, data} ->
            Map.get(data, :session)

          error ->
            Logger.error("get_session error: #{inspect(error)}")
            :timer.sleep(@request_delay)
            get_session(time)
        end

      false ->
        {:error, "could not get session within #{@retry_timeout / 1000} seconds"}
    end
  end

  defp build_auth_body() do
    URI.encode_query(%{
      "request-json":
        Jason.encode!(%{
          apikey: get_astrometry_api_key()
        })
    })
  end

  defp get_astrometry_api_key() do
    Application.get_env(:philomena, :astrometry_api_key)
  end
end
