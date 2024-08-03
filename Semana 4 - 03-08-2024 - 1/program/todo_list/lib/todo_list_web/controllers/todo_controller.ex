defmodule TodoListWeb.TaskController do
  use TodoListWeb, :controller

  alias TodoList.TaskManager

  def index(conn, _params) do
    tasks = TaskManager.get_all_tasks()
    json(conn, tasks)
  end

  def show(conn, %{"id" => id}) do
    case TaskManager.get_task(id) do
      nil -> send_resp(conn, :not_found, "Task not found")
      task -> json(conn, task)
    end
  end

  def create(conn, %{"task" => task_params}) do
    case TaskManager.create_task(task_params) do
      {:ok, task} -> json(conn, task)
      {:error, reason} -> send_resp(conn, :bad_request, reason)
    end
  end

  def complete(conn, %{"id" => id}) do
    case TaskManager.complete_task(id) do
      {:ok, task} -> json(conn, task)
      {:error, reason} -> send_resp(conn, :bad_request, reason)
    end
  end

  def delete(conn, %{"id" => id}) do
    case TaskManager.delete_task(id) do
      :ok -> send_resp(conn, :no_content, "")
      {:error, reason} -> send_resp(conn, :bad_request, reason)
    end
  end
end
