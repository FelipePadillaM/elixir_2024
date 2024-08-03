defmodule PingPong do
  @moduledoc """
  Módulo que implementa un ejemplo de comunicación entre procesos utilizando mensajes `ping` y `pong`.
  """

  @doc """
  Inicia el ejemplo de PingPong.
  """
  def start do
    # Inicia el proceso pong
    pong_pid = spawn(fn -> pong() end)

    # Inicia el proceso ping y envía el primer mensaje a pong
    spawn(fn -> ping(pong_pid) end)
  end

  @doc false
  defp ping(pong_pid) do
    # Envía un mensaje {:ping, self()} al proceso pong
    send(pong_pid, {:ping, self()})

    receive do
      # Recibe un mensaje {:pong, _from} del proceso pong
      {:pong, _from} ->
        IO.puts("Ping received Pong")
        :timer.sleep(1000)  # Duerme por 1 segundo
        send(pong_pid, {:ping, self()})  # Envía otro mensaje ping
        ping(pong_pid)  # Llama recursivamente a ping/1
    end
  end

  @doc false
  defp pong do
    receive do
      # Recibe un mensaje {:ping, from} del proceso ping
      {:ping, from} ->
        IO.puts("Pong received Ping")
        :timer.sleep(1000)  # Duerme por 1 segundo
        send(from, {:pong, self()})  # Envía un mensaje pong de vuelta
        pong()  # Llama recursivamente a pong/0
    end
  end
end

# Inicia el ejemplo de PingPong
# PingPong.start()
