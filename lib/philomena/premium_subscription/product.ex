defmodule Philomena.PremiumSubscription.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  schema "paypal_products" do
    has_many :billing_plans, BillingPlan

    field :name, :string, null: false
    field :description, :string, null: false
    field :type, :string, null: false
    field :category, :string, null: false
  end

  @doc false
  def save_changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [])
    |> validate_required([:name, :description, :type, :category])
  end
end
