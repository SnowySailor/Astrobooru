defmodule Philomena.Backblaze.API do
  alias Philomena.Backblaze.Requests
  alias Philomena.Backblaze.Authentication

  def upload_file!(path, name, headers \\ %{}) do
    auth = Authentication.get_auth!()
    upload_url_resp = get_upload_url!(auth)
    sha1 =
      File.read!(path)
      |> (&(:crypto.hash(:sha, &1))).()
      |> Base.encode16()

    headers = Map.merge(headers, %{
      "Content-Type": "b2/x-auto",
      "Content-Length": File.stat!(path).size,
      "X-Bz-File-Name": encode_file_name(name),
      "X-Bz-Content-Sha1": sha1,
      "Authorization": upload_url_resp.authorizationToken
    })
    Requests.post_raw!(upload_url_resp.uploadUrl, {:file, path}, auth, headers)
  end

  def get_upload_url!(auth \\ nil) do
    auth = auth || Authentication.get_auth!()
    data = Jason.encode!(%{
      bucketId: auth.allowed.bucketId
    })
    Requests.post!("b2_get_upload_url", data, auth)
  end

  def encode_file_name(name) do
    URI.encode_www_form(name) |> String.replace("%2F", "/")
  end
end