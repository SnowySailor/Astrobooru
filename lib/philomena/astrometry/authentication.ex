defmodule Philomena.Astrometry.Authentication do
  alias Philomena.Astrometry.Request

  def get_session() do
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]
    Request.post!("login", build_auth_body(), headers, [recv_timeout: 15000])
    |> Map.get(:session)
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