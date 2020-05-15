defmodule Philomena.DataBackup do
  use Ecto.Schema
  use Retry
  import Ecto.Changeset
  alias Philomena.DataBackup.Download
  alias Philomena.Backblaze.API
  alias Philomena.Users.User
  alias Philomena.Repo
  alias Ecto
  require Logger

  schema "data_backups" do
    belongs_to :user, User
    has_many :downloads, Download

    field :path, :string, null: false
    field :disk_size, :integer, null: false
    field :file_name, :string, null: false
    field :description, :string, size: 500
    field :create_date, :utc_datetime, null: false
    field :backblaze_file_id, :string
    field :in_backblaze, :boolean, null: false, default: false
    field :deleted, :boolean, null: false, default: false
  end

  @doc false
  def changeset(data_backup, attrs) do
    data_backup
    |> cast(attrs, [])
    |> validate_required([])
    |> validate_length(:description, max: 500, count: :bytes)
  end

  @doc false
  def create_changeset(data_backup, attrs) do
    size = File.stat!(data_backup.path).size
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    data_backup
    |> cast(attrs, [])
    |> change(%{create_date: now, disk_size: size})
    |> validate_required([:path, :disk_size, :file_name])
  end

  def delete_changeset(data_backup, attrs) do
    data_backup
    |> cast(attrs, [])
    |> change(deleted: true)
  end

  def uploaded_changeset(data_backup, attrs) do
    data_backup
    |> cast(attrs, [:backblaze_file_id])
    |> change(in_backblaze: true)
    |> validate_required([:in_backblaze, :backblaze_file_id])
  end

  def persist_file(source, user) do
    name = Ecto.UUID.generate()
    dest_path = Path.join(data_backup_file_root(), to_string(user.id))
    dest = Path.join(dest_path, name)
    File.mkdir_p!(dest_path)
    File.cp!(source, dest)
    dest
  end

  def delete(data_backup) do
    data_backup
    |> delete_changeset(%{})
    |> Repo.update!()

    File.rm!(data_backup.path)
  end

  def create_data_backup(data_backup) do
    data_backup
    |> create_changeset(%{})
    |> Repo.insert()
  end

  def upload_to_backblaze(data_backup) do
    spawn(fn ->
      IO.puts("uploading")
      response = API.upload_file!(data_backup.path, make_storage_name(data_backup))
      mark_uploaded_and_delete_local(data_backup, response)
    end)
  end

  def mark_uploaded_and_delete_local(data_backup, upload_data) do
    IO.puts("uploaded: #{inspect(upload_data)}")
    mark_uploaded(data_backup, upload_data)
    spawn(fn ->
      remove_file(data_backup)
    end)
  end

  def mark_uploaded(data_backup, upload_data) do
    data_backup
    |> uploaded_changeset(%{backblaze_file_id: upload_data.fileId})
    |> Repo.update!()
  end

  def remove_file(data_backup) do
    retry with: exponential_backoff(1_000) |> cap(120_000) |> expiry(86_400_00), rescue_only: [File.Error] do
      File.rm!(data_backup.path)
    after
      _ ->
        nil
    else
      error ->
        Logger.error("Could not remove file #{data_backup.path}: #{inspect(error)}")
        raise error
    end
  end

  def can_download?(data_backup) do
    downloads =
      Repo.query!("""
        SELECT COUNT(*)
        FROM data_backup_downloads
        WHERE
          data_backup_id = #{data_backup.id}
          AND
          date > ((NOW() at time zone 'utc') - interval '1 month')
      """)
      |> case do
        %{rows: n} when n in [nil, []] ->
          0

        %{rows: [[downloads] | _rest]} ->
          downloads
      end
    downloads < 3
  end

  def make_storage_name(data_backup) do
    data_backup
    |> Repo.preload([:user])
    |> (fn data_backup -> 
        "user/" <> to_string(data_backup.user.id) <> "/" <> data_backup.file_name
      end).() 
  end

  defp data_backup_file_root do
    Application.get_env(:philomena, :data_backup_file_root)
  end
end
