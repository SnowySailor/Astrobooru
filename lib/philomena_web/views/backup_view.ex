defmodule PhilomenaWeb.DataBackupView do
  use PhilomenaWeb, :view

  def download_link(conn, backup) do
    content_tag(:a, backup.file_name, [{:href, Routes.data_backup_path(conn, :show, backup.id)}])
  end

  def delete_link(conn, backup) do
    content_tag(:a, "Delete", [
      {:data, [confirm: "Are you really, really sure?", method: "delete"]},
      {:href, Routes.data_backup_path(conn, :delete, backup.id)}
    ])
  end
end
