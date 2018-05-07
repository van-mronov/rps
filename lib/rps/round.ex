defmodule RPS.Round do
  defstruct first_player_choice: nil, second_player_choice: nil, result: nil

  alias RPS.Round

  @doc """
  Creates a blank game round.

  ## Examples

      iex> RPS.Round.new()
      #Round<first_player_choice: nil, second_player_choice: nil, result: nil>

  """
  def new do
    %Round{}
  end

  def player_choice(round, :first, choice) do
    %{round | first_player_choice: choice}
  end

  def player_choice(round, :second, choice) do
    %{round | second_player_choice: choice}
  end

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
    "first_player_choice: #{inspect fpc}, second_player_choice: #{inspect spc}, result: #{inspect result}"
  end
end

defimpl Inspect, for: RPS.Round do
  def inspect(round, _opts) do
    "#Round<" <> RPS.Round.to_doc(round) <> ">"
  end
end
