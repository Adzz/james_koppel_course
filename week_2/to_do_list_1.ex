# Your task is to design the data layer for a to-do list app.
# Create the core data structures that track state, along with
# an API that can be connected to any frontend (command-line, web, desktop GUI, etc).
# Initial Design
# In the basic version, a task is either done or not done. A user should be able
# to create and delete todo items, view the list to do, and mark items as done.

defmodule ToDo.List do
  defstruct [:task_list]

  def add_task(list = %__MODULE__{task_list: tasks}, task) do
    new_task_list = Enum.sort_by([task | tasks], & &1.order)
    %{list | task_list: new_task_list}
  end

  def delete_task(list, %{id: task_id}) do
    new_task_list = Enum.reject(list.task_list, fn %{id: id} -> id == task_id end)
    %{list | task_list: new_task_list}
  end

  def view(list) do
    list.task_list
  end

  def complete_task(list, task) do
    list
    |> delete_task(task)
    |> add_task(ToDo.Task.mark_task_complete(task))
  end
end

defmodule ToDo.Task do
  defstruct [:order, :description, :id, completed?: false]

  def mark_task_complete(task) do
    %{task | completed?: true}
  end
end

# Examples
task1 = %ToDo.Task{order: 2, description: "skjfbh", id: 1}
list = %ToDo.List{task_list: [task1]}
task = %ToDo.Task{order: 1, description: "skjfbh", id: 2}
ToDo.List.add_task(list, task)
ToDo.List.delete_task(list, task)
ToDo.List.view(list)
ToDo.List.complete_task(list, task1)
