defmodule PhilomenaWeb.AvatarGeneratorView do
  use PhilomenaWeb, :view
  use Bitwise

  alias Philomena.Servers.Config

  def generated_avatar(displayed_name) do
    config = config()

    # Generate 8 pseudorandom numbers
    seed = :erlang.crc32(displayed_name)

    {rand, _acc} =
      Enum.map_reduce(1..8, seed, fn _elem, acc ->
        value = xorshift32(acc)
        {value, value}
      end)

    # Set the ranges for the colors we are going to make
    color_range = 128
    color_brightness = 72

    {body_r, body_g, body_b, rand} = gen_random_rgb(0..color_range, color_brightness, rand)
    {rings_r, rings_g, rings_b, _rand} = gen_random_rgb(0..color_range, color_brightness, rand)

    color_bd = format("~2.16.0B~2.16.0B~2.16.0B", [body_r, body_g, body_b])
    color_rgstart = format("~2.16.0B~2.16.0B~2.16.0B", [rings_r, rings_g, rings_b])

    avatar_svg(config, color_bd, color_rgstart)
  end

  defp avatar_svg(config, color_bd, color_rgstart) do
    [
      header(config),
      background(config),
      body(config) |> String.replace("BODY_FILL", color_bd),
      rings(config) |> String.replace("RING_GRADIENT_START", color_rgstart),
      footer(config)
    ]
    |> List.flatten()
    |> Enum.map(&raw/1)
  end

  # https://en.wikipedia.org/wiki/Xorshift
  # 32-bit xorshift deterministic PRNG
  defp xorshift32(state) do
    state = state &&& 0xFFFF_FFFF
    state = state ^^^ (state <<< 13)
    state = state ^^^ (state >>> 17)

    state ^^^ (state <<< 5)
  end

  defp gen_random_rgb(range, brightness, rand) do
    {r, rand} = at(range, rand)
    {g, rand} = at(range, rand)
    {b, rand} = at(range, rand)

    {r + brightness, g + brightness, b + brightness, rand}
  end

  defp at(list, [position | rest]) do
    length = Enum.count(list)
    position = rem(position, length)

    {Enum.at(list, position), rest}
  end

  defp format(format_string, args), do: to_string(:io_lib.format(format_string, args))

  defp header(%{"header" => header}), do: header
  defp background(%{"background" => background}), do: background
  defp body(%{"body" => body}), do: body
  defp rings(%{"rings" => rings}), do: rings
  defp footer(%{"footer" => footer}), do: footer

  defp config, do: Config.get(:avatar)
end
