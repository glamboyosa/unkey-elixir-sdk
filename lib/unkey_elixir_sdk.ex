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

  @doc """
  Creates an  API key for your users

  Returns a map with the key

  {
  "key": "xyz_AS5HDkXXPot2MMoPHD8jnL"
  }

  ## Examples
      iex> UnkeyElixirSdk.create_key(%{"apiId" => "myapiid"})
      %{"key" => "xyz_AS5HDkXXPot2MMoPHD8jnL"}

     iex>  UnkeyElixirSdk.create_key(%{
    "apiId" => "myapiid",
    "prefix" => "xyz",
    "byteLength" => 16,
    "ownerId" => "glamboyosa",
    "meta" => %{
      hello: "world"
    },
    "expires" => 1_686_941_966_471,
    "ratelimit" => %{
      "type" => "fast",
      "limit" => 10,
      "refillRate" => 1,
      "refillInterval" => 1000
    }
  })

      %{"key" => "xyz_AS5HDkXXPot2MMoPHD8jnL"}

  """

  @spec create_key(map) :: map()
  def create_key(opts) when is_map(opts) do
    if(is_nil(Map.get(opts, :apiId))) do
      handle_error("You need to specify at least the apiId in the form %{apiId: 'yourapiId'}")
    end

    [{_m, pid}] = :ets.lookup(:pid_store, "pid")
    GenServer.call(pid, {:create_key, opts})
  end

  @doc """
  Verify a key from your users. Notice how this endpoint does not require an Unkey api key. You only need to send the api key from your user.

  Returns a map with whether the key is valid or not. Optionally sends `ownerId` and `meta`

  ## Examples
      iex> UnkeyElixirSdk.verify_key("xyz_AS5HDkXXPot2MMoPHD8jnL")

   %{"valid" => true,
    "ownerId" => "chronark",
    "meta" => %{
      "hello" => "world"
    }}
  """

  @spec verify_key(binary) :: map()
  def verify_key(key) when is_binary(key) do
    [{_m, pid}] = :ets.lookup(:pid_store, "pid")
    GenServer.call(pid, {:verify_key, key})
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

    {:noreply, state}
  end

  @impl true
  def handle_call({:verify_key, key}, _from, state) do
    body =
      %{"key" => key}
      |> Jason.encode!()

    case HTTPoison.post("#{state.base_url}/verify", body, headers(state.token)) do
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

    {:noreply, state}
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
