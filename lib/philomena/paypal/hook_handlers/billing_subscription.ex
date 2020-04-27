defmodule Philomena.Paypal.HookHandlers.BillingSubscription do
  alias Philomena.Repo
  alias Philomena.PremiumSubscription.{SubscriptionPayment, Subscription}
  import Ecto.Query, warn: false

  def activated(%{"resource" => %{"id" => id, "start_time" => time, "status" => "ACTIVE"}}) do
    case DateTime.from_iso8601(time) do
      {:ok, parsed_time, 0} ->
        add_subscription_payment(id, parsed_time)
      _ ->
        {:error, "could not parse time: #{time}"}
    end
  end

  def activated(event),
    do: {:error, "could not validate status or locate id start_time in event #{inspect(event)}"}

  def activated(id, time) do
    add_subscription_payment(id, time)
  end

  def cancelled(%{"resource" => %{"id" => id}}) do 
    Subscription
    |> where([s], s.id == ^id)
    |> Repo.update_all(set: [cancelled: true])
  end

  def sale_completed(%{"resource" => %{"billing_agreement_id" => id, "create_time" => time}}) do
    case DateTime.from_iso8601(time) do
      {:ok, parsed_time, 0} ->
        add_subscription_payment(id, parsed_time)
      _ ->
        {:error, "could not parse time #{time}"}
    end
  end

  def sale_reversed(event) do
    
  end

  def sale_refunded(event) do
    
  end

  def add_subscription_payment(subscription_id, time) do
    %SubscriptionPayment{
      subscription_id: subscription_id,
      payment_date: time
    }
    |> SubscriptionPayment.changeset(%{})
    |> Repo.insert(on_conflict: :nothing)
  end
end