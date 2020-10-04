defmodule Philomena.Astrometry.API do
  require Logger
  alias Logger
  alias Philomena.Astrometry.Request
  alias Philomena.Astrometry.Authentication

  @request_delay 30_000
  @retry_timeout 1_800

  def get_tags(url) do
    submit_url(url)
    |> wait_for_jobid()
    |> wait_for_solve()
    |> get_machine_tags()
  end

  defp submit_url(url) when is_binary(url) do
    submit_url(url, DateTime.utc_now())
  end

  defp submit_url(url, time) when is_binary(url) do
    case expired?(time) do
      true ->
        raise("could not submit url within #{@retry_timeout} seconds")

      false ->
        body = build_url_submit_body(url)

        case Request.post("url_upload", body, [
               {"Content-Type", "application/x-www-form-urlencoded"}
             ]) do
          {:ok, data} ->
            Map.get(data, :subid)

          error ->
            Logger.warn("submit_url exception: #{inspect(error)}")
            :timer.sleep(@request_delay)
            submit_url(url, time)
        end
    end
  end

  defp build_url_submit_body(path) do
    URI.encode_query(%{
      "request-json":
        Jason.encode!(%{
          publicly_visible: "n",
          allow_modifications: "n",
          allow_commercial_use: "n",
          session: Authentication.get_session(),
          url: Path.join(get_site_url(), path)
        })
    })
  end

  defp wait_for_jobid(subid) when is_integer(subid) do
    wait_for_jobid(subid, DateTime.utc_now())
  end

  defp wait_for_jobid(subid, time) when is_integer(subid) do
    case expired?(time) do
      true ->
        raise(
          "submission #{subid} was not assigned jobid within #{@retry_timeout} seconds"
        )

      false ->
        case Request.get("submissions/#{subid}/") do
          {:ok, body} ->
            case body do
              %{jobs: [nil]} ->
                :timer.sleep(@request_delay)
                wait_for_jobid(subid, time)

              %{jobs: []} ->
                :timer.sleep(@request_delay)
                wait_for_jobid(subid, time)

              %{jobs: [jobid | _rest]} ->
                jobid
            end

          error ->
            Logger.warn("wait_for_jobid exception: #{inspect(error)}")
            :timer.sleep(@request_delay)
            wait_for_jobid(subid, time)
        end
    end
  end

  defp wait_for_solve(jobid) when is_integer(jobid) do
    wait_for_solve(jobid, DateTime.utc_now())
  end

  defp wait_for_solve(jobid, time) when is_integer(jobid) do
    case expired?(time) do
      true ->
        raise("job #{jobid} did not complete within #{@retry_timeout / 1000} seconds")

      false ->
        case Request.get("jobs/#{jobid}") do
          {:ok, body} ->
            case body do
              %{status: "success"} ->
                jobid

              %{status: "failure"} ->
                raise("failed to solve job #{jobid}")

              %{status: "solving"} ->
                :timer.sleep(@request_delay)
                wait_for_solve(jobid, time)

              status ->
                Logger.warn("wait_for_solve got unknown status: #{inspect(status)}")
                :timer.sleep(@request_delay)
                wait_for_solve(jobid, time)
            end

          error ->
            Logger.warn("wait_for_solve exception: #{inspect(error)}")
            :timer.sleep(@request_delay)
            wait_for_solve(jobid, time)
        end
    end
  end

  defp get_machine_tags(jobid) when is_integer(jobid) do
    get_machine_tags(jobid, DateTime.utc_now())
  end

  defp get_machine_tags(jobid, time) when is_integer(jobid) do
    case expired?(time) do
      true ->
        raise("could not get machine tags within #{@retry_timeout / 1000} seconds")

      false ->
        case Request.get("jobs/#{jobid}/machine_tags") do
          {:ok, data} ->
            Map.get(data, :tags)

          error ->
            Logger.warn("get_machine_tags exception: #{inspect(error)}")
            :timer.sleep(@request_delay)
            get_machine_tags(jobid, time)
        end
    end
  end

  defp get_site_url() do
    Application.get_env(:philomena, :site_url)
  end

  defp expired?(time) do
    DateTime.diff(DateTime.utc_now(), time) > @retry_timeout
  end
end
