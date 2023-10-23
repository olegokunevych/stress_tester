defmodule StressTesterTest do
  use ExUnit.Case
  doctest StressTester

  test "greets the world" do
    assert StressTester.hello() == :world
  end
end
