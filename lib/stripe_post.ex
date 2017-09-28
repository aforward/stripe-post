defmodule StripePost do
  @moduledoc"""
  A minimal library for posting messages to the Stripe API.
  """

  @doc"""
  Charge an account with the following body configurations

      StripePost.charge(
        %{amount: 10000,
          currency: "cad",
          description: "3 wozzle",
          source: "pk_abc_123"}
      )

  Where the `source` is the payment token received from Stripe most likely
  in your client javascriopt.


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
  defdelegate charge(body), to: StripePost.Client

  @doc"""
  Sync customer information directly from Stripe into Worder.
  This will lookup all customers in Stripe for easy access within
  this library.

      StripePost.reload

  This will reload all customers from the Stripe API in the background
  so the response will be

      :ok

  """
  defdelegate reload, to: StripePost.Worker

  @doc"""
  Retrieve all customers stored within this process

      StripePost.customers

  On first call, this will return an empty map.

      %{}

  If you have customers, then you need to explicitly call reload

      StripePost.reload

  Afterwhich you will now receive customers such as

      %{"abc123" => "cus_AunbC99p7tNQj",
        "abc456" => "cus_AuncZ98ePY18"}

  Where the key (e.g. `"abc123"`) is your public id for the customer
  (stored as the description), and the value (e.g. `"cus_AunbC99p7tNQj"`)
  is the Stripe ID.
  """
  defdelegate customers, to: StripePost.Worker

  @doc"""
  Retrieve (and create if missing) the customer by the provided
  (and globally unique aka "public id") name.

      StripePost.customer("c12ab54612ad")

  """
  defdelegate customer(name), to: StripePost.Worker

end
