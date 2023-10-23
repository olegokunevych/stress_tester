defmodule StressTester do
  @moduledoc """
  Documentation for `StressTester`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> StressTester.hello()
      :world

  """
  def hello do
    :world
  end
  
  def start(url, req_count, gen_count) do
    opts = %{url: url, req_count: req_count}
    for _ <- 1..gen_count do
      DynamicSupervisor.start_child(StressTester.DynamicSupervisor, {StressTester.Stresser, opts})
    end
  end
  
  def stats() do
    DynamicSupervisor.which_children(StressTester.DynamicSupervisor)
    |> Enum.map(fn {_, pid, _, _} -> StressTester.Stresser.get_state(pid) end)
    |> Enum.map(fn %{requests_times: rt} -> rt end)
    |> List.flatten()
    |> mean()
  end
  
  defp mean(data) do
    Enum.sum(data) / length(data)
  end
end
