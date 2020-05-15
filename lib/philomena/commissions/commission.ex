defmodule Philomena.Commissions.Commission do
  use Ecto.Schema
  import Ecto.Changeset

  alias Philomena.Commissions.Item
  alias Philomena.Images.Image
  alias Philomena.Users.User

  schema "commissions" do
    belongs_to :user, User
    belongs_to :sheet_image, Image
    has_many :items, Item

    field :open, :boolean
    field :categories, {:array, :string}, default: []
    field :information, :string
    field :contact, :string
    field :will_create, :string
    field :will_not_create, :string
    field :commission_items_count, :integer, default: 0

    timestamps(inserted_at: :created_at)
  end

  @doc false
  def changeset(commission, attrs) do
    commission
    |> cast(attrs, [
      :information,
      :contact,
      :will_create,
      :will_not_create,
      :open,
      :sheet_image_id,
      :categories
    ])
    |> drop_blank_categories()
    |> validate_required([:user_id, :information, :contact, :open])
    |> validate_length(:information, max: 700, count: :bytes)
    |> validate_length(:contact, max: 700, count: :bytes)
    |> validate_subset(:categories, Keyword.values(categories()))
  end

  defp drop_blank_categories(changeset) do
    categories =
      changeset
      |> get_field(:categories)
      |> Enum.filter(&(&1 not in [nil, ""]))

    change(changeset, categories: categories)
  end

  def categories do
    [
      DSO: "DSO",
      Planetary: "Planetary",
      Lunar: "Lunar"
    ]
  end

  def types do
    [
      "Monochrome",
      "Color",
      "Video"
    ]
  end
end
