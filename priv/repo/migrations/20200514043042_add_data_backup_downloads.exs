defmodule Philomena.Repo.Migrations.AddDataBackupDownloads do
  use Ecto.Migration

  def change do
    create table(:data_backup_downloads, primary_key: false) do
      add :data_backup_id, :integer, primary_key: true
      add :date, :utc_datetime, primary_key: true
    end
  end
end
