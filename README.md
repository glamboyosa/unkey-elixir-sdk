# UnkeyElixirSdk

[Unkey.dev](https://unkey.dev) Elixir SDK for interacting with the platform programatically.

## Installation

The package can be installed from Hex PM by adding `unkey_elixir_sdk` to your list of dependencies in `mix.exs`:

> Note: This project uses Elixir version `1.13`.

```elixir
def deps do
  [
    {:unkey_elixir_sdk, "~> 0.3.0"}
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
      {UnkeyElixirSdk, %{token: "yourunkeyapitoken"}}
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

## Breaking Changes

### Version 0.3.0

**Change**: Updated to use Unkey API v2 (`https://api.unkey.com/v2/`).

The Unkey API v1 will be deprecated in January 2026. This version updates the SDK to use the v2 API.

**Key changes in v2 API:**
- New base URL: `https://api.unkey.com/v2/keys.{action}` (was `https://api.unkey.dev/v1/keys/{action}`)
- Response format now includes `meta` and `data` wrapper fields (the SDK extracts `data` for backward compatibility)
- Some request field names have changed in the API:
  - `ownerId` → `externalId`
  - Rate limit structure uses `duration` instead of `refillInterval`/`refillRate`

See the [Unkey v2 Migration Guide](https://www.unkey.com/docs/api-reference/v1/migration) for full details.

### Version 0.2.0

**Change**: The ` revoke_key` function has been renamed to `delete_key`.
The delete_key function now performs the same operation as `revoke_key`.
Update your code to replace calls to `revoke_key`with`delete_key`.

## Functions

### create_key

> @spec create_key(map) :: map()

Creates an API key for your users. It takes a map with at least one property `apiId`. Full list of properties can be found below or in the [docs](https://docs.unkey.dev/api-reference/keys/create)

Returns a map with the `key` and `keyId`.

```elixir
 UnkeyElixirSdk.create_key(%{"apiId" => "myapiid"})
  # returns
   %{"keyId" => "key_cm9vdCBvZiBnb29kXa", "key" => "xyz_AS5HDkXXPot2MMoPHD8jnL"}
```

```elixir
UnkeyElixirSdk.create_key(%{
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
})
# returns
%{"keyId" => "key_cm9vdCBvZiBnb29kXa", "key" => "xyz_AS5HDkXXPot2MMoPHD8jnL"}
```

### verify_key

> @spec verify_key(binary, map()) :: map()

Verify a key from your users. You only need to send the api key from your user. Optionally, pass in a second param, a map with the key `apiId` which sends the `apiId` along.

Returns a map with whether the key is valid or not. Optionally sends `ownerId` and `meta`.

```elixir
 UnkeyElixirSdk.verify_key("xyz_AS5HDkXXPot2MMoPHD8jnL")
  # returns
  %{"valid" => true,
    "ownerId" => "chronark",
    "meta" => %{
      "hello" => "world"
    }}
```

```elixir
 UnkeyElixirSdk.verify_key("xyz_AS5HDkXXPot2MMoPHD8jnL", %{"apiId"=> "api_AS455efrefsfsf"})
  # returns
  %{"valid" => true,
    "ownerId" => "chronark",
    "meta" => %{
      "hello" => "world"
    }}
```

### update_key

> @spec update_key(binary(), map()) :: :ok
> Updates the configuration of a key

Takes in a `key_id` argument and a map whose members are optional
but must have at most 1 member present.

```elixir
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

Returns :ok

```elixir
UnkeyElixirSdk.update_key("key_cm9vdCBvZiBnb29kXa", %{
"name" => "my_new_key",
"ratelimit" => %{
"type" => "fast",
"limit" => 15,
"refillRate" => 2,
"refillInterval" => 500
},
"remaining" => 3
})

:ok
```

### update_remaining

> @spec update_remaining(map()) :: :ok

Updates the `remaining` value for a specified key.
Takes in a map of the shape:
`%{
"keyId": "key_123",
"op": "increment",
"value": 1
}`

Where "op" is "increment" | "decrement" | "set"
and value is the value you want to increase by or nil (unlimited)

Returns a map with the updated "remaining" value.

```elixir
UnkeyElixirSdk.update_remaining(%{
"keyId": "key_123",
"op": "increment",
"value": 1
})

 %{remaining: 100}

```

### delete_key

> @spec delete_key(binary) :: :ok

Delete an api key for your users

Returns `:ok`

```elixir
UnkeyElixirSdk.delete_key("key_cm9vdCBvZiBnb29kXa")
# returns
:ok
```

Documentation can be found at [https://hexdocs.pm/unkey_elixir_sdk](https://hexdocs.pm/unkey_elixir_sdk).

## References

- [Unkey.dev documentation](https://unkey.dev/docs)
