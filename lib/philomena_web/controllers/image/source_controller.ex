defmodule PhilomenaWeb.Image.SourceController do
  use PhilomenaWeb, :controller

  alias Philomena.SourceChanges.SourceChange
  alias Philomena.UserStatistics
  alias Philomena.Images.Image
  alias Philomena.Images
  alias Philomena.Repo
  alias Philomena.Captcha
  import Ecto.Query

  plug PhilomenaWeb.FilterBannedUsersPlug
  plug PhilomenaWeb.CaptchaPlug
  plug PhilomenaWeb.UserAttributionPlug
  plug PhilomenaWeb.CanaryMapPlug, update: :edit_metadata
  plug :load_and_authorize_resource, model: Image, id_name: "image_id", preload: [:tags, :user]

  def update(conn, %{"image" => image_params}) do
    attributes = conn.assigns.attributes
    image = conn.assigns.image
    old_source = image.source_url

    case Images.update_source(image, attributes, image_params) do
      {:ok, %{image: image}} ->
        PhilomenaWeb.Endpoint.broadcast!(
          "firehose",
          "image:source_update",
          %{image_id: image.id, added: [image.source_url], removed: [old_source]}
        )
        PhilomenaWeb.Endpoint.broadcast!(
          "firehose",
          "image:update",
          PhilomenaWeb.Api.Json.ImageView.render("show.json", %{image: image, interactions: []})
        )

        changeset = Images.change_image(image)

        source_change_count =
          SourceChange
          |> where(image_id: ^image.id)
          |> Repo.aggregate(:count, :id)

        if old_source != image.source_url do
          UserStatistics.inc_stat(conn.assigns.current_user, :metadata_updates)
        end

        Images.reindex_image(image)

        conn
        |> put_view(PhilomenaWeb.ImageView)
        |> render("_source.html",
          layout: false,
          source_change_count: source_change_count,
          image: image,
          changeset: changeset,
          captcha_site_key: Captcha.get_captcha_site_key()
        )

      {:error, :image, changeset, _} ->
        conn
        |> put_view(PhilomenaWeb.ImageView)
        |> render("_source.html",
          layout: false,
          source_change_count: 0,
          image: image,
          changeset: changeset,
          captcha_site_key: Captcha.get_captcha_site_key()
        )
    end
  end
end
