defmodule Philomena.Repo.Migrations.CreatePaypalSubscriptionPayments do
  use Ecto.Migration

  def change do
    create table(:paypal_subscription_payments, primary_key: false) do
      add :subscription_id,
          references(:paypal_subscriptions,
            on_update: :update_all,
            on_delete: :delete_all,
            type: :string
          ),
          null: false,
          primary_key: true

      add :payment_date, :utc_datetime, null: false, primary_key: true
    end
  end
end
