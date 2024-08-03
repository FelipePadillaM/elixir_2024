defmodule Sensor do
  # Función para iniciar el sensor
  def iniciar(controlador_pid, sensor_id) do
    spawn(fn -> leer_temperatura(controlador_pid, sensor_id) end)
  end

  # Función para leer la temperatura y enviarla al controlador
  defp leer_temperatura(controlador_pid, sensor_id) do
    # Genera una temperatura aleatoria entre -10 y 40 grados
    temperatura = :rand.uniform(50) - 10
    send(controlador_pid, {:temperatura, sensor_id, temperatura})
    :timer.sleep(2000)  # Espera por 2 segundos antes de enviar el siguiente valor
    leer_temperatura(controlador_pid, sensor_id)
  end
end

defmodule Controlador do
  # Función para iniciar el controlador
  def iniciar do
    controlador_pid = spawn(fn -> monitorear() end)

    # Inicia varios sensores
    Enum.each(1..5, fn sensor_id ->
      Sensor.iniciar(controlador_pid, sensor_id)
    end)
  end

  # Función para monitorear las temperaturas recibidas
  defp monitorear do
    receive do
      {:temperatura, sensor_id, temperatura} ->
        IO.puts("Sensor #{sensor_id}: Temperatura actual es #{temperatura}°C")
        verificar_alerta(sensor_id, temperatura)
        monitorear()
    end
  end

  # Función para verificar si la temperatura excede un umbral
  defp verificar_alerta(sensor_id, temperatura) do
    if temperatura > 30 do
      IO.puts("¡Alerta! El sensor #{sensor_id} detectó una temperatura alta de #{temperatura}°C")
    end
  end
end

# Inicia el programa
Controlador.iniciar()
