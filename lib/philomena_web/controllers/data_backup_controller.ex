defmodule PhilomenaWeb.DataBackupController do
  use PhilomenaWeb, :controller
  require Logger
  import Phoenix.Controller

  alias Logger
  alias Philomena.Users.User
  alias Philomena.DataBackup
  alias Philomena.DataBackup.Download
  alias Zarex
  alias Philomena.Repo
  alias PhilomenaWeb.DataBackupView
  alias Phoenix.HTML

  def delete(conn, %{"id" => id}) do
    user = Repo.preload(conn.assigns.current_user, :data_backups)

    backup =
      user.data_backups
      |> Enum.filter(fn backup -> backup.id == String.to_integer(id) and not backup.deleted end)

    case backup do
      [] ->
        conn
        |> put_flash(:error, "Not authorized")
        |> redirect(to: Routes.data_backup_path(conn, :index))

      [backup] ->
        DataBackup.delete(backup)

        conn
        |> redirect(to: Routes.data_backup_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.preload(conn.assigns.current_user, :data_backups)

    backup =
      user.data_backups
      |> Enum.filter(fn backup -> backup.id == String.to_integer(id) and not backup.deleted end)

    case backup do
      [] ->
        conn
        |> put_flash(:error, "Not authorized")
        |> redirect(to: Routes.data_backup_path(conn, :index))

      [backup] ->
        do_download(conn, backup)
    end
  end

  def index(conn, _params) do
    user = Repo.preload(conn.assigns.current_user, :data_backups)

    backups =
      user.data_backups
      |> Enum.filter(fn backup -> not backup.deleted end)
      |> Enum.sort_by(&Map.get(&1, :create_date), :desc)

    render(conn, "index.html",
      title: "Cloud Backup",
      data_backups: backups
    )
  end

  def create(conn, %{"backup" => file, "description" => description}) do
    user = conn.assigns.current_user

    case User.backup_size_allowed?(user, file.path) do
      {false, size} ->
        conn
        |> put_status(:request_entity_too_large)
        |> text(to_string(size))
        |> halt()

      {true, _} ->
        path = DataBackup.persist_file(file.path, user)

        %DataBackup{
          path: path,
          user_id: user.id,
          file_name: Zarex.sanitize(file.filename),
          description: description
        }
        |> DataBackup.create_data_backup()
        |> case do
          {:ok, backup} ->
            DataBackup.upload_to_backblaze(backup)

            conn
            |> json(%{
              description: backup.description,
              create_date: to_string(backup.create_date),
              file_size: Size.humanize!(backup.disk_size),
              download_link: DataBackupView.download_link(conn, backup) |> HTML.safe_to_string(),
              delete_link: DataBackupView.delete_link(conn, backup) |> HTML.safe_to_string()
            })
            |> halt()

          error ->
            Logger.error("backup error for user #{user.id}: #{inspect(error)}")

            conn
            |> put_status(:server_error)
            |> text("")
            |> halt()
        end
    end
  end

  def do_download(conn, backup) do
    case DataBackup.can_download?(backup) do
      true ->
        Download.record(backup)
        conn
        |> put_resp_header("content-disposition", ~s(attachment; filename="#{backup.file_name}"))
        |> send_file(200, backup.path)
      false ->
        conn
        |> put_flash(:error, "You've already downloaded that file 3 times in the past month")
        |> redirect(to: Routes.data_backup_path(conn, :index))
    end
  end
end
