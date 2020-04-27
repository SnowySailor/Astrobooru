defmodule PhilomenaWeb.PremiumSubscriptionController do
  use PhilomenaWeb, :controller
  alias Philomena.Users.User

  def index(conn, _params) do
    render(
      conn,
      "show.html",
      subscription_options: get_subscription_options(),
      can_purchase: User.can_purchase_premium_subscription?(conn.assigns.current_user)
    )
  end

  defp get_subscription_options() do
    [
      %{
        title: "Monthly",
        cost: Decimal.from_float(5.50),
        recurrence: "month",
        id: "1"
      },
      %{
        title: "Tri-monthly",
        cost: Decimal.from_float(15.00),
        recurrence: "3 months",
        id: "2"
      },
      %{
        title: "Semi-annual",
        cost: Decimal.from_float(27.00),
        recurrence: "6 months",
        id: "3"
      },
      %{
        title: "Yearly",
        cost: Decimal.from_float(50.00),
        recurrence: "year",
        id: "4"
      }
    ]
  end
end
