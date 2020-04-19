defmodule Philomena.Repo.Migrations.CreatePaypalProducts do
  use Ecto.Migration

  def change do
    create table(:paypal_products, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string, null: false
      add :description, :string, null: false
      add :type, :string, null: false
      add :category, :string, null: false
    end
  end
end
