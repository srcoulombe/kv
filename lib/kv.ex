defmodule KV do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, name: KV, keys: :unique}
    ]
    Supervisor.start_link(
      children,
      strategy: :one_for_one
    )
  end
end
