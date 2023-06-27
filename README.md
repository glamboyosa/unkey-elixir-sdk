# UnkeyElixirSdk

[Unkey.dev](https://unkey.dev) Elixir SDK for interacting with the platform programatically.

## Installation

The package can be installed from Hex PM by adding `unkey_elixir_sdk` to your list of dependencies in `mix.exs`:

> Note: This project uses Elixir version `1.13`.

```elixir
def deps do
  [
    {:unkey_elixir_sdk, "~> 0.1.0"}
  ]
end
```

## Start the GenServer

In order to start this package we can either start it under a supervision tree (most common).

The GenServer takes a map with two properties.

- token: Your [Unkey](https://unkey.dev) Access token used to make requests. You can create one [here](https://unkey.dev/app/keys) **required**
- base_url: The base URL endpoint you will be hitting i.e. `https://api.unkey.dev/v1/keys` (optional).

```elixir
children = [
  # The Counter is a child started via Counter.start_link(0)
  %{
    id: UnkeyElixirSdk,
    start: {UnkeyElixirSdk, :start_link, [%{token: "yourunkeyapitoken"}]}
  }
]


# Now we start the supervisor with the children and a strategy
{:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

# After started, we can query the supervisor for information
Supervisor.count_children(pid)
#=> %{active: 1, specs: 1, supervisors: 0, workers: 1}
```

You can also call the `start_link` function instead.

```elixir
{:ok, _pid} = UnkeyElixirSdk.start_link(%{token: "yourunkeyapitoken", base_url: "https://api.unkey.dev/v1/keys"})
```

## Functions

### create_key

> @spec create_key(map) :: map()

Creates an API key for your users. It takes a map with at least one property `apiId`. Full list of properties can be found below or in the [docs](https://docs.unkey.dev/api-reference/keys/create)

Returns a map with the `key` and `keyId`.

```elixir
 UnkeyElixirSdk.create_key(%{"apiId" => "myapiid"})

   %{"keyId" => "key_cm9vdCBvZiBnb29kXa", "key" => "xyz_AS5HDkXXPot2MMoPHD8jnL"}
```

```elixir
UnkeyElixirSdk.create_key(%{
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
%{"keyId" => "key_cm9vdCBvZiBnb29kXa", "key" => "xyz_AS5HDkXXPot2MMoPHD8jnL"}
```

### verify_key

> @spec verify_key(binary) :: map()

Verify a key from your users. You only need to send the api key from your user.

Returns a map with whether the key is valid or not. Optionally sends `ownerId` and `meta`.

```elixir
 UnkeyElixirSdk.verify_key("xyz_AS5HDkXXPot2MMoPHD8jnL")

  %{"valid" => true,
    "ownerId" => "chronark",
    "meta" => %{
      "hello" => "world"
    }}
```

### revoke_key

> @spec revoke_key(binary) :: :ok

Delete an api key for your users

Returns `:ok`

```elixir
UnkeyElixirSdk.revoke_key("key_cm9vdCBvZiBnb29kXa")

:ok
```

Documentation can be found at [https://hexdocs.pm/unkey_elixir_sdk](https://hexdocs.pm/unkey_elixir_sdk).

## References

- [Unkey.dev documentation](https://unkey.dev/docss)
