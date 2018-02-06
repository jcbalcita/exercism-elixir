defmodule RotationalCipher do
  @doc """
  Given a plaintext and amount to shift by, return a rotated string.

  Example:
  iex> RotationalCipher.rotate("Attack at dawn", 13)
  "Nggnpx ng qnja"
  """

  @spec rotate(text :: String.t(), shift :: integer) :: String.t()
  def rotate(text, shift) do
    alphabet =  ?a..?z |> Enum.to_list |> List.to_string |> String.split("", trim: true)
    cipher_map = create_cipher_map(alphabet, rem(shift, 26))

    Regex.replace(~r/[a-zA-Z]/, text, fn x -> cipher_map[x] end)
  end

  defp create_cipher_map(alphabet, shift) do
    {fst, snd} = alphabet |> Enum.split(shift)
    tuple = alphabet |> Enum.zip(Enum.concat(snd, fst))

    Enum.concat(tuple, Enum.map(tuple, fn ({a, b}) -> {String.upcase(a), String.upcase(b)} end))
    |> Enum.into(%{})
  end
end

