defmodule StripePost.Opts do

  @moduledoc"""
  Generate API options based on overwritten values, as well as
  any configured defaults.

  Please refer to `StripePost` for more details on configuring this library,
  the know what can be configured.
  """

  @doc"""
  Merge the `provided_opts` with the configured options from the
  `:stripe_post` application env, available from `StripePost.Opts.env/0`

  ## Example

      StripePost.Opts.merge([resource: "messages"])
  """
  def merge(provided_opts), do: merge(provided_opts, env(), nil)


  @doc"""
  Merge the `provided_opts` with an env `configured_key`.  Or, merge those
  `provided_opts` with the default application envs in `StripePost.Opts.env/0`,
  but only provide values for the `expected_keys`.

  ## Example

      # Merge the provided keyword list with the Application env for `:stripe_post`
      # but only take the `expected_keys` of `[:base, :resource]`
      StripePost.Opts.merge([resource: "messages"], [:base, :resource])

      # Merge the provided keyword list with the `:http_opts` from the
      # Application env for `:stripe_post`
      StripePost.Opts.merge([resource: "messages"], :http_opts)
  """
  def merge(provided_opts, configured_key_or_expected_keys) when is_atom(configured_key_or_expected_keys) do
    merge(provided_opts, env(configured_key_or_expected_keys), nil)
  end
  def merge(provided_opts, expected_keys) when is_list(expected_keys) do
    merge(provided_opts, env(), expected_keys)
  end

  @doc"""
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

  """
  def merge(provided_opts, nil, _), do: provided_opts
  def merge(provided_opts, configured_opts, expected_keys) do
    case expected_keys do
      nil -> configured_opts
      k -> configured_opts |> Keyword.take(k)
    end
    |> Keyword.merge(provided_opts)
  end

  @doc"""
  Lookup all application env values for `:stripe_post`

  ## Example

      # Return all environment variables for :stripe_post
      StripePost.Opts.env()

  """
  def env, do: Application.get_all_env(:stripe_post)

  @doc"""
  Lookup the `key` within the `:stripe_post` application.

  ## Example

      # Return the `:stripe_post` value for the `:base` key
      StripePost.Opts.env(:base)
  """
  def env(key), do: Application.get_env(:stripe_post, key)

end