defmodule PhilomenaWeb.Image.PlatesolveController do
  use PhilomenaWeb, :controller

  alias Philomena.Tags
  alias Philomena.Images.Image

  plug PhilomenaWeb.CanaryMapPlug, create: :hide

  plug :load_and_authorize_resource,
    model: Image,
    id_name: "image_id",
    persisted: true,
    preload: [:tags]

  def create(conn, _params) do
    spawn(fn ->
      Tags.autopopulate_object_tags(conn.assigns.image)
    end)

    conn
    |> put_flash(:info, "Platesolve started.")
    |> redirect(to: Routes.image_path(conn, :show, conn.assigns.image))
  end
end
