defmodule StripePost.Opts do
  @moduledoc """
  Generate API options based on overwritten values, as well as
  any configured defaults.

  Please refer to `StripePost` for more details on configuring this library,
  the know what can be configured.
  """

  @doc """
  Merge the `provided_opts` with the `configured_opts`.  Only provide
  values for the `expected_keys` (if `nil` then merge all keys from
  `configured_opts`).

  ## Example

      iex> StripePost.Opts.merge(
      ...>   [resource: "messages"],
      ...>   [base: "http://localhost:4000/v2", resource: "log", timeout: 5000],
      ...>   [:resource, :base])
      [base: "http://localhost:4000/v2", resource: "messages"]

      iex> StripePost.Opts.merge(
      ...>   [resource: "messages"],
      ...>   [base: "http://localhost:4000/v2", resource: "log", timeout: 5000],
      ...>   nil)
      [base: "http://localhost:4000/v2", timeout: 5000, resource: "messages"]

      iex> StripePost.Opts.merge(
      ...>   [resource: "messages"],
      ...>   nil,
      ...>   nil)
      [reload_on_init: false, public_key: "pk_test_def456", secret_key: "sk_test_abc123", resource: "messages"]
  """
  def merge(provided_opts), do: merge(provided_opts, nil, nil)
  def merge(provided_opts, configured_opts), do: merge(provided_opts, configured_opts, nil)
  def merge(provided_opts, nil, expected_keys), do: merge(provided_opts, env(), expected_keys)

  def merge(provided_opts, configured_opts, expected_keys) do
    case expected_keys do
      nil -> configured_opts
      k -> configured_opts |> Keyword.take(k)
    end
    |> Keyword.merge(provided_opts)
  end

  @doc """
  Lookup all application env values for `:stripe_post`

  ## Example

      # Return all environment variables for :stripe_post
      StripePost.Opts.env()

  """
  def env, do: Application.get_all_env(:stripe_post)

  @doc """
  Lookup the `key` within the `:stripe_post` application.

  ## Example

      # Return the `:stripe_post` value for the `:base` key
      StripePost.Opts.env(:base)
  """
  def env(key), do: Application.get_env(:stripe_post, key)
end
