defmodule StripePost.Worker do
  use GenServer

  ### Public API

  def start_link() do
    {:ok, _pid} = GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def post(url, body, headers) do
    GenServer.call(StripePost.Worker, {:post, url, body, headers})
  end

  ### Server Callbacks

  def init() do
    {:ok, {}}
  end

  def handle_call({:post, url, body, headers}, _from, state) do
    answer = StripePost.Api.post(url, body, headers)
    {:reply, answer, state}
  end

end