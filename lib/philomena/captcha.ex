defmodule Philomena.Captcha do
  def valid_solution?(response_token) when is_binary(response_token) do
    response_token
    |> get_hcaptcha_response_body()
    |> validate_body?()
  end

  def valid_solution?(%{"h-captcha-response" => response_token}) do
    valid_solution?(response_token)
  end

  def valid_solution?(_params),
    do: false

  def get_captcha_site_key do
    Application.get_env(:philomena, :captcha_site_key)
  end

  def get_captcha_secret_key do
    Application.get_env(:philomena, :captcha_secret_key)
  end

  defp get_hcaptcha_response_body(response_token) do
    request_body = URI.encode_query(%{secret: get_captcha_secret_key(), response: response_token})

    resp =
      HTTPoison.post("https://hcaptcha.com/siteverify", request_body, %{
        "Content-Type" => "application/x-www-form-urlencoded"
      })

    case resp do
      {:ok, %HTTPoison.Response{body: raw_body, status_code: 200}} -> raw_body
      _ -> ""
    end
  end

  defp validate_body?(raw_body) do
    case Jason.decode(raw_body, keys: :atoms) do
      {:ok, %{success: success}} -> success
      _ -> false
    end
  end
end
