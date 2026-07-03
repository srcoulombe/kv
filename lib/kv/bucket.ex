defmodule KV.Bucket do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def get(bucket, key), do: GenServer.call(bucket, {:get, key})

  def put(bucket, key, value), do: GenServer.call(bucket, {:put, key, value})

  def delete(bucket, key), do: GenServer.call(bucket, {:delete, key})

  def subscribe(bucket) do
    GenServer.cast(bucket, {:subscribe, self()})
  end

  @impl true
  def init(bucket) do
    state = %{
      bucket: bucket,
      subscribers: MapSet.new()
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    value = get_in(state.bucket[key])
    broadcast(state, {:get, key})
    {:reply, value, state}
  end

  def handle_call({:put, key, value}, _from, state) do
    state = put_in(state.bucket[key], value)
    broadcast(state, {:put, key, value})
    {:reply, :ok, state}
  end

  def handle_call({:delete, key}, _from, state) do
    {value, state} = pop_in(state.bucket[key])
    broadcast(state, {:delete, key})
    {:reply, value, state}
  end

  @impl true
  def handle_cast({:subscribe, pid}, state) do
    Process.monitor(pid)
    state = update_in(state.subscribers, &MapSet.put(&1, pid))
    {:noreply, state}
  end

  defp broadcast(state, message) do
    for pid <- state.subscribers do
      send(pid, message)
    end
  end
end
