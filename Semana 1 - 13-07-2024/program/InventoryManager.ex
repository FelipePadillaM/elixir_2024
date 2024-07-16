defmodule InventoryManager do
  defstruct inventory: [], cart: []

  def add_product(
    %InventoryManager{inventory: inventory} = inventoryManager,
    name,
    price,
    stock) do
    id = Enum.count(inventory) + 1
    product = %{id: id, name: name, price: price, stock: stock}
    %{inventoryManager | inventory: inventory ++ [product]}
  end

  def list_products(%InventoryManager{inventory: inventory}) do
    Enum.each(inventory, fn product ->
      IO.puts("""
                Id:          #{product.id}
                Producto:    #{product.name}
                precio:      #{product.price}
                stock:       #{product.stock}
              """)
    end)
  end

  def increase_stock(
    %InventoryManager{inventory: inventory} = inventory_manager,
    id,
    quantity) do
    updated_inventory = Enum.map(inventory, fn product ->
      if product.id == id do
        %{product | stock: product.stock + quantity}
      else
        product
      end
    end)
    %{inventory_manager | inventory: updated_inventory}
  end

  def sell_product(
  %InventoryManager{inventory: inventory, cart: cart} = inventory_manager,
  id,
  quantity
) do
  # verificar stock suficiente
  stock_suficiente = Enum.any?(inventory, fn product -> product.id == id and (product.stock - quantity) >= 0 end)

  # Actualizar inventario solo si hay stock suficiente
  updated_inventory = if stock_suficiente do
    Enum.map(inventory, fn product ->
      if product.id == id do
        %{product | stock: product.stock - quantity}
      else
        product
      end
    end)
  else
    IO.puts("Producto: #{id} con stock insuficiente")
    inventory
  end

  # Actualizar carrito solo si hay stock suficiente
  updated_cart = if stock_suficiente do
    if Enum.any?(cart, fn {id_producto_cart, _} -> id == id_producto_cart end) do
      Enum.map(cart, fn {id_producto_cart, existing_quantity} ->
        if id == id_producto_cart do
          {id, existing_quantity + quantity}
        else
          {id_producto_cart, existing_quantity}
        end
      end)
    else
      [{id, quantity} | cart]
    end
  else
    cart
  end

  # Retornar el objeto actualizado
  %{inventory_manager | inventory: updated_inventory, cart: updated_cart}
end

  def view_cart(%InventoryManager{inventory: _, cart: cart}) do
    Enum.each(cart, fn {id, quantity} ->
      IO.puts("""
                Id:          #{id}
                cantidad:    #{quantity}
              """)
    end)
  end

  def checkout(%InventoryManager{inventory: inventory, cart: cart} = inventory_manager) do
    total = Enum.reduce(cart, 0, fn {id, quantity}, acc ->
      case Enum.find(inventory, fn product -> product.id == id end) do
        nil ->
          IO.puts("Producto con id #{id} no encontrado en el inventario")
          acc

        %{} = product ->
          total_value = product.price * quantity
          IO.puts("ID: #{product.id}, Nombre: #{product.name}, Valor: $#{total_value}")
          acc + total_value
      end
    end)

    IO.puts("Valor total del carrito: $#{total}")
    %{inventory_manager | cart: []}
  end

  def run do
    inventoryManager = %InventoryManager{}
    loop(inventoryManager)
  end

  defp loop(inventoryManager) do
    IO.puts("""
    Gestor de Inventario
    1. Agregar Producto
    2. Listar Productos
    3. Aumentar stock de producto
    4. Agregar producto al carrito
    5. Ver productos del carrito
    6. Comprar productos del carrito
    7. Salir
    """)

    IO.write("Seleccione una opción: ")
    option = IO.gets("") |> String.trim() |> String.to_integer()

    case option do
      1 ->
        IO.write("Ingrese el nombre del producto: ")
        name = IO.gets("") |> String.trim()
        IO.write("Ingrese el precio del producto: ")
        price = IO.gets("") |> String.trim() |> String.to_integer()
        IO.write("Ingrese el stock del producto: ")
        stock = IO.gets("") |> String.trim() |> String.to_integer()
        inventoryManager = add_product(inventoryManager, name, price, stock)
        loop(inventoryManager)

      2 ->
        list_products(inventoryManager)
        loop(inventoryManager)

      3 ->
        IO.write("Ingrese el ID del producto para aumento de stock: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()
        IO.write("Ingrese la cantidad a adicionar en stock del producto: ")
        quantity = IO.gets("") |> String.trim() |> String.to_integer()
        inventoryManager = increase_stock(inventoryManager, id, quantity)
        loop(inventoryManager)

      4 ->
        IO.write("Ingrese el ID del producto para agregar al carrito: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()
        IO.write("Ingrese la cantidad del producto a agregar: ")
        quantity = IO.gets("") |> String.trim() |> String.to_integer()
        inventoryManager = sell_product(inventoryManager, id, quantity)
        loop(inventoryManager)

      5 ->
        view_cart(inventoryManager)
        loop(inventoryManager)

      6 ->
        inventoryManager = checkout(inventoryManager)
        loop(inventoryManager)

      7 ->
        IO.puts("¡Adiós!")
        :ok

      _ ->
        IO.puts("Opción no válida.")
        loop(inventoryManager)
    end
  end
end

# Ejecutar el gestor de tareas
InventoryManager.run()
