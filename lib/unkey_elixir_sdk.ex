defmodule UnkeyElixirSdk do
  @moduledoc """
  Documentation for `UnkeyElixirSdk`.
  """
  use GenServer

  require Logger

  # Client
  @doc """
  Start the GenServer
  Returns {:ok, pid}

  ## Examples
      iex> UnkeyElixirSdk.start_link(%{token: "yourtoken"})
      `{:ok, pid}`

    iex> UnkeyElixirSdk.start_link(%{token: "yourtoken", base_url: "theunkeybaseurl"})


  `{:ok, pid}`
  """
  @spec start_link(map) :: {:ok, pid}
  def start_link(default) when is_map(default) do
    :ets.new(:pid_store, [:set, :public, :named_table])

    if map_size(default) === 0 do
      raise ArgumentError,
            "You need to specify at least the token in either the supervisor or via the start_link function i.e. start_link(%{token: 'mytoken'})"
    end

    {:ok, pid} = GenServer.start_link(__MODULE__, default)
    # save the PID to a store so the user does not need to alwayd supply it
    :ets.insert(:pid_store, {"pid", pid})

    {:ok, pid}
  end

  @doc """
  Creates an  API key for your users

  Returns a map with the key
  `%{"keyId" => "key_cm9vdCBvZiBnb29kXa", "key" => "xyz_AS5HDkXXPot2MMoPHD8jnL"}`


  ## Examples
      iex> UnkeyElixirSdk.create_key(%{"apiId" => "myapiid"})
      %{"keyId" => "key_cm9vdCBvZiBnb29kXa", "key" => "xyz_AS5HDkXXPot2MMoPHD8jnL"}

     iex>  `UnkeyElixirSdk.create_key(%{
     "apiId" => "myapiid",
     "prefix" => "xyz",
     "byteLength" => 16,
     "ownerId" => "glamboyosa",
     "meta" => %{
      "hello" => "world"
     },
     "expires" => 1_686_941_966_471,
     "ratelimit" => %{
     "type" => "fast",
     "limit" => 10,
     "refillRate" => 1,
     "refillInterval" => 1000
     },
     "remaining" => 5
  })`

    %{"keyId" => "key_cm9vdCBvZiBnb29kXa", "key" => "xyz_AS5HDkXXPot2MMoPHD8jnL"}

  """

  @spec create_key(map) :: map()
  def create_key(opts) when is_map(opts) do
    if is_nil(Map.get(opts, "apiId")) do
      raise ArgumentError,
            "You need to specify at least the apiId in the form %{apiId: 'yourapiId'}"
    end

    [{_m, pid}] = :ets.lookup(:pid_store, "pid")
    GenServer.call(pid, {:create_key, opts}, 6000)
  end

  @doc """
  Verify a key from your users.  You only need to send the api key from your user. Optionally, second param is a map with the key `apiId` which sends the apiId

  Returns a map with whether the key is valid or not. Optionally sends `ownerId` and `meta`

  ## Examples
      iex> UnkeyElixirSdk.verify_key("xyz_AS5HDkXXPot2MMoPHD8jnL")

      `%{"valid" => true,
       "ownerId" => "chronark",
      "meta" => %{
      "hello" => "world"
      }}`

      iex> UnkeyElixirSdk.verify_key("xyz_AS5HDkXXPot2MMoPHD8jnL", %{"apiId"} => "api_sASDSsgeegd")

      `%{"valid" => true,
       "ownerId" => "chronark",
      "meta" => %{
      "hello" => "world"
      }}`
  """

  @spec verify_key(binary, map()) :: map()
  def verify_key(key, opts \\ %{}) when is_binary(key) do
    [{_m, pid}] = :ets.lookup(:pid_store, "pid")
    GenServer.call(pid, {:verify_key, key, opts}, :infinity)
  end

  @doc """
  Delete an api key for your users

  Returns  :ok

  ## Examples
      iex> UnkeyElixirSdk.delete_key("key_cm9vdCBvZiBnb29kXa")

      :ok
  """

  @spec delete_key(binary) :: :ok
  def delete_key(key) when is_binary(key) do
    [{_m, pid}] = :ets.lookup(:pid_store, "pid")
    GenServer.call(pid, {:delete_key, key}, :infinity)
  end

  @doc """
  Updates the `remaining` value for a specified key.
  Takes in a map of the shape:
  %{
  "keyId": "key_123",
  "op": "increment",
  "value": 1
  }
  Where "op" is "increment" | "decrement" | "set"
  and value is the value you want to increase by or nil (unlimited)

  Returns a map with the updated "remaining" value.

  ## Examples
      iex> UnkeyElixirSdk.update_remaining(%{
  "keyId": "key_123",
  "op": "increment",
  "value": 1
  })

      %{remaining: 100}
  """
  @spec update_remaining(map()) :: :ok
  def update_remaining(opts) when is_map(opts) do
    [{_m, pid}] = :ets.lookup(:pid_store, "pid")
    GenServer.call(pid, {:update_remaining, opts}, :infinity)
  end

  @doc """
  Updates the configuration of a key

  Takes in a `key_id` argument and a map whose members are optional
  but must have at most 1 member present.

  ```
  %{
    "name" => "my_new_key",
    "ownerId" => "still_glamboyosa",
     "meta" => %{
      "hello" => "world"
     },
     "expires" => 1_686_941_966_471,
     "ratelimit" => %{
     "type" => "fast",
     "limit" => 15,
     "refillRate" => 2,
     "refillInterval" => 500
     },
     "remaining" => 3
  }
  ```

  Returns  :ok

  ## Examples

  ```
      iex> UnkeyElixirSdk.update_key("key_cm9vdCBvZiBnb29kXa", %{
    "name" => "my_new_key",
    "ownerId" => "still_glamboyosa",
     "meta" => %{
      "hello" => "world"
     },
     "expires" => 1_686_941_966_471,
     "ratelimit" => %{
     "type" => "fast",
     "limit" => 15,
     "refillRate" => 2,
     "refillInterval" => 500
     },
     "remaining" => 3
  })
  ```

      :ok
  """

  @spec update_key(binary(), map()) :: :ok
  def update_key(key_id, opts) when is_map(opts) and is_binary(key_id) do
    [{_m, pid}] = :ets.lookup(:pid_store, "pid")
    GenServer.call(pid, {:update_key, key_id, opts}, :infinity)
  end

  # Server (callbacks)

  @impl true
  def init(elements) do
    # Use user-provided base_url if present, otherwise default to v2 API
    # v2 API: https://api.unkey.com/v2/keys.{action}
    # See: https://www.unkey.com/docs/api-reference/v2/rpc
    default_base_url = "https://api.unkey.com/v2/keys."
    elements = Map.put_new(elements, :base_url, default_base_url)
    {:ok, elements}
  end

  @impl true
  def handle_call({:create_key, opts}, _from, state) do
    body = opts |> Jason.encode!()

    case HTTPoison.post("#{state.base_url}createKey", body, headers(state.token)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        # v2 API wraps response in {meta, data} - extract data for backward compatibility
        response = Jason.decode!(body)
        {:reply, extract_data(response), state}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        handle_error("Not found :(", state)

      {:ok, %HTTPoison.Response{status_code: 401}} ->
        handle_error("Unauthorised", state)

      {:error, %HTTPoison.Error{reason: reason}} ->
        handle_error(to_string(reason), state)

      {:ok, %HTTPoison.Response{body: body}} ->
        handle_error(to_string(body), state)

      _ ->
        handle_error("Something went wrong", state)
    end
  end

  @impl true
  def handle_call({:update_remaining, opts}, _from, state) do
    validate_params(opts)
    body = opts |> Jason.encode!()

    case HTTPoison.post("#{state.base_url}updateRemaining", body, headers(state.token)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        # v2 API wraps response in {meta, data} - extract data for backward compatibility
        response = Jason.decode!(body)
        {:reply, extract_data(response), state}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        handle_error("Not found :(", state)

      {:ok, %HTTPoison.Response{status_code: 401}} ->
        handle_error("Unauthorised", state)

      {:error, %HTTPoison.Error{reason: reason}} ->
        handle_error(to_string(reason), state)

      {:ok, %HTTPoison.Response{body: body}} ->
        handle_error(to_string(body), state)

      _ ->
        handle_error("Something went wrong", state)
    end
  end

  @impl true
  def handle_call({:delete_key, key_id}, _from, state) do
    body = %{"keyId" => key_id} |> Jason.encode!()

    case HTTPoison.post("#{state.base_url}deleteKey", body, headers(state.token)) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        {:reply, :ok, state}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        handle_error("Not found :(", state)

      {:ok, %HTTPoison.Response{status_code: 401}} ->
        handle_error("Unauthorised", state)

      {:error, %HTTPoison.Error{reason: reason}} ->
        handle_error(to_string(reason), state)

      {:ok, %HTTPoison.Response{body: body}} ->
        handle_error(to_string(body), state)

      _ ->
        handle_error("Something went wrong", state)
    end
  end

  @impl true
  def handle_call({:update_key, key_id, opts}, _from, state) do
    body =
      %{
        "keyId" => key_id,
        "name" => :undefined,
        "ownerId" => :undefined,
        "meta" => :undefined,
        "expires" => :undefined,
        "ratelimit" => :undefined,
        "remaining" => :undefined
      }
      |> Map.merge(opts)
      |> Map.filter(&(elem(&1, 1) !== :undefined))
      |> Jason.encode!()

    case HTTPoison.post("#{state.base_url}updateKey", body, headers(state.token)) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        {:reply, :ok, state}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        handle_error("Not found :(", state)

      {:ok, %HTTPoison.Response{status_code: 401}} ->
        handle_error("Unauthorised", state)

      {:error, %HTTPoison.Error{reason: reason}} ->
        handle_error(to_string(reason), state)

      {:ok, %HTTPoison.Response{body: body}} ->
        handle_error(to_string(body), state)

      _ ->
        handle_error("Something went wrong", state)
    end
  end

  @impl true
  def handle_call({:verify_key, key, opts}, _from, state) do
    body =
      %{"key" => key}
      |> Map.merge(opts)
      |> Jason.encode!()

    case HTTPoison.post("#{state.base_url}verifyKey", body, headers(state.token)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        # v2 API wraps response in {meta, data} - extract data for backward compatibility
        response = Jason.decode!(body)
        {:reply, extract_data(response), state}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        handle_error("Not found :(", state)

      {:ok, %HTTPoison.Response{status_code: 401}} ->
        handle_error("Unauthorised", state)

      {:error, %HTTPoison.Error{reason: reason}} ->
        handle_error(to_string(reason), state)

      {:ok, %HTTPoison.Response{body: body}} ->
        handle_error(to_string(body), state)

      _ ->
        handle_error("Something went wrong", state)
    end
  end

  # v2 API wraps responses in {meta, data} structure
  # Extract the data field for backward compatibility, or return as-is for v1-style responses
  defp extract_data(%{"data" => data}) when is_map(data), do: data
  defp extract_data(response), do: response

  defp handle_error(error_message, state) when is_binary(error_message) do
    Logger.error("UnkeyElixirSdk: #{error_message}")
    {:reply, {:error, error_message}, state}
  end

  defp headers(token) do
    [{"Authorization", "Bearer #{token}"}, {"Content-Type", "application/json; charset=UTF-8"}]
  end

  defp validate_params(params) do
    # Runtime checks to ensure op is valid and value is a number or nil
    valid_ops = ~w(increment decrement set)a
    op = String.to_atom(params["op"])

    if !Enum.member?(valid_ops, op) do
      raise ArgumentError, "Invalid operation '#{op}', expected one of: #{inspect(valid_ops)}"
    end

    value = params["value"]

    if !(is_nil(value) || is_integer(value)) do
      raise ArgumentError, "Invalid value '#{value}', expected an integer or nil"
    end
  end
end
