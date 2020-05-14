defmodule Philomena.Repo.Migrations.AddDataBackupsTable do
  use Ecto.Migration

  def change do
    create table(:data_backups) do
      add :user_id, references(:users, on_update: :update_all, on_delete: :delete_all),
        null: false

      add :disk_size, :bigint, null: false
      add :path, :string, null: false
      add :file_name, :string, null: false
      add :description, :string, size: 500

      add :create_date, :utc_datetime,
        null: false,
        default: fragment("(now() at time zone 'utc')")
    end
  end
end
