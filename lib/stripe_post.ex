defmodule StripePost do
  @moduledoc """
  A minimal library for posting messages to the Stripe API.
  """
  defdelegate reload, to: StripePost.Worker

  defdelegate charge(body), to: StripePost.Client

  defdelegate customers, to: StripePost.Worker
  defdelegate customer(name), to: StripePost.Worker

end
