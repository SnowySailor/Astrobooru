defmodule PhilomenaWeb.PremiumSubscription.CancelController do
  use PhilomenaWeb, :controller
  alias Philomena.Users.User
  alias Philomena.PremiumSubscription.Subscription
  
  def index(conn, _params) do
    case User.can_cancel_premium_subscription?(conn.assigns.current_user) do
      true ->
        render(conn, "index.html")
      false ->
        conn
        |> put_flash(:warning, "You don't currently have a premium subscription")
        |> redirect(external: Routes.activity_path(conn, :index))
    end
  end

  def create(conn, %{"reason" => reason, "reason_text" => reason_text}) do
    user = conn.assigns.current_user
    case User.can_cancel_premium_subscription?(conn.assigns.current_user) do
      true ->
        case Subscription.cancel_subscriptions(user, reason <> ": " <> reason_text) do
          true ->
            conn
            |> put_flash(:info, "Successfully cancelled your subscription payments; your premium account will remain active until the end of the billing period")
          false ->
            conn
            |> put_flash(:error, "There was an issue cancelling your subscription; please contact us to confirm that you will no longer be billed")
        end
        |> redirect(external: Routes.activity_path(conn, :index))
      false ->
        conn
        |> put_flash(:warning, "You have already cancelled your premium subscription")
        |> redirect(external: Routes.activity_path(conn, :index))
    end
  end
end
