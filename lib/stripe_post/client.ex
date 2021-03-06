defmodule StripePost.Client do
  @moduledoc """
  Access service functionality through Elixir functions,
  wrapping the underlying HTTP API calls.

  This is where you will want to write your custom
  code to access your API.
  """

  alias StripePost.Api

  @doc """
  Charge an account with the following body configurations

      StripePost.charge(
        %{amount: 10000,
          currency: "cad",
          description: "3 wozzle",
          source: "pk_abc_123"}
      )

  Where the `source` is the payment token received from Stripe most likely
  in your client javascriopt.

  You also now also authorize (without charging) an account by setting the
  `capture` field to `false`.  For more details [auth and capture](https://stripe.com/docs/charges#auth-and-capture)

      StripePost.charge(
        %{amount: 10000,
          currency: "cad",
          description: "3 wozzle",
          source: "pk_abc_123"
          capture: false}
      )

  The configurations are optional, and can be (preferrably) configured as elixir configs,
  like:

      config :stripe_post,
        secret_key: "sk_test_abc123",
        public_key: "pk_test_def456",
        content_type: "application/x-www-form-urlencoded"

  But, if you must, then you can specify it directly like

      opts = %{
        secret_key: "sk_test_abc123",
        content_type: "application/x-www-form-urlencoded"
      }

  """
  def charge(body, opts \\ nil) do
    Api.request(:post, [resource: "charges", body: body], opts)
  end

  @doc """
  Capture the payment of an existing, uncaptured, charge.
  This is the second half of the two-step payment flow, where first
  you created a charge with the capture option set to false.

  For example, if you charged the following, but did NOT capture

      StripePost.charge(
        %{amount: 10000,
          currency: "cad",
          description: "3 wozzle",
          source: "pk_abc_123"
          capture: false}
      )

  The results will contain a charge ID, and captured should be false, for example

      {"id": "ch_abc123",
       "paid": true,
       "status": "succeeded",
       "captured": false}

  When you are ready to capture the payment, use that charge "id", you can also
  provide additional fields, for example:

      StripePost.capture(
        "ch_abc123",
        %{amount: 10000,
          application_fee: 100,
          destination: 90210}
      )

  Please visit https://stripe.com/docs/api#capture_charge for more information

  The configurations are optional, and can be (preferrably) configured as elixir opts,
  like:

      config :stripe_post,
        secret_key: "sk_test_abc123",
        public_key: "pk_test_def456",
        content_type: "application/x-www-form-urlencoded"

  But, if you must, then you can specify it directly like

      opts = %{
        secret_key: "sk_test_abc123",
        content_type: "application/x-www-form-urlencoded"
      }

  """
  def capture(charge_id, body \\ %{}, opts \\ nil) do
    Api.request(:post, [resource: ["charges", charge_id, "capture"], body: body], opts)
  end

  @doc """
  Create a customer with the following body configurations

      body = %{description: "customer xxx", source: "pk_abc_123"}

  """
  def create_customer(body, opts \\ nil) do
    Api.request(:post, [resource: "customers", body: body], opts)
  end

  @doc """
  Retrieve a customer by his/her stripe ID
  """
  def get_customer(id, opts \\ nil) do
    Api.request(:post, [resource: ["customers", id]], opts)
  end

  @doc """
  List all customer, if you don't provide a limit we will fetch them all

      query_params = %{limit: 100, starting_after: "obj_pk_1234"}

  """
  def list_customers(query_params \\ %{}, opts \\ []) do
    case query_params[:limit] do
      nil -> all_customers(:first, query_params, opts)
      _ -> do_list_customers(query_params, opts)
    end
    |> clean_customers
  end

  defp all_customers(:first, query_params, opts) do
    query_params
    |> do_list_customers(opts)
    |> all_customers([], query_params, opts)
  end

  defp all_customers(
         {:ok, %{"data" => new_customers, "has_more" => false}},
         acc,
         _,
         _
       ) do
    {:ok, %{"data" => acc ++ new_customers, "has_more" => false}}
  end

  defp all_customers(
         {:ok, %{"data" => new_customers, "has_more" => true}},
         acc,
         query_params,
         opts
       ) do
    new_customers
    |> List.last()
    |> Map.get(:id)
    |> (fn starting_after -> query_params |> Map.put(:starting_after, starting_after) end).()
    |> do_list_customers(opts)
    |> all_customers(acc ++ new_customers, query_params, opts)
  end

  defp all_customers(resp, _acc, _query_params, _opts), do: resp

  defp do_list_customers(query_params, opts) do
    Api.request(
      :get,
      [resource: "/customers?" <> URI.encode_query(query_params |> reject_nil())],
      opts
    )
  end

  defp clean_customers({:error, _}), do: nil

  defp clean_customers({200, %{data: customers}}) do
    customers
    |> Enum.map(fn c -> {c[:description], c} end)
    |> Enum.into(%{})
    |> (fn mapped -> {:ok, mapped} end).()
  end

  defp reject_nil(map) do
    map
    |> Enum.reject(fn {_k, v} -> v == nil end)
    |> Enum.into(%{})
  end
end
