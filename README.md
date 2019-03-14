# StripePost

A minimal library for posting messages to the Stripe API.

## Installation

Add `stripe_post` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:stripe_post, "~> 0.2.0"}]
end
```

## Configuration

Within your opts, you will need to provide your
[https://dashboard.stripe.com/account/apikeys](Stripe API Keys).  For example,

```elixir
 config :stripe_post,
   secret_key: "sk_test_abc123"
   public_key: "pk_test_abc123"
```

Documentation can
be found at [https://hexdocs.pm/stripe_post](https://hexdocs.pm/stripe_post).
