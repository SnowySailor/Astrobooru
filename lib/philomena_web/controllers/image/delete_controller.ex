defmodule PhilomenaWeb.Image.DeleteController do
  use PhilomenaWeb, :controller

  # N.B.: this would be Image.Hide, because it hides the image, but that is
  # taken by the user action

  alias Philomena.Images.Image
  alias Philomena.Images
  alias Philomena.Tags
  alias Philomena.Reports

  plug PhilomenaWeb.CanaryMapPlug, create: :hide, delete: :hide
  plug :load_and_authorize_resource, model: Image, id_name: "image_id", persisted: true
  plug :verify_deleted when action in [:update]

  def create(conn, %{"image" => image_params}) do
    image = conn.assigns.image
    user = conn.assigns.current_user

    case Images.hide_image(image, user, image_params) do
      {:ok, %{image: image, tags: tags, reports: {_count, reports}}} ->
        Images.reindex_image(image)
        Reports.reindex_reports(reports)
        Tags.reindex_tags(tags)

        conn
        |> put_flash(:info, "Image successfully hidden.")
        |> redirect(to: Routes.image_path(conn, :show, image))

      {:error, :image, changeset, _changes} ->
        render(conn, "new.html", image: image, changeset: changeset)
    end
  end

  def update(conn, %{"image" => image_params}) do
    image = conn.assigns.image

    case Images.update_hide_reason(image, image_params) do
      {:ok, image} ->
        Images.reindex_image(image)

        conn
        |> put_flash(:info, "Hide reason updated.")
        |> redirect(to: Routes.image_path(conn, :show, image))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Couldn't update hide reason.")
        |> redirect(to: Routes.image_path(conn, :show, image))
    end
  end

  defp verify_deleted(conn, _opts) do
    case conn.assigns.image.hidden_from_users do
      true ->
        conn

      _false ->
        conn
        |> put_flash(:error, "Cannot change hide reason on a non-hidden image!")
        |> redirect(to: Routes.image_path(conn, :show, conn.assigns.image))
        |> halt()
    end
  end

  def delete(conn, _params) do
    image = conn.assigns.image

    {:ok, %{image: image, tags: tags}} = Images.unhide_image(image)
    Images.reindex_image(image)
    Tags.reindex_tags(tags)

    conn
    |> put_flash(:info, "Image successfully unhidden.")
    |> redirect(to: Routes.image_path(conn, :show, image))
  end
end
