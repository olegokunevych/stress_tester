defmodule StressTester.Stresser do
  use GenServer
  
  def start_link(%{url: _url, req_count: _req_count} = opts) do
    id = :rand.uniform(1_000_000)
    
    GenServer.start_link(__MODULE__, opts, name: {:global, id})
  end
  
  def init(opts) do
    opts =
      opts
      |> Map.put(:failed_count, 0)
      |> Map.put(:success_count, 0)
      |> Map.put(:requests_times, [])
    
    {:ok, opts, {:continue, :make_request}}
  end
  
  def schedule(pid) do
    Process.send_after(pid, :start, 0)
  end
  
  def handle_continue(:make_request, state) do
    schedule(self())
    
    {:noreply, state}
  end
  
  def handle_info(:start, %{req_count: 0} = state) do
    {:noreply, state}
  end
    
  def handle_info(:start, %{url: url} = state) do
    start_time = System.monotonic_time(:millisecond)
    case make_http_call(url) do
      {:ok, _response} ->
        requests_times = [(System.monotonic_time(:millisecond) - start_time) | state.requests_times]
        state =
          state
          |> Map.put(:success_count, state.success_count + 1)
          |> Map.put(:requests_times, requests_times)
          |> Map.put(:req_count, state.req_count - 1)
          
        schedule(self())
        {:noreply, state}
      {:error, _reason} ->
        state =
          state
          |> Map.put(:failed_count, state.failed_count + 1)
          |> Map.put(:req_count, state.req_count - 1)
        schedule(self())
        {:noreply, state}
    end
  end
  
  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end
  
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
  
  defp make_http_call(url) do
    :inets.start()
    :ssl.start()
    :httpc.request(:get, {url, []}, [], [])
  end
end
