
defmodule GameServer do
  @moduledoc """
  Módulo que representa un servidor de juego que maneja jugadores y sus puntuaciones.
  """

  @doc """
  Inicia el servidor de juego.
  """
  def start do
    spawn(fn -> loop(%{}) end)
  end

  @doc """
  Permite que un jugador se una al servidor de juego.

  ## Parámetros
  - `server_pid`: PID del proceso del servidor.
  - `player_name`: Nombre del jugador que se va a unir.
  """
  def join(server_pid, player_name) do
    send(server_pid, {:join, player_name, self()})
  end

  @doc """
  Actualiza la puntuación de un jugador en el servidor de juego.

  ## Parámetros
  - `server_pid`: PID del proceso del servidor.
  - `player_name`: Nombre del jugador cuya puntuación se va a actualizar.
  - `score`: Puntuación a añadir al jugador.
  """
  def update_score(server_pid, player_name, score) do
    send(server_pid, {:update_score, player_name, score})
  end

  @doc """
  Solicita la tabla de clasificación del servidor de juego.

  ## Parámetros
  - `server_pid`: PID del proceso del servidor.

  ## Retorno
  - Devuelve la tabla de clasificación ordenada por puntuación en orden descendente.
  """
  def leaderboard(server_pid) do
    send(server_pid, {:leaderboard, self()})

    receive do
      {:response, leaderboard} -> leaderboard
    end
  end

  @doc false
  defp loop(state) do
    new_state =
      receive do
        {:join, player_name, player_pid} ->
          send(player_pid, {:joined, player_name})
          Map.put(state, player_name, 0)

        {:update_score, player_name, score} ->
          Map.update(state, player_name, score, &(&1 + score))

        {:leaderboard, caller_pid} ->
          leaderboard = Enum.sort_by(state, &elem(&1, 1), &>=/2)
          send(caller_pid, {:response, leaderboard})
          state

        _ ->
          IO.puts("Invalid Message")
          state
      end

    loop(new_state)
  end
end

defmodule Player do
  @moduledoc """
  Módulo que representa a un jugador en el juego.
  """

  @doc """
  Inicia un proceso de jugador.

  ## Parámetros
  - `name`: Nombre del jugador.
  - `server_pid`: PID del proceso del servidor de juego.
  """
  def start(name, server_pid) do
    spawn(fn -> loop(name, server_pid) end)
  end

  @doc false
  defp loop(name, server_pid) do
    receive do
      {:joined, player_name} ->
        IO.puts("#{player_name} has joined the game!")
        loop(name, server_pid)

      {:update_score, score} ->
        GameServer.update_score(server_pid, name, score)
        loop(name, server_pid)

      {:view_leaderboard} ->
        leaderboard = GameServer.leaderboard(server_pid)
        IO.inspect(leaderboard, label: "Leaderboard")
        loop(name, server_pid)

      _ ->
        IO.puts("Invalid Message")
        loop(name, server_pid)
    end
  end
end
# Example usage
# server_pid = GameServer.start()

# player1 = Player.start("Alice", server_pid)
# player2 = Player.start("Bob", server_pid)

# GameServer.join(server_pid, "Alice")
# GameServer.join(server_pid, "Bob")

# send(player1, {:update_score, 10})
# send(player2, {:update_score, 20})

# send(player1, {:view_leaderboard})
# send(player2, {:view_leaderboard})
