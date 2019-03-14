defmodule StripePost.Url do
  @moduledoc """
  Generate the appropriate StripePost URL based on the sending
  domain, and the desired resource.
  """

  @base_url "https://api.stripe.com/v1"

  alias StripePost.Opts

  @doc """
  The API url for your domain, configurable using several `opts`
  (Keyword list of options).

  ## Available options:

    * `:base` - The base URL which defaults to `https://api.stripe.com/v1`
    * `:resource` - The requested resource (e.g. /domains)

  The options above can be defaulted using `Mix.Config` configurations,
  please refer to `StripePost` for more details on configuring this library.

  This function returns a fully qualified URL as a string.

  ## Example

      iex> StripePost.Url.generate()
      "https://api.stripe.com/v1"

      iex> StripePost.Url.generate(base: "http://localhost:4000/v2")
      "http://localhost:4000/v2"

      iex> StripePost.Url.generate(base: "http://localhost:4000/v2", resource: "stuff")
      "http://localhost:4000/v2/stuff"

      iex> StripePost.Url.generate(base: "http://localhost:4000/v2/", resource: "stuff")
      "http://localhost:4000/v2/stuff"

      iex> StripePost.Url.generate(base: "http://localhost:4000/v2/", resource: "/stuff")
      "http://localhost:4000/v2/stuff"

      iex> StripePost.Url.generate(base: "http://localhost:4000/v2", resource: "/stuff")
      "http://localhost:4000/v2/stuff"

      iex> StripePost.Url.generate()
      "https://api.stripe.com/v1"

      iex> StripePost.Url.generate(resource: "logs")
      "https://api.stripe.com/v1/logs"

      iex> StripePost.Url.generate(resource: "tags/t1")
      "https://api.stripe.com/v1/tags/t1"

      iex> StripePost.Url.generate(resource: ["tags", "t1", "stats"])
      "https://api.stripe.com/v1/tags/t1/stats"

      iex> StripePost.Url.generate([resource: ["tags", "t1", "stats"]], [base: "http://localhost:4000/v2"])
      "http://localhost:4000/v2/tags/t1/stats"

      iex> StripePost.Url.generate([resource: ["tags", "t1", "stats"], base: "http://localhost:4000/v3"], [base: "http://localhost:4000/v2"])
      "http://localhost:4000/v3/tags/t1/stats"
  """
  def generate(), do: _generate([], [])
  def generate(overwritten_opts), do: _generate(overwritten_opts, [])
  def generate(overwritten_opts, default_opts), do: _generate(overwritten_opts, default_opts)

  defp _generate(overwritten_opts, default_opts) do
    overwritten_opts
    |> Opts.merge(default_opts, [:base, :resource])
    |> (fn all_opts ->
          [
            Keyword.get(all_opts, :base, @base_url),
            Keyword.get(all_opts, :resource, [])
          ]
        end).()
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn s -> s |> String.trim("/")  end)
    |> Enum.join("/")
  end
end
