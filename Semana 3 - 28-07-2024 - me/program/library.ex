defmodule Library do
  defmodule Book do
    defstruct title: "", author: "", isbn: "", available: true
  end

  defmodule User do
    defstruct name: "", id: "", borrowed_books: []
  end

  #Agregar libro
  def add_book(library, %Book{} = book) do
    library ++ [book]
  end

  #Agregar usuario
  def add_user(users, %User{} = user) do
    users ++ [user]
  end

  #Prestar libro
  def borrow_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(library, &(&1.isbn == isbn && &1.available))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no disponible"}
      true ->
        updated_book = %{book | available: false}
        updated_user = %{user | borrowed_books: user.borrowed_books ++ [updated_book]}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  #Devolver libro
  def return_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(user.borrowed_books, &(&1.isbn == isbn))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no encontrado en los libros prestados del usuario"}
      true ->
        updated_book = %{book | available: true}
        updated_user = %{user | borrowed_books: Enum.filter(user.borrowed_books, &(&1.isbn != isbn))}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  #Listar libros
  def list_books(library) do
    library
  end

  #Listar usuarios
  def list_users(users) do
    users
  end

  #Listar libros prestados por usuario
  def books_borrowed_by_user(users, user_id) do
    user = Enum.find(users, &(&1.id == user_id))
    if user, do: user.borrowed_books, else: []
  end

  #Verificar disponibilidad de libro
  def check_book_availability(library, isbn) do
    book = Enum.find(library, &(&1.isbn == isbn))
    if book do
      IO.puts("El libro '#{book.title}' está #{if book.available, do: "disponible", else: "no disponible"}.")
    else
      IO.puts("Libro no encontrado.")
    end
  end

  # Starting loop
  def run do
    library = []
    users = []
    loop(library, users)
  end

  defp loop(library, users) do
    IO.puts("""
    Sistema de gestion de bibliotecas
    ***Gestion de libros***
      1. Agregar Libro
      2. Listar libros
      3. Verificar disponibilidad de libro
    ***Gestion de usuarios***
      4. Registrar Usuario
      5. Listar usuarios
    ***Prestamo de libros***
      6. Prestar libro
      7. Devolver libro
      8. Listar libros prestados por usuario

    9. Salir
    """)

    IO.write("Seleccione una opción: ")
    option = IO.gets("") |> String.trim() |> String.to_integer()

    case option do
      1 ->
        IO.write("Ingrese el título del libro: ")
        title = IO.gets("") |> String.trim()
        IO.write("Ingrese el autor del libro: ")
        author = IO.gets("") |> String.trim()
        IO.write("Ingrese el ISBN del libro: ")
        isbn = IO.gets("") |> String.trim()

        book = %Book{title: title, author: author, isbn: isbn}
        library = add_book(library, book)
        loop(library, users)

        2 ->
          IO.inspect(list_books(library))
          loop(library, users)

        3 ->
          IO.write("Ingrese el ISBN del libro: ")
          isbn = IO.gets("") |> String.trim()
          check_book_availability(library, isbn)
          loop(library, users)

        4 ->
          IO.write("Ingrese el nombre del usuario: ")
          name = IO.gets("") |> String.trim()
          IO.write("Ingrese el ID del usuario: ")
          id = IO.gets("") |> String.trim()

          user = %User{name: name, id: id}
          users = add_user(users, user)
          loop(library, users)

        5 ->
          IO.inspect(list_users(users))
          loop(library, users)

        6 ->
          IO.write("Ingrese el ID del usuario: ")
          user_id = IO.gets("") |> String.trim()
          IO.write("Ingrese el ISBN del libro: ")
          isbn = IO.gets("") |> String.trim()

          case borrow_book(library, users, user_id, isbn) do
            {:ok, new_library, new_users} ->
              IO.puts("Libro prestado exitosamente.")
              loop(new_library, new_users)
            {:error, msg} ->
              IO.puts(msg)
              loop(library, users)
          end

        7 ->
          IO.write("Ingrese el ID del usuario: ")
          user_id = IO.gets("") |> String.trim()
          IO.write("Ingrese el ISBN del libro: ")
          isbn = IO.gets("") |> String.trim()

          case return_book(library, users, user_id, isbn) do
            {:ok, new_library, new_users} ->
              IO.puts("Libro devuelto exitosamente.")
              loop(new_library, new_users)
            {:error, msg} ->
              IO.puts(msg)
              loop(library, users)
          end

        8 ->
          IO.write("Ingrese el ID del usuario: ")
          user_id = IO.gets("") |> String.trim()
          borrowed_books = books_borrowed_by_user(users, user_id)
          IO.inspect(borrowed_books)
          loop(library, users)


      9 ->
        IO.puts("¡Adiós!")
        :ok

      _ ->
        IO.puts("Opción no válida.")
        loop(library, users)
    end
  end
end

# Ejecutar el gestor de tareas
Library.run()
