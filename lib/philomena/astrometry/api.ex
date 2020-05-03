defmodule Philomena.Astrometry.API do
  require Logger
  alias Logger
  alias Philomena.Astrometry.Request
  alias Philomena.Astrometry.Authentication

  @request_delay 5_000

  def get_tags(url) do
    body = build_url_submit_body(url)
    Logger.info("requesting: #{body}")
    Request.post!("url_upload", body, [{"Content-Type", "application/x-www-form-urlencoded"}])
    |> Map.get(:subid)
    |> wait_for_jobid()
    |> wait_for_solve()
    |> get_machine_tags()
  end

  defp build_url_submit_body(path) do
    URI.encode_query(%{
      "request-json": Jason.encode!(%{
        publicly_visible: "y",
        allow_modifications: "n",
        allow_commercial_use: "n",
        session: Authentication.get_session(),
        url: Path.join(get_site_url(), path)
      })
    })
  end

  defp wait_for_jobid(subid) do
    Logger.info("got subid #{subid}")
    wait_for_jobid(subid, DateTime.utc_now())
  end

  defp wait_for_jobid(subid, time) do
    case DateTime.diff(DateTime.utc_now(), time) < 1800 do
      true ->
        Request.get("submissions/#{subid}/")
        |>
          case do
            {:ok, body} ->
              case body do
                %{jobs: [nil]} ->
                  Logger.info("sleeping for a second, got nil")
                  :timer.sleep(@request_delay)
                  wait_for_jobid(subid, time)
                %{jobs: []} ->
                  Logger.info("sleeping for a second got []")
                  :timer.sleep(@request_delay)
                  wait_for_jobid(subid, time)
                %{jobs: [jobid | _rest]} ->
                  Logger.info("got jobid #{jobid}")
                  jobid
              end
            error ->
              Logger.error("#{inspect(error)}")
              :timer.sleep(@request_delay)
              wait_for_jobid(subid, time)
          end
      false ->
        {:error, "submission #{subid} was not assigned jobid within 30 minutes"}
    end
  end

  defp wait_for_solve(jobid) do
    wait_for_solve(jobid, DateTime.utc_now())
  end

  defp wait_for_solve(jobid, time) do
    case DateTime.diff(DateTime.utc_now(), time) < 1200 do
      true ->
        Request.get("jobs/#{jobid}")
        |>
          case do
            {:ok, body} ->
              case body do
                %{status: "success"} ->
                  Logger.info("got success")
                  jobid
                %{status: "failure"} ->
                  Logger.info("got failure")
                  {:error, "failed to solve"}
                status ->
                  Logger.info("sleeping for a second, got #{inspect(status)}")
                  :timer.sleep(@request_delay)
                  wait_for_solve(jobid, time)
              end
            error ->
              Logger.error("#{inspect(error)}")
              :timer.sleep(@request_delay)
              wait_for_solve(jobid, time)
          end
      false ->
        {:error, "job #{jobid} did not complete within 20 minutes"}
    end
  end

  defp get_machine_tags(jobid) when is_integer(jobid) do
    Logger.info("getting tags")
    Request.get!("jobs/#{jobid}/machine_tags")
    |> Map.get(:tags)
  end

  defp get_site_url() do
    Application.get_env(:philomena, :site_url)
  end
end