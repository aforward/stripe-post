defmodule StripePost.Worker do
  use GenServer

  alias StripePost.Client
  alias StripePost.Worker, as: W


  ### Public API

  def start_link() do
    {:ok, _pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def reload(), do: GenServer.call(W, :reload)
  def customers(), do: GenServer.call(W, :customers)
  def customer(pubid), do: GenServer.call(W, {:customer, pubid})


  ### Server Callbacks

  def init(_) do
    {:ok, zero_state(Application.get_env(:stripe_post, :reload_on_init))}
  end

  def handle_call(:customers, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:customer, pubid}, _from, state) do
    case Map.get(state, pubid) do
      nil -> Client.create_customer(%{description: pubid})
      id -> Client.get_customer(id)
    end
    |> (fn {:ok, customer} ->
         {:reply, customer, state |> Map.put(pubid, customer["id"])}
       end).()
  end

  def handle_call(:reload, _from, _state) do
    {:reply, :ok, zero_state(true)}
  end

  defp zero_state(true) do
    Client.list_customers
    |> (fn {:ok, customers} -> customers end).()
    |> Enum.map(fn {description, %{"id" => id}} -> {description, id} end)
    |> Enum.into(%{})
  end
  defp zero_state(_) do
    %{}
  end

end
