defmodule KV do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, name: KV, keys: :unique},
      {DynamicSupervisor, name: KV.BucketSupervisor, strategy: :one_for_one},
      {Task, fn -> KV.Server.accept(4040) end}
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

  defp via(name), do: {:via, Registry, {KV, name}}
end
