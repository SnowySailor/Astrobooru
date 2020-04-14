defmodule Philomena.Repo.Migrations.CreatePremiumSubscriptions do
  use Ecto.Migration

  def change do
    create table(:premium_subscriptions) do
      add :start_date, :utc_datetime, null: false
      add :end_date, :utc_datetime, null: false
      add :type, :string, null: false
      add :user_id, references(:users, on_update: :update_all, on_delete: :delete_all)
    end

    create index(:premium_subscriptions, [:type, :end_date])
    create index(:premium_subscriptions, [:user_id])
  end
end
