defmodule UnkeyElixirSdk do
  use GenServer

  @moduledoc """
  Documentation for `UnkeyElixirSdk`.
  """

  # Client

  def start_link(default) when is_map(default) do
    :ets.new(:pid_store, [:set, :public, :named_table])

    if map_size(default) === 0 do
      handle_error(
        "You need to specify at least the token in either the supervisor or via the start_link function i.e. start_link(%{token: 'mytoken'})"
      )
    end

    {:ok, pid} = GenServer.start_link(__MODULE__, default)
    # save the PID to a store so the user does not need to alwayd supply it
    :ets.insert(:pid_store, {"pid", pid})

    {:ok, pid}
  end

  def create_key(opts) when is_map(opts) do
    if(is_nil(Map.get(opts, :apiId))) do
      handle_error("You need to specify at least the apiId in the form %{apiId: 'yourapiId'}")
    end

    [{_m, pid}] = :ets.lookup(:pid_store, "pid")
    GenServer.call(pid, :pop)
  end

  # Server (callbacks)

  @impl true
  def init(elements) do
    case Map.get(elements, :base_url) do
      nil ->
        base_url = "https://api.unkey.dev/v1/keys"

        Map.put(elements, :base_url, base_url)

        {:ok, elements}

      _ ->
        {:ok, elements}
    end
  end

  @impl true
  def handle_call(:pop, _from, state) do
    [to_caller | new_state] = state
    {:reply, to_caller, new_state}
  end

  defp handle_error(error_message) when is_binary(error_message) do
    try do
      throw(error_message)
    catch
      err ->
        log_error("Error Message #{err}")
    end
  end

  defp log_error(input) when is_binary(input) do
    IO.puts(input)
  end
end
