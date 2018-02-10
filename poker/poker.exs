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
    @type t :: %Card{suit: String.t, rank: integer, str_rank: String.t}
    defstruct suit: nil, rank: nil, str_rank: nil

    @str_rank_to_int ~w(2 3 4 5 6 7 8 9 10 J Q K A) |> Enum.zip(2..14 |> Enum.to_list) |> Enum.into(%{})

    @spec new(String.t) :: Card.t
    def new(str) do
      [_, str_rank, suit] = Regex.run(~r/([0-9]{1,2}|[A-Z]{1})([a-zA-Z])/, str)
      %Card{suit: suit, str_rank: str_rank, rank: @str_rank_to_int[str_rank]}
    end

    def get_rank(card), do: card.rank

    def to_s(card) do
      card.str_rank <> card.suit
    end
  end

  defmodule Hand do
    alias Poker.Card

    @poker_hands [:high_card, :one_pair, :two_pair, :three_of_a_kind, :straight, :flush, :full_house, :four_of_a_kind, :straight_flush]

    @type t :: %Hand{high_hand: {atom(), list(integer)}, cards: list(Cards.t)}
    defstruct high_hand: nil, cards: nil

    @spec new(list(Card.t)) :: Hand.t
    def new(cards) do
      %Hand{cards: cards}
      |> find_high_hand
    end

    def find_winning_hands(hands) do
      best_poker_hand = hands |> Enum.max_by(fn h -> Enum.find_index(@poker_hands, fn p -> p == elem(h.high_hand, 0) end) end)
      tied_hands = Enum.filter(hands, fn h -> h.high_hand |> elem(0) == best_poker_hand.high_hand |> elem(0) end)
      cond do
        Enum.count(tied_hands) > 1 -> break_tie(tied_hands)
        true                       -> tied_hands
      end
    end

    def break_tie(tied_hands) do
      hand = tied_hands |> Enum.at(0)
      compare_length = hand.high_hand |> elem(1) |> Enum.count

      tied_hands |> Enum.map(fn hand -> {hand.high_hand |> elem(1), hand} end)
      |> compare_high_cards(compare_length, 0)
      |> Enum.map(fn t -> elem(t, 1) end)
    end

    def compare_high_cards(tpls, len, i) when i == len, do: tpls
    def compare_high_cards(tpls, len, i) do
      high = tpls |> Enum.max_by(fn t -> Enum.at(elem(t, 0), i) end) |> elem(0) |> Enum.at(i)
      filtered = tpls |> Enum.filter(fn t -> Enum.at(elem(t, 0), i) == high end)
      compare_high_cards(filtered, len, i + 1)
    end

    def find_high_hand(hand) do
      basic_cards =
        hand.cards
        |> Enum.map(fn c -> {c.rank, c.suit} end)
        |> Enum.sort |> Enum.chunk_by(fn {r, _} -> r end) |> Enum.sort_by(&-Enum.count(&1)) |> List.flatten

      high = apply(Hand, :high_hand, [basic_cards])
      %Hand{hand | high_hand: high}
    end

    def high_hand([{a, s}, {b, s}, {c, s}, {d, s}, {e, s}]) do
      sorted = sort_([a, b, c, d, e])
      if is_straight?(sorted), do: {:straight_flush, [List.first(sorted)]}, else: {:flush, sorted}
    end
    def high_hand([{a, _}, {a, _}, {a, _}, {a, _}, {b, _}]), do: {:four_of_a_kind, [a, b]}
    def high_hand([{a, _}, {a, _}, {a, _}, {b, _}, {b, _}]), do: {:full_house, [a, b]}
    def high_hand([{a, _}, {a, _}, {a, _}, {b, _}, {c, _}]), do: {:three_of_a_kind, [a | sort_([b, c])]}
    def high_hand([{a, _}, {a, _}, {b, _}, {b, _}, {c, _}]), do: {:two_pair, [sort_([a, b]), c]}
    def high_hand([{a, _}, {a, _}, {b, _}, {c, _}, {d, _}]), do: {:one_pair, [a | sort_([b, c, d])]}
    def high_hand([{a, _}, {b, _}, {c, _}, {d, _}, {e, _}]) do
      sorted = sort_([a, b, c, d, e])
      if is_straight?(sorted), do: {:straight, high_for_straight(sorted)}, else: {:high_card, sorted}
    end

    def sort_(list), do: list |> Enum.sort(&(&1 >= &2))

    def is_straight?(rank_list) do
      replaced_ace = rank_list |> Enum.map(fn r -> if r ==14, do: 1, else: r end)
      consecutive?(rank_list) || consecutive?(replaced_ace)
    end

    def consecutive?(rank_list), do: Enum.max(rank_list) - Enum.min(rank_list) == 4

    def high_for_straight(ranks_desc) do
      case ranks_desc do
        [14, 5, _, _, 2] ->  [5]
        [x,  _, _, _, _]  -> [x]
      end
    end
  end

  @spec best_hand(list(list(String.t()))) :: list(list(String.t()))
  def best_hand(raw_hands) do
    raw_hands
    |> Enum.map(&transform_to_hand(&1))
    |> Hand.find_winning_hands
    |> Enum.map(&transform_to_raw_hand/1)
  end

  defp transform_to_hand(raw_hand), do: raw_hand |> Enum.map(&Card.new/1) |> Hand.new
  defp transform_to_raw_hand(hands), do: Enum.map(hands.cards, &Card.to_s/1)
end
