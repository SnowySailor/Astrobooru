defmodule PhilomenaWeb.PremiumSubscriptionController do
  use PhilomenaWeb, :controller

  def show(conn, _params) do
    render(
      conn,
      "show.html",
      subscription_options: get_subscription_options()
    )
  end

  defp get_subscription_options() do
    [
      %{
        title: "Monthly",
        cost: 5.50,
        recurrence: "month"
      },
      %{
        title: "Tri-monthly",
        cost: 15.00,
        recurrence: "3 months"
      },
      %{
        title: "Semi-annual",
        cost: 27.00,
        recurrence: "6 months"
      },
      %{
        title: "Yearly",
        cost: 50.00,
        recurrence: "year"
      }
    ]
  end
end
