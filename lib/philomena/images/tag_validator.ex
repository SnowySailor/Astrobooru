defmodule Philomena.Images.TagValidator do
  alias Philomena.Servers.Config
  import Ecto.Changeset

  @ratings MapSet.new(["dso", "planetary", "lunar", "solar", "landscape"])
  @empty MapSet.new()

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

  defp ratings(%MapSet{} = tag_set) do
    MapSet.intersection(tag_set, @ratings)
  end

  defp validate_number_of_tags(changeset, tag_set, num) do
    cond do
      MapSet.size(tag_set) < num ->
        changeset
        |> add_error(:tag_input, "must contain at least #{num} tags")

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

  defp validate_has_rating(changeset, %{safe: s, sexual: x, horror: h, gross: g})
       when s == @empty and x == @empty and h == @empty and g == @empty do
    changeset
    |> add_error(:tag_input, "must contain at least one rating tag")
  end

  defp validate_has_rating(changeset, _ratings), do: changeset

  defp validate_only_one_rating(changeset, ratings) do
    cond do
      MapSet.size(ratings) > 1 ->
        changeset
        |> add_error(:tag_input, "may contain only one type")

      true ->
        changeset
    end
  end

  defp extract_names(tags) do
    tags
    |> Enum.map(& &1.name)
    |> MapSet.new()
  end
end
