defmodule UnkeyElixirSdk do
  use GenServer
  alias HTTPoison
  alias Jason

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
    GenServer.call(pid, {:create_key, opts})
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
  def handle_call({:create_key, opts}, _from, state) do
    body = opts |> Jason.encode!()

    case HTTPoison.post(state.base_url, body, headers(state.token)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts(body)
        {:reply, Jason.decode!(body), state}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        handle_error("Not found :(")

      {:ok, %HTTPoison.Response{status_code: 401}} ->
        handle_error("Not found :(")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
        handle_error(to_string(reason))
    end

    {:no_reply, state}
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

  defp headers(token) do
    [Authorization: "Bearer #{token}", Accept: "Application/json; Charset=utf-8"]
  end
end
