# Second round of feature requests
# Support a notion of users, where each user has a list of friends and a single todo list. Extend your design to support an "accountability" feature, where users can allow friends to view their todo list and progress. Make sure to allow users to mark some todo items as "private." If a todo item is "private," then no-one may view it or be given any information that it exists.

# Make sure to explain how the user interface for viewing a friend's to-do list would work, and in particular how it may reuse code from your normal user interface.

# Complete this task before reading on.

# I think of this as the User now becoming the top of the graph. The user is the entrypoint for all
# actions, like now a user adds to their list. Instead of ToDo.List.add_task(task2) it becomes
# User.add_task_to_list(user, task)
# User.delete_task_from_list(user, task)
# User.view_friend_list(user, friend)

# I think the features are as follows:
# User has a to do list.
# User has many friends
# User has a whitelist of people who can see their list
# Some To do items can be private. Privacy of an item is separate from the status of an item.

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

  defp update_user_to_do_list(user = %User{}, new_list = %ToDo.List{}) do
    %{user | to_do_list: new_list}
  end
end

defmodule ToDo.List do
  defstruct [:task_list]

  def view(list), do: list

  def view(list = %ToDo.List{task_list: tasks}, :public) do
    new_task_list = Enum.reject(tasks, fn task -> task.private? end)
    update_list(list, new_task_list)
  end

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
  defstruct [:order, :description, :id, :status, :priority, private?: true]

  def mark_task_complete(task), do: %{task | status: @completed}
  def statuses(), do: [@completed, @in_progress, @in_review, @blocked]
end

task1 = %ToDo.Task{order: 2, description: "Jam", id: 1, priority: 1}
task2 = %ToDo.Task{order: 1, description: "trousers", id: 2, priority: 3, private?: false}
task3 = %ToDo.Task{order: 3, description: "iron", id: 3, priority: 2}
task4 = %ToDo.Task{order: 4, description: "eggs", id: 4, priority: 7}
task5 = %ToDo.Task{order: 5, description: "Rum Ham", id: 5, priority: 4}
list_1 = %ToDo.List{task_list: [task1]}
list_2 = %ToDo.List{task_list: [task2]}

jeff = %User{name: "Jeff", friends: [], whitelist: [], to_do_list: list_1}
jo = %User{name: "Jo", friends: [], whitelist: [jeff], to_do_list: list_2}

User.add_task_to_list(jo, task3)
User.add_task_to_list(jeff, task4)
User.delete_task_from_list(jo, task3)
User.delete_task_from_list(jeff, task4)
User.complete_task_on_list(jo, task2)
User.complete_task_on_list(jeff, task1)
User.sort_list(jo, :date_created)
User.sort_list(jeff, :priority)
User.view_list(jo, jeff)
User.view_list(jeff, jo)
