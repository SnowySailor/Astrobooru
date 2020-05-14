defmodule Philomena.Repo.Migrations.AddDataBackupDeletedFlag do
  use Ecto.Migration

  def change do
    alter table(:data_backups) do
      add :deleted, :boolean, null: false, default: false
    end
  end
end
