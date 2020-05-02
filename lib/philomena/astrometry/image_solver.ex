defmodule Philomena.Astrometry.ImageSolver do
  require Logger
  alias Logger
  alias Philomena.Astrometry.Request

  def get_tags(url) do
    body = build_url_submit_body(url)
    Request.post!("url_upload", body, [], [recv_timeout: 15000])
    |> Map.get(:subid)
    |> wait_for_jobid()
    |> wait_for_solve()
    |> get_machine_tags()
  end

  defp build_url_submit_body(path) do
    URI.encode_query(%{
      "request-json": Jason.encode!(%{
        publicly_visible: "n",
        allow_modifications: "n",
        allow_commercial_use: "n",
        session: Authentication.get_session(),
        url: path
      })
    })
  end

  defp wait_for_jobid(subid) do
    Request.get!("submissions/#{subid}/", [], [recv_timeout: 15000])
    |>
      case do
        %{jobs: [nil]} ->
          :timer.sleep(3000)
          wait_for_jobid(subid)
        %{jobs: []} ->
          :timer.sleep(3000)
          wait_for_jobid(subid)
        %{jobs: [jobid | _rest]} ->
          jobid
      end
  end

  defp wait_for_solve(jobid) do
    wait_for_solve(jobid, DateTime.utc_now())
  end

  defp wait_for_solve(jobid, time) do
    case DateTime.diff(DateTime.utc_now(), time) < 600 do
      true ->
        Request.get!("jobs/#{jobid}")
        |> 
          case do
            %{status: "success"} ->
              jobid
            %{status: "failure"} ->
              {:error, "failed to solve"}
            _ ->
              wait_for_solve(jobid)
          end
      false ->
        {:error, "job #{jobid} did not complete within 10 minutes"}
    end
  end

  defp get_machine_tags(jobid) do
    Request.get!("jobs/#{jobid}/machine_tags", [], [recv_timeout: 15000])
    |> Map.get(:tags)
  end
end