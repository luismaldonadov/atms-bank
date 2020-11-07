defmodule AtmTest do
  use ExUnit.Case
  doctest Atm

  test "greets the world" do
    assert Atm.hello() == :world
  end
end
