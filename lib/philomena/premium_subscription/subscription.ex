defmodule Philomena.PremiumSubscription.Subscription do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias Philomena.Repo

  alias Philomena.Users.User
  alias Philomena.PremiumSubscription.{BillingPlan, Subscription, SubscriptionPayment}
  alias Philomena.Paypal.API

  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  schema "paypal_subscriptions" do
    belongs_to :user, User
    belongs_to :billing_plan, BillingPlan, type: :string
    has_many :payments, SubscriptionPayment
    field :cancelled, :boolean, null: false, default: false
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [])
    |> validate_required([])
  end

  def cancel_subscriptions(user, reason) do
    subscriptions =
      Subscription
      |> where([s], s.user_id == ^user.id)
      |> where([s], s.cancelled == false)
      |> distinct(:id)
      |> Repo.all()
    
    success =
      subscriptions
      |> Enum.filter(&active?(&1.id))
      |> Enum.map(&API.cancel_subscription(&1.id, reason))
      |> Enum.map(&log_errors(&1))
      |> Enum.all?(fn {status, _} -> status == :ok end)

    if success do
      ids = Enum.map(subscriptions, fn s -> s.id end)
      Subscription
      |> where([s], s.id in ^ids)
      |> Repo.update_all(set: [cancelled: true])
    end

    success
  end

  def log_errors(data) do
    IO.inspect(data)
    data
  end

  def active?(id) do
    data = API.get_subscription(id)
    IO.inspect(data)
    case data do
      {:ok, %{status: "ACTIVE"}} -> true
      {:ok, _} -> false
    end
  end
end
