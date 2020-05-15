defmodule Philomena.Repo.Migrations.AddDataBackupFields do
  use Ecto.Migration

  def change do
    alter table(:data_backups) do
      add :backblaze_file_id, :string, null: true
      add :in_backblaze, :boolean, null: false, default: false
    end
  end
end
