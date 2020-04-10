defmodule PhilomenaWeb.CaptchaDataProviderPlug do
  import Plug.Conn, only: [assign: 3]
  alias Philomena.Captcha

  def init([]), do: false

  def call(conn, _opts) do
    IO.puts(Captcha.get_captcha_site_key())
    conn
    |> assign(:captcha_site_key, Captcha.get_captcha_site_key())
  end
end
