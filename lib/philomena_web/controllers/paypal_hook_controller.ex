defmodule PhilomenaWeb.PaypalHookController do
  use PhilomenaWeb, :controller

  def create(conn, params) do
    _ = handle_webhook(conn, params)

    conn
    |> text("")
  end

  defp handle_webhook(conn, event) do
    IO.puts("gottem")
  end
end