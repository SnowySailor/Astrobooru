defmodule Philomena.Paypal.Hooks.BillingSubscription do
  require Logger
  alias Philomena.Repo
  alias Philomena.Users.User
  alias Philomena.PremiumSubscription.SubscriptionPayment
  import Ecto.Query, warn: false

  def handle_billing_subscription_activated(conn, event) do
    IO.puts("got event")
    IO.inspect(event)

    User
    |> join(:inner, [u], s in Subscription, on: s.user_id == u.id)
    |> where([s], s.id == ^event.resource.id)
    |> Repo.one()
    |> activate_user_subscription(event)
  end

  defp activate_user_subscription(%User{id: id}, event) do
    case DateTime.from_iso8601(event.resource.billing_info.last_payment.time) do
      {:ok, time} -> 
        %SubscriptionPayment{
          subscription_id: event.resource.id,
          payment_date: time
        }
        |> SubscriptionPayment.changeset(%{})
        |> Repo.insert()
      _ -> Logger.warn("could not parse time #{event.resource.billing_info.last_payment.time}")
    end
  end

  defp activate_user_subscription(_, event),
    do: Logger.warn("could not locate user for subscription activation event #{inspect(event)}")
end