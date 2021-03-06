defmodule TwelveDays do
  @doc """
  Given a `number`, return the song's verse for that specific day, including
  all gifts for previous days in the same line.
  """
  @day ~w(_ first second third fourth fifth sixth seventh eighth ninth tenth eleventh twelfth)

  @gift ["_", "and a Partridge in a Pear Tree", "two Turtle Doves", "three French Hens", "four Calling Birds",
        "five Gold Rings", "six Geese-a-Laying", "seven Swans-a-Swimming", "eight Maids-a-Milking",
        "nine Ladies Dancing", "ten Lords-a-Leaping", "eleven Pipers Piping", "twelve Drummers Drumming"]

  @spec verse(number :: integer) :: String.t()
  def verse(1), do: first_part(1)  <> "a Partridge in a Pear Tree."
  def verse(n), do: first_part(n) <> descending_gift_list(n) <> "."

  @doc """
  Given a `starting_verse` and an `ending_verse`, return the verses for each
  included day, one per line.
  """
  @spec verses(starting_verse :: integer, ending_verse :: integer) :: String.t()
  def verses(starting_verse, ending_verse), do: starting_verse..ending_verse |> Enum.map(&verse/1) |> Enum.join("\n")

  @doc """
  Sing all 12 verses, in order, one verse per line.
  """
  @spec sing():: String.t()
  def sing, do: verses(1, 12)

  defp first_part(number), do: "On the #{Enum.at(@day, number)} day of Christmas my true love gave to me, "
  defp descending_gift_list(number), do: number..1 |> Enum.map(fn n -> Enum.at(@gift, n) end) |> Enum.join(", ")
end

