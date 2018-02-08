defmodule Queens do
  @type t :: %Queens{ black: {integer, integer}, white: {integer, integer} }
  defstruct black: nil, white: nil

  @doc """
  Creates a new set of Queens
  """
  @spec new() :: Queens.t()
  @spec new({integer, integer}, {integer, integer}) :: Queens.t()

  def new, do: %Queens{black: {7, 3}, white: {0, 3}}

  def new(white, black) do
    if white == black, do: raise ArgumentError

    %Queens{white: white, black: black}
  end

  @doc """
  Gives a string reprentation of the board with
  white and black queen locations shown
  """
  @spec to_string(Queens.t()) :: String.t()
  def to_string(%Queens{black: black, white: white} = queens) do
    List.duplicate("_", 8) |> List.duplicate(8)
    |> List.update_at(elem(black, 0), fn b -> List.update_at(b, elem(black, 1), fn _ -> "B" end) end)
    |> List.update_at(elem(white, 0), fn w -> List.update_at(w, elem(white, 1), fn _ -> "W" end) end)
    |> Enum.map(&Enum.join(&1, " "))
    |> Enum.join("\n")
  end

  @doc """
  Checks if the queens can attack each other
  """
  @spec can_attack?(Queens.t()) :: boolean
  def can_attack?(%Queens{black: black, white: white} = queens) do
    is_straight_attack(black, white) || is_diagonal_attack(black, white)
  end

  defp is_straight_attack(black, white) do
    elem(black, 0) == elem(white, 0) || elem(black, 1) == elem(white, 1)
  end

  defp is_diagonal_attack(black, white) do
    elem(black, 0) - elem(white, 0) |> abs == (elem(black, 1) - elem(white, 1)) |> abs
  end
end
