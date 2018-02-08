defmodule BinarySearch do
  @doc """
    Searches for a key in the tuple using the binary search algorithm.
    It returns :not_found if the key is not in the tuple.
    Otherwise returns {:ok, index}.

    ## Examples

      iex> BinarySearch.search({}, 2)
      :not_found

      iex> BinarySearch.search({1, 3, 5}, 2)
      :not_found

      iex> BinarySearch.search({1, 3, 5}, 5)
      {:ok, 2}

  """
  @spec search(tuple, integer) :: {:ok, integer} | :not_found
  def search(numbers, key) do
    search_(numbers, key, 0, tuple_size(numbers) - 1)
  end

  defp search_(_, _, left, right) when right < left, do: :not_found
  defp search_(numbers, key, left, right) do
    mid_idx = (left + right) |> div(2)
    mid_val = elem(numbers, mid_idx)

    cond do
      mid_val == key -> {:ok, mid_idx}
      mid_val >  key -> search_(numbers, key, left, mid_idx - 1)
      mid_val <  key -> search_(numbers, key, mid_idx + 1, right)
    end
  end
end
