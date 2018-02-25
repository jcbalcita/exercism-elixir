defmodule Poker do
  @doc """
  Given a list of poker hands, return a list containing the highest scoring hand.

  If two or more hands tie, return the list of tied hands in the order they were received.

  The basic rules and hand rankings for Poker can be found at:

  https://en.wikipedia.org/wiki/List_of_poker_hands

  For this exercise, we'll consider the game to be using no Jokers,
  so five-of-a-kind hands will not be tested. We will also consider
  the game to be using multiple decks, so it is possible for multiple
  players to have identical cards.

  Aces can be used in low (A 2 3 4 5) or high (10 J Q K A) straights, but do not count as
  a high card in the former case.

  For example, (A 2 3 4 5) will lose to (2 3 4 5 6).

  You can also assume all inputs will be valid, and do not need to perform error checking
  when parsing card values. All hands will be a list of 5 strings, containing a number
  (or letter) for the rank, followed by the suit.

  Ranks (lowest to highest): 2 3 4 5 6 7 8 9 10 J Q K A
  Suits (order doesn't matter): C D H S

  Example hand: ~w(4S 5H 4C 5D 4H) # Full house, 5s over 4s
  """

  defmodule Card do
  @moduledoc """
  Card. Keeps information like suit, rank, and string rank handy and easily accessible.
  """
    @type t :: %Card{suit: String.t, rank: integer, str_rank: String.t}
    defstruct suit: nil, rank: nil, str_rank: nil

    @str_rank_to_int ~w(2 3 4 5 6 7 8 9 10 J Q K A) |> Enum.zip(2..14 |> Enum.to_list) |> Enum.into(%{})

    @spec new(String.t) :: Card.t
    def new(str) do
      [_, str_rank, suit] = Regex.run(~r/([0-9]{1,2}|[A-Z]{1})([a-zA-Z])/, str)
      %Card{suit: suit, str_rank: str_rank, rank: @str_rank_to_int[str_rank]}
    end

    def to_string(card), do: card.str_rank <> card.suit
  end


  defmodule Hand do
    @moduledoc """
    Hand, the ability to analyze and compare poker hands from a list of cards.
    """
    @type t :: %Hand{high_hand: {atom, list(integer)}, cards: list(Cards.t)}
    defstruct high_hand: nil, cards: nil

    @poker_hands [:high_card, :one_pair, :two_pair, :three_of_a_kind, :straight, :flush, :full_house, :four_of_a_kind, :straight_flush]

    @spec new(list(Card.t)) :: Hand.t
    def new(cards) do
      %Hand{cards: cards}
      |> add_high_hand
    end

    @spec determine_winning_hands(list(Hand.t)) :: list(Hand.t)
    def determine_winning_hands(hands) do
      %{high_hand: {hh, ranks}} = hands |> Enum.max_by(&rank_of_hand/1)
      maybe_tied_hands = Enum.filter(hands, fn %{high_hand: {hh_, _}} -> hh_ == hh end)

      case Enum.count(maybe_tied_hands) > 1 do
        true  -> break_tie(maybe_tied_hands, Enum.count(ranks))
        false -> maybe_tied_hands
      end
    end

    defp break_tie(tied_hands, num_ranks) do
      tied_hands
      |> Enum.map(fn hand -> {hand, elem(hand.high_hand, 1)} end)
      |> compare_ranks(num_ranks, 0)
      |> Enum.map(&elem(&1, 0))
    end

    @spec compare_ranks(list({Hand.t, list(integer)}), integer, integer) :: list({list(integer), Hand.t})
    defp compare_ranks(hand_rank_tuples, len, i) when i == len, do: hand_rank_tuples
    defp compare_ranks(hand_rank_tuples, len, i) do
      high_rank_for_round = hand_rank_tuples |> Enum.max_by(fn t -> Enum.at(elem(t, 1), i) end) |> elem(1) |> Enum.at(i)

      hand_rank_tuples
      |> Enum.filter(fn t -> Enum.at(elem(t, 1), i) == high_rank_for_round end)
      |> compare_ranks(len, i + 1)
    end

    @spec add_high_hand(Hand.t) :: Hand.t
    defp add_high_hand(hand) do
      basic_cards =
        hand.cards
        |> Enum.map(fn c -> {c.rank, c.suit} end)
        |> Enum.sort |> Enum.chunk_by(fn {r, _} -> r end) |> Enum.sort_by(&-Enum.count(&1)) |> List.flatten

      %Hand{hand | high_hand: high_hand(basic_cards)}
    end

    @spec high_hand(list({integer, String.t})) :: {atom, list(integer)}
    defp high_hand([{a, s}, {b, s}, {c, s}, {d, s}, {e, s}]), do: flush_or_straight_flush?(sort_ [a, b, c, d, e])
    defp high_hand([{a, _}, {a, _}, {a, _}, {a, _}, {b, _}]), do: {:four_of_a_kind, [a, b]}
    defp high_hand([{a, _}, {a, _}, {a, _}, {b, _}, {b, _}]), do: {:full_house, [a, b]}
    defp high_hand([{a, _}, {a, _}, {a, _}, {b, _}, {c, _}]), do: {:three_of_a_kind, [a] ++ sort_ [b, c]}
    defp high_hand([{a, _}, {a, _}, {b, _}, {b, _}, {c, _}]), do: {:two_pair, sort_([a, b]) ++ [c]}
    defp high_hand([{a, _}, {a, _}, {b, _}, {c, _}, {d, _}]), do: {:one_pair, [a] ++ sort_ [b, c, d]}
    defp high_hand([{a, _}, {b, _}, {c, _}, {d, _}, {e, _}]), do: straight_or_high_card?(sort_ [a, b, c, d, e])

    defp straight_or_high_card?(ranks) do
      if is_straight?(ranks), do: {:straight, high_for_straight(ranks)}, else: {:high_card, ranks}
    end

    defp flush_or_straight_flush?(ranks) do
      if is_straight?(ranks), do: {:straight_flush, high_for_straight(ranks)}, else: {:flush, ranks}
    end

    defp is_straight?(ranks) do
      replaced_ace = ranks |> Enum.map(fn r -> if r == 14, do: 1, else: r end)
      consecutive?(ranks) || consecutive?(replaced_ace)
    end

    defp consecutive?(ranks), do: Enum.max(ranks) - Enum.min(ranks) == 4

    defp high_for_straight([14, x, _, _, 2]), do: [x]
    defp high_for_straight([x | _]), do: [x]

    defp sort_(list), do: list |> Enum.sort(&(&1 >= &2))

    defp rank_of_hand(hand), do: Enum.find_index(@poker_hands, fn p -> p == elem(hand.high_hand, 0) end)
  end

  @spec best_hand(list(list(String.t()))) :: list(list(String.t()))
  def best_hand(raw_hands) do
    raw_hands
    |> Enum.map(&transform_to_hand/1)
    |> Hand.determine_winning_hands
    |> Enum.map(&transform_to_raw_hand/1)
  end

  @spec transform_to_hand(list(String.t)) :: list(Card.t)
  defp transform_to_hand(raw_hand), do: raw_hand |> Enum.map(&Card.new/1) |> Hand.new

  @spec transform_to_raw_hand(list(Card.t)) :: list(String.t)
  defp transform_to_raw_hand(hand), do: Enum.map(hand.cards, &Card.to_string/1)
end
