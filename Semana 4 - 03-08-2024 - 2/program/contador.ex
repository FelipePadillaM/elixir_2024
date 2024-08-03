defmodule Contador do
  def iniciar do
    # Inicia el proceso controlador
    controlador_pid = spawn(fn -> controlador() end)

    # Inicia el proceso contador y envía el primer valor al controlador
    spawn(fn -> contador(0, controlador_pid) end)
  end

  defp contador(valor, controlador_pid) do
    send(controlador_pid, {:contador, valor})
    :timer.sleep(1000)  # Duerme por 1 segundo
    contador(valor + 1, controlador_pid)
  end

  defp controlador do
    receive do
      {:contador, valor} ->
        IO.puts("Valor del contador: #{valor}")
        controlador()
    end
  end
end

# Inicia el programa
Contador.iniciar()
