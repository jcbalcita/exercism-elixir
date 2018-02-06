defmodule SpaceAge do
  @type planet :: :mercury | :venus | :earth | :mars | :jupiter
                | :saturn | :uranus | :neptune

  @doc """
  Return the number of years a person that has lived for 'seconds' seconds is
  aged on 'planet'.
  """
  @spec age_on(planet, pos_integer) :: float
  def age_on(planet, seconds) do
    years = seconds / 60 / 60 / 24 / 365.25

    case planet do
      :mercury -> years / 0.2408467
      :venus   -> years / 0.61519726
      :earth   -> years
      :mars    -> years / 1.8808158
      :jupiter -> years / 11.862615
      :saturn  -> years / 29.447498
      :uranus  -> years / 84.016846
      :neptune -> years / 164.79132
      :pluto   -> {:error, "Pluto is not a planet"}
      _        -> {:error, "Please enter a planet in our solar system as an atom"}
    end
  end
end
