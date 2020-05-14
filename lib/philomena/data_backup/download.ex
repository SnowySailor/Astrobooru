defmodule Philomena.DataBackup.Download do
  use Ecto.Schema
  import Ecto.Changeset
  alias Philomena.Repo
  alias Philomena.DataBackup
  alias Philomena.DataBackup.Download

  @primary_key false
  schema "data_backup_downloads" do
    belongs_to :data_backup, DataBackup, primary_key: true
    field :date, :utc_datetime, null: false, primary_key: true
  end

  def record_changeset(download, attrs) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    download
    |> cast(attrs, [])
    |> change(date: now)
    |> validate_required([:date])
  end

  def record(data_backup) do
    %Download{
      data_backup_id: data_backup.id
    }
    |> record_changeset(%{})
    |> Repo.insert!()
  end
end