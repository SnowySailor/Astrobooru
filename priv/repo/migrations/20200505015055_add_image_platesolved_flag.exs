defmodule Philomena.Repo.Migrations.AddImagePlatesolvedFlag do
  use Ecto.Migration

  def change do
    alter table(:images) do
      add :platesolved, :boolean, default: false
    end
  end
end
