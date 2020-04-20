defmodule Philomena.PremiumSubscription.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  alias Philomena.Users.User
  alias Philomena.PremiumSubscription.{BillingPlan, SubscriptionPayment}

  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  schema "paypal_subscriptions" do
    belongs_to :user, User
    belongs_to :billing_plan, BillingPlan, type: :string
    has_many :payments, SubscriptionPayment
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [])
    |> validate_required([])
  end
end
