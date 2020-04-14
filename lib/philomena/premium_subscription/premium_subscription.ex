defmodule Philomena.PremiumSubscription.PremiumSubscription do
  use Ecto.Schema
  import Ecto.Changeset

  alias Philomena.Users.User

  schema "premium_subscriptions" do
    belongs_to :user, User

    field :start_date, :utc_datetime, null: false
    field :end_date, :utc_datetime, null: false
    field :type, :string, null: false
  end

  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:start_date, :end_date, :type])
    |> validate_required([:start_date, :end_date, :type])
  end
end
