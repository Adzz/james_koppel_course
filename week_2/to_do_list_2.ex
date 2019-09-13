# First round of feature requests
# Extend your design to support two of the following features:

# Assigning more statuses to todo items (e.g.: in-progress, under review, blocked)
# Assign priorities to todo items
# Adding stickers to todo items
# Adding due dates to todo items
# Make sure your new design makes it easy to filter and display to-do items in whatever way the user may reasonably expect.

# We choose:
# Assigning more statuses to todo items (e.g.: in-progress, under review, blocked)
# Assign priorities to todo items
defmodule ToDo.List do
  defstruct [:task_list]

  def view(list), do: list

  def add_task(list = %ToDo.List{task_list: tasks}, task) do
    update_list(list, [task | tasks])
  end

  def delete_task(list = %ToDo.List{task_list: tasks}, %ToDo.Task{id: task_id}) do
    new_task_list = Enum.reject(tasks, fn %{id: id} -> id == task_id end)
    update_list(list, new_task_list)
  end

  def complete_task(list, task) do
    list
    |> delete_task(task)
    |> add_task(ToDo.Task.mark_task_complete(task))
  end

  def sort_by(list = %ToDo.List{task_list: tasks}, :priority) do
    new_task_list =
      Enum.map(tasks, fn task = %{priority: priority} ->
        %{task | order: priority}
      end)

    update_list(list, new_task_list)
  end

  def sort_by(list = %ToDo.List{task_list: tasks}, :date_created) do
    new_task_list =
      Enum.map(tasks, fn task = %{id: id} ->
        %{task | order: id}
      end)

    update_list(list, new_task_list)
  end

  defp update_list(list, new_task_list), do: %{list | task_list: order_task_list(new_task_list)}
  defp order_task_list(task_list), do: Enum.sort_by(task_list, & &1.order)
end

defmodule ToDo.Task do
  @completed "Completed"
  @in_progress "In Progress"
  @in_review "In Review"
  @blocked "Blocked"
  # I've opted to separate order and urgency. You may have a less urgent task that you opt to do first,
  # meaning the order could be lower (and so the task could come first) even if the priority is higher.
  defstruct [:order, :description, :id, :status, :priority]

  def mark_task_complete(task), do: %{task | status: @completed}
  def statuses(), do: [@completed, @in_progress, @in_review, @blocked]
end

task1 = %ToDo.Task{order: 2, description: "Jam", id: 1, priority: 1}
task2 = %ToDo.Task{order: 1, description: "trousers", id: 2, priority: 3}
task3 = %ToDo.Task{order: 3, description: "iron", id: 3, priority: 2}
task4 = %ToDo.Task{order: 4, description: "eggs", id: 4, priority: 7}
task5 = %ToDo.Task{order: 5, description: "Rum Ham", id: 5, priority: 4}

%ToDo.List{task_list: [task1]}
|> ToDo.List.add_task(task2)
|> ToDo.List.add_task(task3)
|> ToDo.List.add_task(task4)
|> ToDo.List.add_task(task5)
|> ToDo.List.delete_task(task2)
|> ToDo.List.complete_task(task1)
|> ToDo.List.sort_by(:priority)
|> ToDo.List.sort_by(:date_created)
