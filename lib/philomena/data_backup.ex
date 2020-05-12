defmodule Philomena.DataBackup do
  use Ecto.Schema
  import Ecto.Changeset
  alias Philomena.Users.User
  alias Philomena.Repo
  alias Ecto
  
  schema "data_backups" do
    belongs_to :user, User

    field :path, :string, null: false
    field :disk_size, :integer, null: false
    field :file_name, :string, null: false
    field :description, :string, size: 500
    field :create_date, :utc_datetime, null: false
  end

  @doc false
  def changeset(data_backup, attrs) do
    data_backup
    |> cast(attrs, [])
    |> validate_required([])
    |> validate_length(:description, max: 50_000, count: :bytes)
  end

  def persist_file(source, user) do
    name = Ecto.UUID.generate()
    dest_path = Path.join(data_backup_file_root(), to_string(user.id))
    dest = Path.join(dest_path, name)
    File.mkdir_p!(dest_path)
    File.cp!(source, dest)
    dest
  end

  def create_data_backup(data_backup) do
    size = File.stat!(data_backup.path).size
    Map.put(data_backup, :disk_size, size)
    |> changeset(%{})
    |> Repo.insert()
  end

  defp data_backup_file_root do
    Application.get_env(:philomena, :data_backup_file_root)
  end
end