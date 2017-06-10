defmodule StripePost.Client do
  @moduledoc"""
  Access service functionality through Elixir functions,
  wrapping the underlying HTTP API calls.

  This is where you will want to write your custom
  code to access your API.
  """

  alias StripePost.Api

  @doc"""
  Charge an account with the following body configurations

    body = %{amount: 10000, currency: "cad", description: "3 wozzle", source: "pk_abc_123"}

  The configurations are optional, and can be (preferrably) configured as elixir configs,
  like:

    config :stripe_post,
      secret_key: "sk_test_abc123",
      public_key: "pk_test_def456",
      content_type: "application/x-www-form-urlencoded"

  But, if you must, then you can specify it directly like

    configs = %{
      secret_key: "sk_test_abc123",
      content_type: "application/x-www-form-urlencoded"
    }

  """
  def charge(body, configs \\ nil) do
    Api.post(Api.url <> "/charges", body, configs)
  end

  @doc"""
  Create a customer with the following body configurations

    body = %{description: "customer xxx", source: "pk_abc_123"}

  """
  def create_customer(body, configs \\ nil) do
    Api.post(Api.url <> "/customers", body, configs)
  end

  @doc"""
  Retrieve a customer by his/her stripe ID

  """
  def get_customer(id, configs \\ nil) do
    Api.get(Api.url <> "/customers/#{id}", Api.encode_headers(configs))
  end

  @doc"""
  List all customer, if you don't provide a limit we will fetch them all

    query_params = %{limit: 100, starting_after: "obj_pk_1234"}

  """
  def list_customers(query_params \\ %{}, configs \\ nil) do
    case query_params[:limit] do
      nil -> all_customers(:first, query_params, configs)
      _ -> do_list_customers(query_params, configs)
    end
    |> clean_customers
  end

  defp all_customers(:first, query_params, configs) do
    query_params
    |> do_list_customers(configs)
    |> all_customers([], query_params, configs)
  end
  defp all_customers(
    {:ok, %{"data" => new_customers, "has_more" => false}},
    acc,
    _,
    _) do
    {:ok, %{"data" => acc ++ new_customers, "has_more" => false}}
  end
  defp all_customers(
    {:ok, %{"data" => new_customers, "has_more" => true}},
    acc,
    query_params,
    configs) do

    new_customers
    |> List.last
    |> Map.get("id")
    |> (fn(starting_after) -> query_params |> Map.put(:starting_after, starting_after) end).()
    |> do_list_customers(configs)
    |> all_customers(acc ++ new_customers, query_params, configs)
  end
  defp all_customers(resp, _acc, _query_params, _configs), do: resp

  defp do_list_customers(query_params, configs) do
    Api.url <> "/customers?" <> URI.encode_query(query_params |> Api.reject_nil)
    |> Api.get(Api.encode_headers(configs))
  end

  defp clean_customers({:error, _}), do: nil
  defp clean_customers({:ok,  %{"data" => customers}}) do
    customers
    |> Enum.map(fn(c) -> {c["description"], c} end)
    |> Enum.into(%{})
    |> (fn(mapped) -> {:ok, mapped} end).()
  end


end