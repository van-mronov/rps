defmodule Rps.Round do
  @moduledoc """
  Module implements a basic logic of the Rock-Paper-Scissors game round.
  """

  defstruct first_player_choice: nil, second_player_choice: nil, result: nil

  alias Rps.Round

  @doc """
  Creates a blank game round.

  ## Examples

      iex> Rps.Round.new()
      #Round<first_player_choice: nil, second_player_choice: nil, result: nil>

  """
  def new, do: %Round{}

  @doc """
  Updates the player's choice.

  ## Examples

      iex> round = Rps.Round.new()
      iex> Rps.Round.player_choice(round, :first, :rock)
      #Round<first_player_choice: :rock, second_player_choice: nil, result: nil>

      iex> round = Rps.Round.new()
      iex> Rps.Round.player_choice(round, :second, :paper)
      #Round<first_player_choice: nil, second_player_choice: :paper, result: nil>

  """
  def player_choice(round, :first, choice), do: %{round | first_player_choice: choice}
  def player_choice(round, :second, choice), do: %{round | second_player_choice: choice}

  @doc """
  Updates the round's result.

  ## Examples

      iex> Rps.Round.new()
      ...> |> Rps.Round.player_choice(:first, :rock)
      ...> |> Rps.Round.player_choice(:second, :rock)
      ...> |> Rps.Round.update_result()
      #Round<first_player_choice: :rock, second_player_choice: :rock, result: :draw>

      iex> Rps.Round.new()
      ...> |> Rps.Round.player_choice(:first, :rock)
      ...> |> Rps.Round.player_choice(:second, :scissors)
      ...> |> Rps.Round.update_result()
      #Round<first_player_choice: :rock, second_player_choice: :scissors, result: :first>

  """
  def update_result(%Round{first_player_choice: choice, second_player_choice: choice} = round),
    do: %{round | result: :draw}

  def update_result(%Round{first_player_choice: :rock, second_player_choice: :paper} = round),
    do: %{round | result: :second}

  def update_result(%Round{first_player_choice: :rock, second_player_choice: :scissors} = round),
    do: %{round | result: :first}

  def update_result(%Round{first_player_choice: :paper, second_player_choice: :rock} = round),
    do: %{round | result: :first}

  def update_result(%Round{first_player_choice: :paper, second_player_choice: :scissors} = round),
    do: %{round | result: :second}

  def update_result(%Round{first_player_choice: :scissors, second_player_choice: :rock} = round),
    do: %{round | result: :second}

  def update_result(%Round{first_player_choice: :scissors, second_player_choice: :paper} = round),
    do: %{round | result: :first}

  @doc false
  def to_doc(%Round{first_player_choice: fpc, second_player_choice: spc, result: result}) do
    "first_player_choice: #{inspect(fpc)}, second_player_choice: #{inspect(spc)}, result: #{
      inspect(result)
    }"
  end
end

defimpl Inspect, for: Rps.Round do
  def inspect(round, _opts), do: "#Round<" <> Rps.Round.to_doc(round) <> ">"
end
