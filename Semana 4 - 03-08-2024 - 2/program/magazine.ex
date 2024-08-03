defmodule Magazine do
  @moduledoc """
  Módulo que representa una revista que maneja suscriptores y notificaciones de nuevas publicaciones.
  """

  @doc """
  Inicia el proceso de la revista.
  """
  def start do
    spawn(fn -> loop([]) end)
  end

  @doc """
  Suscribe un nuevo suscriptor a la revista.

  ## Parámetros
  - `magazine_pid`: PID del proceso de la revista.
  - `subscriber_pid`: PID del proceso del suscriptor.
  """
  def subscribe(magazine_pid, subscriber_pid) do
    send(magazine_pid, {:subscribe, subscriber_pid})
  end

  @doc """
  Desuscribe un suscriptor de la revista.

  ## Parámetros
  - `magazine_pid`: PID del proceso de la revista.
  - `subscriber_pid`: PID del proceso del suscriptor.
  """
  def unsubscribe(magazine_pid, subscriber_pid) do
    send(magazine_pid, {:unsubscribe, subscriber_pid})
  end

  @doc """
  Publica un nuevo número de la revista.

  ## Parámetros
  - `magazine_pid`: PID del proceso de la revista.
  - `issue`: Número de la revista a publicar.
  """
  def publish(magazine_pid, issue) do
    send(magazine_pid, {:publish, issue})
  end

  @doc false
  defp loop(subscribers) do
    receive do
      {:subscribe, subscriber_pid} ->
        IO.puts("New subscriber added")
        loop([subscriber_pid | subscribers])

      {:unsubscribe, subscriber_pid} ->
        IO.puts("Subscriber removed")
        loop(List.delete(subscribers, subscriber_pid))

      {:publish, issue} ->
        IO.puts("Publishing new issue: #{issue}")
        Enum.each(subscribers, fn subscriber ->
          send(subscriber, {:new_issue, issue})
        end)
        loop(subscribers)

      _ ->
        IO.puts("Invalid Message")
        loop(subscribers)
    end
  end
end

defmodule Subscriber do
  @moduledoc """
  Módulo que representa a un suscriptor de la revista.
  """

  @doc """
  Inicia un proceso de suscriptor.

  ## Parámetros
  - `name`: Nombre del suscriptor.
  """
  def start(name) do
    spawn(fn -> loop(name) end)
  end

  @doc false
  def loop(name) do
    receive do
      {:new_issue, issue} ->
        IO.puts("#{name} received new issue: #{issue}")
        loop(name)

      _ ->
        IO.puts("Invalid Message")
        loop(name)
    end
  end
end

# Ejemplo de uso
# magazine_pid = Magazine.start()

# subscriber1 = Subscriber.start("Alice")
# subscriber2 = Subscriber.start("Bob")

# Magazine.subscribe(magazine_pid, subscriber1)
# Magazine.subscribe(magazine_pid, subscriber2)

# Magazine.publish(magazine_pid, "Issue #1")

# Magazine.unsubscribe(magazine_pid, subscriber1)

# Magazine.publish(magazine_pid, "Issue #2")
