defmodule PhilomenaWeb.Tag.AliasController do
  use PhilomenaWeb, :controller

  alias Philomena.Tags.Tag
  alias Philomena.Tags

  plug PhilomenaWeb.CanaryMapPlug, edit: :alias, update: :alias, delete: :alias

  plug :load_and_authorize_resource,
    model: Tag,
    id_name: "tag_id",
    id_field: "slug",
    preload: [:implied_tags, :aliased_tag],
    persisted: true

  def edit(conn, _params) do
    changeset = Tags.change_tag(conn.assigns.tag)
    render(conn, "edit.html", title: "Editing Tag Alias", changeset: changeset)
  end

  def update(conn, %{"tag" => tag_params}) do
    spawn(fn ->
      Tags.alias_tag(conn.assigns.tag, tag_params)
    end)

    conn
    |> put_flash(:info, "Tag alias queued.")
    |> redirect(to: Routes.tag_alias_path(conn, :edit, conn.assigns.tag))
  end

  def delete(conn, _params) do
    spawn(fn ->
      {:ok, _tag} = Tags.unalias_tag(conn.assigns.tag)
    end)

    conn
    |> put_flash(:info, "Tag dealias queued.")
    |> redirect(to: Routes.tag_path(conn, :show, conn.assigns.tag))
  end
end
