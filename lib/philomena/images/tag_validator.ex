defmodule Philomena.Images.TagValidator do
  alias Philomena.Servers.Config
  import Ecto.Changeset

  def validate_tags(changeset) do
    tags = changeset |> get_field(:tags)

    validate_tag_input(changeset, tags)
  end

  defp validate_tag_input(changeset, tags) do
    tag_set = extract_names(tags)
    rating_set = ratings(tag_set)

    changeset
    |> validate_number_of_tags(tag_set, 3)
    |> validate_bad_words(tag_set)
    |> validate_has_rating(rating_set)
    |> validate_only_one_rating(rating_set)
  end

  defp ratings(tag_set) do
    dso = MapSet.intersection(tag_set, dso_rating())
    planetary = MapSet.intersection(tag_set, planetary_ratings())
    lunar = MapSet.intersection(tag_set, lunar_ratings())
    solar = MapSet.intersection(tag_set, solar_rating())
    landscape = MapSet.intersection(tag_set, landscape_rating())

    %{
      dso: dso,
      planetary: planetary,
      lunar: lunar,
      solar: solar,
      landscape: landscape
    }
  end

  defp validate_number_of_tags(changeset, tag_set, num) do
    cond do
      MapSet.size(tag_set) < num ->
        add_error(changeset, :tag_input, "must contain at least #{num} tags")

      true ->
        changeset
    end
  end

  def validate_bad_words(changeset, tag_set) do
    bad_words = MapSet.new(Config.get(:tag)["blacklist"])
    intersection = MapSet.intersection(tag_set, bad_words)

    cond do
      MapSet.size(intersection) > 0 ->
        Enum.reduce(
          intersection,
          changeset,
          &add_error(&2, :tag_input, "contains forbidden tag `#{&1}'")
        )

      true ->
        changeset
    end
  end

  defp validate_has_rating(changeset, %{dso: d, planetary: p, lunar: l, solar: s, landscape: la}) do
    cond do
      MapSet.size(d) > 0 or MapSet.size(p) > 0 or MapSet.size(l) > 0 or MapSet.size(s) > 0 or MapSet.size(la) > 0 ->
        changeset

      true ->
        add_error(changeset, :tag_input, "must contain at least one classification tag")
    end
  end

  defp validate_only_one_rating(changeset, ratings) do
    rating =
      Enum.reduce(ratings, 0, fn r, acc ->
        acc + MapSet.size(elem(r, 1))
      end)

    cond do
      rating > 1 ->
        changeset
        |> add_error(:tag_input, "may contain only one classification tag")

      true ->
        changeset
    end
  end

  defp extract_names(tags) do
    tags
    |> Enum.map(& &1.name)
    |> MapSet.new()
  end

  defp dso_rating, do: MapSet.new(["dso"])
  defp planetary_ratings, do: MapSet.new(["planetary"])
  defp lunar_ratings, do: MapSet.new(["lunar"])
  defp solar_rating, do: MapSet.new(["solar"])
  defp landscape_rating, do: MapSet.new(["landscape"])
end
