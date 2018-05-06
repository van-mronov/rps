defmodule RPS.Round do
  defstruct first_player_choice: nil, second_player_choice: nil, result: nil

  alias RPS.Round

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
end
