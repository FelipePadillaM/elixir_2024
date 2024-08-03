defmodule TodoList.TaskManager do
  @task_file "tasks.txt"

    @doc """
  Fetch all tasks from the file.
  """
  def get_all_tasks do
    @task_file  # Use the constant file path
    |> File.read!()  # Read the entire contents of the file
    |> String.split("\n", trim: true)  # Split the content into lines, removing empty lines
    |> Enum.map(&parse_task/1)  # Parse each line into a task struct
  end

  @doc """
  Fetch a task by ID.
  """
  def get_task(id) do
    get_all_tasks()  # Get all tasks
    |> Enum.find(fn task -> task.id == id end)  # Find the task with the matching ID
  end

  @doc """
  Create a new task and save it to the file.
  """
  def create_task(%{"title" => title}) do
    id = UUID.uuid4()  # Generate a new UUID for the task
    task = %{id: id, title: title, completed: false}  # Create a new task struct
    save_task(task)  # Save the new task to the file
    {:ok, task}  # Return the created task
  end

  @doc """
  Mark a task as complete.
  """
  def complete_task(id) do
    tasks = get_all_tasks()  # Get all tasks
    updated_tasks = Enum.map(tasks, fn task ->
      if task.id == id do
        %{task | completed: true}  # If the task ID matches, mark it as completed
      else
        task  # Otherwise, return the task unchanged
      end
    end)
    save_all_tasks(updated_tasks)  # Save all tasks with the updated one
    {:ok, Enum.find(updated_tasks, fn task -> task.id == id end)}  # Return the updated task
  end

  @doc """
  Delete a task by ID.
  """
  def delete_task(id) do
    tasks = get_all_tasks()  # Get all tasks
    updated_tasks = Enum.reject(tasks, fn task -> task.id == id end)  # Remove the task with the matching ID
    save_all_tasks(updated_tasks)  # Save the remaining tasks
    :ok  # Return :ok to indicate successful deletion
  end

  # Private function to parse a single task from a string
  defp parse_task(line) do
    [id, title, completed] = String.split(line, ",")  # Split the line into components
    %{id: id, title: title, completed: completed == "true"}  # Create a task struct
  end

  # Private function to save a single task to the file
  defp save_task(task) do
    File.write!(@task_file, "#{task.id},#{task.title},#{task.completed}\n", [:append])  # Append the task to the file
  end

  # Private function to save all tasks to the file
  defp save_all_tasks(tasks) do
    content = Enum.map(tasks, fn task -> "#{task.id},#{task.title},#{task.completed}" end)
    |> Enum.join("\n")  # Convert tasks to strings and join with newlines
    File.write!(@task_file, content)  # Write all tasks to the file, overwriting existing content
  end
end
