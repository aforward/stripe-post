defmodule StripePost do
  @moduledoc """
  A minimal library for posting messages to the Stripe API.
  """

  defdelegate post(url, body, headers), to: StripePost.Worker

end
