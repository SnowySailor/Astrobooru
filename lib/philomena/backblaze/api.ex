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
      "X-Bz-File-Name": URI.encode(name),
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

  # def encode_file_name(name) do
  #   safe = Enum.to_list(39..43) ++ Enum.to_list(45..59) ++ Enum.to_list(64..90) ++ Enum.to_list(97..122) ++ [126, 95, 33, 61]
  #   :binary.bin_to_list(name)
  #   |> Enum.map(fn c ->
  #     case c do
  #       c when c in safe ->
  #         c
  #       c ->
  #         "%" + Integer.to_string(c)
  #     end
  #   end)
  #   |> IO.puts()
  # end
end