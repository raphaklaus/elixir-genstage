defmodule Playgenstage.Consumer do
  use GenStage

  def start_link(init_args) do
    # you may want to register your server with `name: __MODULE__`
    # as a third argument to `start_link`
    GenStage.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(_args) do
    {:consumer, %{}, subscribe_to: [{Playgenstage.Producer, max_demand: 4, min_demand: 1}]}
    # {:consumer, :initial_state, subscribe_to: [
    #   {Playgenstage.Producer, [max_demand: 2, min_demand: 1]}]
    # }
  end

  def handle_subscribe(:producer, opts, from, producers) do
    IO.inspect "CONSUMER: subscribe"
    # We will only allow max_demand events every 5000 milliseconds
    pending = opts[:max_demand] || 1000
    interval = opts[:interval] || 2000

    # Register the producer in the state
    producers = Map.put(producers, from, {pending, interval})
    # Ask for the pending events and schedule the next time around
    producers = ask_and_schedule(producers, from)
    # IO.inspect producers

    # Returns manual as we want control over the demand
    {:manual, producers}
  end

  def handle_cancel(_, from, producers) do
    # Remove the producers from the map on unsubscribe
    {:noreply, [], Map.delete(producers, from)}
  end

  def handle_events(events, from, producers) do
    IO.inspect "CONSUMER: coming events..."
    IO.inspect "CONSUMER: PENDING"

    # Bump the amount of pending events for the given producer
    producers = Map.update!(producers, from, fn {pending, interval} ->
      IO.inspect pending + length(events)
      {pending + length(events), interval}
    end)


    # Consume the events by printing them.
    IO.inspect "CONSUMER: what"
    IO.inspect events, charlists: :as_lists
    IO.inspect producers, charlists: :as_lists

    # A producer_consumer would return the processed events here.
    {:noreply, [], producers}
  end


  def handle_info({:ask, from}, producers) do
    IO.inspect "CONSUMER: more?"
    IO.inspect producers
    # This callback is invoked by the Process.send_after/3 message below.
    {:noreply, [], ask_and_schedule(producers, from)}
  end

  defp ask_and_schedule(producers, from) do
    IO.inspect "CONSUMER: ask and schedule"
    # IO.inspect producers
    case producers do
      %{^from => {pending, interval}} ->
        # Ask for any pending events
        GenStage.ask(from, pending)
        # And let's check again after interval
        IO.inspect Process.send_after(self(), {:ask, from}, interval)
        # Finally, reset pending events to 0
        Map.put(producers, from, {0, interval})
      %{} ->
        IO.inspect "CONSUMER: outro"
        producers
    end
  end
end
