defmodule Philomena.PremiumSubscription.BillingPlan do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  schema "paypal_billing_plans" do
    field :product_id, :string, null: false
    field :cycle_duration, :integer, null: false
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [])
    |> validate_required([:cycle_duration])
  end
end
