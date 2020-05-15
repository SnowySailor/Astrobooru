defmodule Philomena.Backblaze.Authentication do
  use Retry

  def get_auth!() do
    retry with: constant_backoff(1_000) |> Stream.take(5), rescue_only: [KeyError] do
      headers = %{"Authorization": "Basic " <> create_auth()}
      HTTPoison.get!("https://api.backblazeb2.com/b2api/v2/b2_authorize_account", headers)
      |> Map.get(:body)
      |> Jason.decode!(keys: :atoms)
    after
      response ->
        response
    else
      error ->
        raise error
    end
  end

  def create_auth() do
    (get_backblaze_key_id() <> ":" <> get_backblaze_key())
    |> Base.encode64()
  end

  defp get_backblaze_key_id(),
    do: Application.get_env(:philomena, :backblaze_key_id)

  defp get_backblaze_key(),
    do: Application.get_env(:philomena, :backblaze_key)
end
