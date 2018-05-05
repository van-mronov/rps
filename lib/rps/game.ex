defmodule RPS.Game do

  @enforce_keys [:rounds]
  defstruct rounds: nil, scores: %{}, result: nil

  alias RPS.{Game, Round}

  @doc """
  Creates a game with `duration` rounds.
  """
  def new(duration) when is_integer(duration) do
    rounds = for _round <- 1..duration, do: %Round{}
    %Game{rounds: rounds}
  end
end
