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

    case expired?(time) do
      true ->
        raise("could not get session within #{@retry_timeout / 1000} seconds")

      false ->
        case Request.post("login", build_auth_body(), headers) do
          {:ok, data} ->
            Map.get(data, :session)

          error ->
            Logger.warn("get_session exception: #{inspect(error)}")
            :timer.sleep(@request_delay)
            get_session(time)
        end
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

  defp expired?(time) do
    DateTime.diff(DateTime.utc_now(), time) > @retry_timeout
  end
end
