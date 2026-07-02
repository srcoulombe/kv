defmodule KV do
  use Application

  @impl true
  def start(_type, _args) do
    # allows to specify node names at startup:
    # in one terminal, run
    # $ NODES="foo@computer-name,foo@samy-ThinkPad-T450" PORT=4040 iex --sname foo -S mix
    # in another terminal, run
    # $ NODES="foo@computer-name,bar@samy-ThinkPad-T450" PORT=4040 iex --sname bar -S mix
    # you should now be able to have your node named foo create and manipulate a KV bucket in the bar node by running:
    # :erpc.call(:"bar@samy-ThinkPad-T450", KV, :create_bucket, ["shopping"])
    # (and vice versa)
    #
    for node <- Application.fetch_env!(:kv, :nodes) do
      Node.connect(node)
    end

    port = Application.fetch_env!(:kv, :port)

    children = [
      {Registry, name: KV, keys: :unique},
      {DynamicSupervisor, name: KV.BucketSupervisor, strategy: :one_for_one},
      {Task.Supervisor, name: KV.ServerSupervisor},
      Supervisor.child_spec({Task, fn -> KV.Server.accept(port) end}, restart: :permanent)
    ]
    Supervisor.start_link(
      children,
      strategy: :one_for_one
    )
  end

  def create_bucket(name) do
    DynamicSupervisor.start_child(KV.BucketSupervisor, {KV.Bucket, name: via(name)})
  end

  def lookup_bucket(name), do: GenServer.whereis(via(name))

  defp via(name), do: {:global, name}
end
