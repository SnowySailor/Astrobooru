defmodule Philomena.PremiumSubscription.SubscriptionPayment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Philomena.PremiumSubscription.Subscription

  @primary_key false
  schema "paypal_subscription_payments" do
    belongs_to :subscription, Subscription, type: :string, primary_key: true

    field :payment_date, :utc_datetime, null: false, primary_key: true
  end

  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [])
    |> validate_required([:payment_date, :payment_duration, :subscription_id])
  end
end
