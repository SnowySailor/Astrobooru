defmodule Philomena.Repo.Migrations.CreatePaypalBillingPlans do
  use Ecto.Migration

  def change do
    create table(:paypal_billing_plans, primary_key: false) do
      add :id, :string, primary_key: true

      add :product_id,
          references(:paypal_products,
            on_update: :update_all,
            on_delete: :delete_all,
            type: :string
          ),
          null: false

      add :cycle_duration, :integer, null: false
    end
  end
end
