# Third round of feature requests
# Extend your design to support one of the following two features:

# Ability to look up, for all users, how many have a todo item with the same name as one of yours.
# Also, explain how to extend your user interface to display the total number of todo items in the
# list currently being viewed. This feature is simple, but there are some easy ways to get it wrong.

# Ability to go back into the past, and see what a user's todo list looked like at any point in time.
# Explain how this would work for todo lists that already exist.
# =================================================================================================

# I choose the latter, it's interesting because we have to define exactly what a jump forward in time
# is. Like, conceptually for a user, is a sorted list a new list? Or does a step through time simply
# mean each point I add / remove / change the status of a list?

# I think we'd need something like a persistent data structure. I think the simplest way I can think
# of though is to store the state of the list before the action you take on it, and then store the
# result of the action you took. Then you need the concept of the "current view" of that data. A simple
# way is like this:

# %ToDo.List.History{
#   list_history: [
#     %ToDo.List{task_list: [%ToDo.Task{}]}
#   ]
# }
# Then we add a task, and end up with this:
# %ToDo.List.History{
#   list_history: [
#     # The first version of our list:
#     %ToDo.List{task_list: [%ToDo.Task{}]},
#     # The second version:
#     %ToDo.List{task_list: [%ToDo.Task{}, %ToDo.Task{}]},
#   ]
# }
# Effectively what we need to do is introduce for the first time a new kind of list - a persistent list.

# But notice how this now affects what we have written already - with all those calls to `ToDo.List`
# We are currently depending on what was a concrete type. Now that we know it isn't one - there can
# now be many types of lists, we should make that an interface and have different lists obey that
# interface. We can do that like this:

# Then we can think about stepping through time as just traversing history.

defprotocol ToDo.List do
  def view(list, task_type)
  def add_task(list, task)
  def delete_task(list, task)
  def complete_task(list, task)
  def sort_by(list, sorting_factor)
  def step_back(list)
  def step_forward(list)
end

defmodule User do
  defstruct [:id, :name, :friends, :to_do_list, :whitelist]

  def add_task_to_list(user = %User{to_do_list: list}, task) do
    update_user_to_do_list(user, ToDo.List.add_task(list, task))
  end

  def delete_task_from_list(user = %User{to_do_list: list}, task) do
    update_user_to_do_list(user, ToDo.List.delete_task(list, task))
  end

  def complete_task_on_list(user = %User{to_do_list: list}, task) do
    update_user_to_do_list(user, ToDo.List.complete_task(list, task))
  end

  def sort_list(user = %User{to_do_list: list}, sorting_factor) do
    update_user_to_do_list(user, ToDo.List.sort_by(list, sorting_factor))
  end

  def view_list(%User{id: my_id}, friend = %User{whitelist: whitelist}) do
    with {:allowed?, true} <- {:allowed?, Enum.any?(whitelist, &(&1.id == my_id))} do
      ToDo.List.view(friend.to_do_list, :public)
    else
      {:allowed?, false} -> {:error, "This user has not permitted you to see their ToDos"}
    end
  end

  # these are just the domain of the persistent list really. So is the protocol the wrong move
  # or do we have to understand what the previous list means for a regular old list. Could just
  # mean it's the same as it ever was. Or could mean it
  def view_previous_list() do
    ToDo.List.view_previous()
  end

  def view_next_list() do
    ToDo.List.view_next()
  end

  defp update_user_to_do_list(user = %User{}, new_list) do
    %{user | to_do_list: new_list}
  end
end

defmodule ToDo.List.Persistent do
  defstruct [:list_history, :present]

  defimpl ToDo.List do
    def view(list = %{list_history: history, present: present_index}, task_type) do
      latest = Enum.at(history, present_index)
      ToDo.List.view(latest, task_type)
    end

    def add_task(list = %{list_history: history = [old_list | _]}, task) do
      new_list = ToDo.List.add_task(old_list, task)
      update_list_history(list, [new_list | history])
    end

    def delete_task(list = %{list_history: history = [old_list | _]}, task) do
      new_list = ToDo.List.delete_task(old_list, task)
      update_list_history(list, [new_list | history])
    end

    def complete_task(list = %{list_history: history = [old_list | _]}, task) do
      list
      |> delete_task(task)
      |> add_task(ToDo.Task.mark_task_complete(task))
    end

    def sort_by(list = %{list_history: history = [old_list | _]}, sorting_factor) do
      new_list = ToDo.List.sort_by(old_list, sorting_factor)
      update_list_history(list, [new_list | history])
    end

    def step_back(list = %{list_history: history, present: present_index}) do
      # Step back and step forward only allow viewing of the past lists, not editing them
      view(%{list | present: present_index - 1})
    end

    def step_forward(list = %{list_history: history, present: present_index}) do
      # Step back and step forward only allow viewing of the past lists, not editing them
      view(%{list | present: present_index + 1})
    end

    defp update_list_history(history, new_history), do: %{history | list_history: new_history}
  end
end

defmodule ToDo.List.Regular do
  defstruct [:task_list]

  defimpl ToDo.List do
    def view(list = %ToDo.List.Regular{task_list: tasks}, :public) do
      new_task_list = Enum.reject(tasks, fn task -> task.private? end)
      update_list(list, new_task_list)
    end

    def add_task(list = %ToDo.List.Regular{task_list: tasks}, task) do
      update_list(list, [task | tasks])
    end

    def delete_task(list = %ToDo.List.Regular{task_list: tasks}, %ToDo.Task{id: task_id}) do
      new_task_list = Enum.reject(tasks, fn %{id: id} -> id == task_id end)
      update_list(list, new_task_list)
    end

    def complete_task(list, task) do
      list
      |> delete_task(task)
      |> add_task(ToDo.Task.mark_task_complete(task))
    end

    def sort_by(list = %ToDo.List.Regular{task_list: tasks}, :priority) do
      new_task_list =
        Enum.map(tasks, fn task = %{priority: priority} ->
          %{task | order: priority}
        end)

      update_list(list, new_task_list)
    end

    def sort_by(list = %ToDo.List.Regular{task_list: tasks}, :date_created) do
      new_task_list =
        Enum.map(tasks, fn task = %{id: id} ->
          %{task | order: id}
        end)

      update_list(list, new_task_list)
    end

    def step_back(list), do: list
    def step_forward(list), do: list
    defp update_list(list, new_task_list), do: %{list | task_list: order_task_list(new_task_list)}
    defp order_task_list(task_list), do: Enum.sort_by(task_list, & &1.order)
  end
end

defmodule ToDo.Task do
  @completed "Completed"
  @in_progress "In Progress"
  @in_review "In Review"
  @blocked "Blocked"
  defstruct [:order, :description, :id, :status, :priority, private?: true]

  def mark_task_complete(task), do: %{task | status: @completed}
  def statuses(), do: [@completed, @in_progress, @in_review, @blocked]
end

task1 = %ToDo.Task{order: 2, description: "Jam", id: 1, priority: 1}
task2 = %ToDo.Task{order: 1, description: "trousers", id: 2, priority: 3, private?: false}
list_1 = %ToDo.List.Regular{task_list: [task2]}
persistent = %ToDo.List.Persistent{list_history: [list_1]}
jo = %User{name: "Jo", friends: [], whitelist: [], to_do_list: persistent}

User.add_task_to_list(jo, task1)
|> User.delete_task_from_list(task1)
|> User.complete_task_on_list(task2)
|> User.sort_list(:date_created)
