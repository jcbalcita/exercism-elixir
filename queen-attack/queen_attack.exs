defmodule Queens do
  @type t :: %Queens{ black: {integer, integer}, white: {integer, integer} }
  defstruct black: nil, white: nil

  @doc """
  Creates a new set of Queens
  """
  @spec new() :: Queens.t()
  @spec new({integer, integer}, {integer, integer}) :: Queens.t()
  def new,               do: %Queens{black: {7, 3}, white: {0, 3}}
  def new(same, same),   do: raise ArgumentError
  def new(white, black), do: %Queens{white: white, black: black}

  @doc """
  Gives a string reprentation of the board with
  white and black queen locations shown
  """
  @spec to_string(Queens.t()) :: String.t()
  def to_string({black: {row, col}, white: {row_, col_}}) do
    List.duplicate("_", 8) |> List.duplicate(8)
    |> List.update_at(row,  fn b -> List.update_at(b, col,  fn _ -> "B" end) end)
    |> List.update_at(row_, fn w -> List.update_at(w, col_, fn _ -> "W" end) end)
    |> Enum.map(&Enum.join(&1, " "))
    |> Enum.join("\n")
  end

  @doc """
  Checks if the queens can attack each other
  """
  @spec can_attack?(Queens.t()) :: boolean
  def can_attack?(%{black: {row, _}, white: {row, _}}), do: true
  def can_attack?(%{black: {_, col}, white: {_, col}}), do: true
  def can_attack?(%{black: {row, col}, white: {row_, col_}}) do
    abs(row - row_) == abs(col - col_)
  end
end
