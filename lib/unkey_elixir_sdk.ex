defmodule UnkeyElixirSdk do
  use GenServer

  @moduledoc """
  Documentation for `UnkeyElixirSdk`.
  """

  # Client

  def start_link(default) when is_binary(default) do
    :ets.new(:pid_store, [:set, :public, :named_table])

    {:ok, pid} = GenServer.start_link(__MODULE__, default)
    # save the PID to a store so the user does not need to alwayd supply it
    :ets.insert(:pid_store, {"pid", pid})
    {:ok, pid}
  end

  def pop() do
    [{_m, pid}] = :ets.lookup(:user_lookup, "pid")
    GenServer.call(pid, :pop)
  end

  # Server (callbacks)

  @impl true
  def init(elements) do
    initial_state = String.split(elements, ",", trim: true)
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:pop, _from, state) do
    [to_caller | new_state] = state
    {:reply, to_caller, new_state}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    new_state = [element | state]
    {:noreply, new_state}
  end
end
