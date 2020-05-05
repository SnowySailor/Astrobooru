defmodule PhilomenaWeb.PremiumSubscriptionPlug do
  import Plug.Conn
  import Phoenix.Controller
  alias Philomena.Users.User
  alias PhilomenaWeb.Router.Helpers, as: Routes

  def init([]), do: false

  def call(conn, _opts) do
    case User.premium?(conn.assigns.current_user) do
      true ->
        conn
      false ->
        conn
        |> put_flash(:error, "You need Astrobooru Premium to access that page")
        |> redirect(to: Routes.premium_subscription_path(conn, :index))
        |> halt()
    end
  end
end