defmodule Philomena.Repo.Migrations.IncreaseBillingPlanFieldCapacity do
  use Ecto.Migration

  def change do
    alter table(:paypal_billing_plans) do
      modify :backup_size_limit, :bigint, null: false
    end
  end
end
