defmodule Philomena.PremiumSubscription.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  alias Philomena.Users.User

  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  schema "paypal_subscriptions" do
    belongs_to :user, User
    belongs_to :billing_plan, BillingPlan, type: :string
    has_many :payments, Payment

    field :payment_duration, :integer, null: false
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [])
    |> validate_required([:payment_duration])
  end
end
