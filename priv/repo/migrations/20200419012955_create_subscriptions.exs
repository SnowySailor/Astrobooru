defmodule Philomena.Repo.Migrations.CreatePaypalSubscriptions do
  use Ecto.Migration

  def change do
    create table(:paypal_subscriptions, primary_key: false) do
      add :id, :string, primary_key: true
      add :cancelled, :boolean, null: false, default: false
      add :image_size_limit, :integer, null: false, default: 3_145_728
      add :backup_size_limit, :bigint, null: false, default: 0

      add :user_id, references(:users, on_update: :update_all, on_delete: :delete_all),
        null: false

      add :billing_plan_id,
          references(:paypal_billing_plans,
            on_update: :update_all,
            on_delete: :delete_all,
            type: :string
          ),
          null: false
    end

    create index(:paypal_subscriptions, [:user_id])
  end
end
