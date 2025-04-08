defmodule MyInstallerTest do
  use ExUnit.Case
  doctest MyInstaller

  test "greets the world" do
    assert MyInstaller.hello() == :world
  end
end
