defmodule UnkeyElixirSdkTest do
  use ExUnit.Case
  doctest UnkeyElixirSdk

  test "greets the world" do
    assert UnkeyElixirSdk.hello() == :world
  end
end
