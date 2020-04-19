defmodule Philomena.PremiumSubscription.BillingPlan do
  use Ecto.Schema
  import Ecto.Changeset

  alias Philomena.Users.User

  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  schema "paypal_billing_plans" do
    belongs_to :product, Product, type: :string
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [])
    |> validate_required([
      :product_id,
      :status,
      :link,
      :start_time,
      :create_time,
      :status_update_time
    ])
  end
end
