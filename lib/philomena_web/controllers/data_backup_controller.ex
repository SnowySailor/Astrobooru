defmodule PhilomenaWeb.DataBackupController do
  use PhilomenaWeb, :controller
  require Logger
  alias Logger
  import Phoenix.Controller
  alias Philomena.Users.User
  alias Philomena.DataBackup
  alias Zarex

  def index(conn, _params) do
    render(conn, "index.html",
      title: "Cloud Backup"
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
          {:ok, _} -> 
            conn
            |> put_status(:ok)
            |> text("")
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
end
