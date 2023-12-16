defmodule UnkeyElixirSdkTest do
  use ExUnit.Case

  require Logger
  alias UnkeyElixirSdk

  test "Starts the GenServer Process successfully" do
    token = Application.get_env(:unkey_elixir_sdk, :token)

    assert {:ok, _pid} = UnkeyElixirSdk.start_link(%{token: token})
  end

  test "version in README matches mix.exs" do
    readme_md = File.read!(Path.join(__DIR__, "../README.md"))

    mix_config = Mix.Project.config()

    version = mix_config[:version]

    assert version == "0.2.0"

    assert readme_md =~ ~s({:unkey_elixir_sdk, "~> #{version}"})
  end

  describe "Unkey SDK Methods" do
    setup %{} do
      token = Application.get_env(:unkey_elixir_sdk, :token)
      api_id = Application.get_env(:unkey_elixir_sdk, :api_id)

      if is_nil(token) or is_nil(api_id) do
        throw("No env variables exists")
      end

      UnkeyElixirSdk.start_link(%{token: token})
      {:ok, api_id: api_id}
    end

    test "create_key/1 w just one opt", %{api_id: api_id} do
      try do
        opts = UnkeyElixirSdk.create_key(%{"apiId" => api_id})

        assert is_map(opts)
      catch
        err ->
          Logger.error(err)
      end
    end

    test "create_key/1 w just all opts", %{api_id: api_id} do
      try do
        expiry =
          DateTime.utc_now()
          |> DateTime.add(100_000)
          |> DateTime.to_unix(:millisecond)

        opts =
          UnkeyElixirSdk.create_key(%{
            "apiId" => api_id,
            "prefix" => "xyz",
            "byteLength" => 16,
            "ownerId" => "glamboyosa",
            "meta" => %{"hello" => "world"},
            "expires" => expiry,
            "ratelimit" => %{
              "type" => "fast",
              "limit" => 10,
              "refillRate" => 1,
              "refillInterval" => 1000
            }
          })

        assert is_map(opts)
      catch
        err ->
          Logger.error(err)
      end
    end

    test "verify_key/1", %{api_id: api_id} do
      try do
        opts = UnkeyElixirSdk.create_key(%{"apiId" => api_id})

        assert is_map(opts)

        assert opts = UnkeyElixirSdk.verify_key(opts["key"])

        assert is_map(opts)
        assert opts["valid"] == true
      catch
        err ->
          Logger.error(err)
      end
    end

    test "verify_key/2", %{api_id: api_id} do
      try do
        opts = UnkeyElixirSdk.create_key(%{"apiId" => api_id})

        assert is_map(opts)

        assert opts = UnkeyElixirSdk.verify_key(opts["key"], %{"apiId" => api_id})

        assert is_map(opts)
        assert opts["valid"] == true
      catch
        err ->
          Logger.error(err)
      end
    end

    test "update_key/2", %{api_id: api_id} do
      try do
        opts =
          UnkeyElixirSdk.create_key(%{
            "apiId" => api_id,
            "prefix" => "xyz",
            "byteLength" => 16,
            "ownerId" => "glamboyosa",
            "meta" => %{"hello" => "world"},
            "ratelimit" => %{
              "type" => "fast",
              "limit" => 10,
              "refillRate" => 1,
              "refillInterval" => 1000
            }
          })

        assert is_map(opts)

        assert :ok =
                 UnkeyElixirSdk.update_key(opts["keyId"], %{
                   "name" => "my_new_key",
                   "ratelimit" => %{
                     "type" => "fast",
                     "limit" => 15,
                     "refillRate" => 2,
                     "refillInterval" => 500
                   },
                   "remaining" => 3
                 })
      catch
        err ->
          Logger.error(err)
      end
    end

    test "update_key/2 with nil values", %{api_id: api_id} do
      try do
        opts =
          UnkeyElixirSdk.create_key(%{
            "apiId" => api_id,
            "prefix" => "xyz",
            "byteLength" => 16,
            "ownerId" => "glamboyosa",
            "meta" => %{"hello" => "world"},
            "ratelimit" => %{
              "type" => "fast",
              "limit" => 10,
              "refillRate" => 1,
              "refillInterval" => 1000
            }
          })

        assert is_map(opts)

        assert :ok =
                 UnkeyElixirSdk.update_key(opts["keyId"], %{
                   "name" => nil,
                   "ratelimit" => nil
                 })
      catch
        err ->
          Logger.error(err)
      end
    end

    test "delete_key/1", %{api_id: api_id} do
      try do
        opts = UnkeyElixirSdk.create_key(%{"apiId" => api_id})

        assert is_map(opts)

        assert :ok = UnkeyElixirSdk.delete_key(opts["keyId"])
      catch
        err ->
          Logger.error(err)
      end
    end
    test "update_remaining/1", %{api_id: api_id} do
      try do
        opts = UnkeyElixirSdk.create_key(%{"apiId" => api_id, "remaining" => 2})

        assert is_map(opts)

        assert opts = UnkeyElixirSdk.update_remaining(%{"keyId" => opts["keyId"],"op" => "increment", "value" => 100 })
        assert is_map(opts)
        assert is_integer(opts["remaining"])
      catch
        err ->
          Logger.error(err)
      end
    end
  end
end
