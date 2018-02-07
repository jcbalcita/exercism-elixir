defmodule TwelveDays do
  @doc """
  Given a `number`, return the song's verse for that specific day, including
  all gifts for previous days in the same line.
  """
  @day Enum.to_list(1..12)
       |> Enum.zip(["first", "second", "third", "fourth", "fifth", "sixth","seventh", "eighth", "ninth", "tenth", "eleventh", "twelfth"])
       |> Enum.into(%{})

  @gift Enum.to_list(1..12)
        |> Enum.zip(["and a Partridge in a Pear Tree", "two Turtle Doves", "three French Hens", "four Calling Birds",
                    "five Gold Rings", "six Geese-a-Laying", "seven Swans-a-Swimming", "eight Maids-a-Milking",
                    "nine Ladies Dancing", "ten Lords-a-Leaping", "eleven Pipers Piping", "twelve Drummers Drumming"])
        |> Enum.into(%{})

  @first_part "On the _count_ day of Christmas my true love gave to me, "

  @spec verse(number :: integer) :: String.t()
  def verse(1), do: format_first_part() <> "a Partridge in a Pear Tree."
  def verse(number), do: format_first_part(number) <> descending_gift_list(number) <> "."

  @doc """
  Given a `starting_verse` and an `ending_verse`, return the verses for each
  included day, one per line.
  """
  @spec verses(starting_verse :: integer, ending_verse :: integer) :: String.t()
  def verses(first, last), do: first..last |> Enum.map(fn n -> verse(n) end) |> Enum.join("\n")

  @doc """
  Sing all 12 verses, in order, one verse per line.
  """
  @spec sing():: String.t()
  def sing, do: verses(1, 12)

  defp format_first_part(day \\ 1), do: String.replace(@first_part, ~r/_count_/, @day[day])
  defp descending_gift_list(number), do: number..1 |> Enum.map(fn n -> @gift[n] end) |> Enum.join(", ")
end

