defmodule Playgenstage.Producer do
  use GenStage

  def start_link(init_args) do
    # you may want to register your server with `name: __MODULE__`
    # as a third argument to `start_link`
    GenStage.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(args) do
    # my_queue = args
    # |> :queue.from_list

    # IO.inspect my_queue
    {:producer, args}
  end

  def add_items(items) do
    IO.inspect "PRODUCER: add"
    GenStage.cast(__MODULE__, {:add, items})
  end

  def get_current_items do
    GenStage.call(__MODULE__, {:get})
  end

  def handle_call({:get}, _from, state) do
    IO.inspect "PRODUCER: state is..."
    IO.inspect state
    {:reply, state, state, state}
  end

  def handle_cast({:add, items}, state) do
    IO.inspect "PRODUCER: add cast"
    IO.inspect "PRODUCER: add cast2"
    IO.inspect state ++ items, charlists: :as_lists
    IO.inspect items, charlists: :as_lists
    {:noreply, state ++ items, state ++ items}
  end

  def handle_demand(demand, state) when demand > 0 do
    IO.inspect "PRODUCER: new demand:"
    IO.inspect demand
    IO.inspect "PRODUCER: the state:"
    IO.inspect state, charlists: :as_lists
    {result, rest} = next_element(demand, state, [])
    IO.inspect "PRODUCER: result"
    IO.inspect result, charlists: :as_lists
    IO.inspect "PRODUCER: rest"
    IO.inspect rest, charlists: :as_lists
    # IO.inspect :queue.to_list(element_queue)
    # IO.inspect resulting_queue
    {:noreply, result, rest}
  end

  def next_element(demand, queue, elements) do
    case demand == length(elements) or length(queue) == 0 do
      true -> {elements, queue}
      false ->
        {element, rest} = List.pop_at(queue, 0)
        next_element(demand, rest, elements ++ [element])
    end
  end

  # def next_element(count, demand, queue, new_queue) do
  #   IO.inspect "PRODUCER: iasjdioajsd"
  #   IO.inspect queue
  #   case count < demand do
  #     true ->
  #       case :queue.out(queue) do
  #         {{:value, element}, rest} -> next_element(count+1, demand, rest, :queue.in(element, new_queue))
  #         {{:empty}, _} -> {new_queue, queue}
  #       end

  #     _ -> {new_queue, queue}
  #   end
  # end
end
