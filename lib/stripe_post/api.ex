defmodule StripePost.Api do

  alias StripePost.Api

  @doc"""
  Post a message to the Stripe API by providing all the necessary
  information.  The answer will be

    If successful
    {status_code, body}

    Under error
    {:error, reason}
  """
  def post(url, body, headers) do
    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {status_code, Poison.decode!(body)}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

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
  def charge(body), do: charge(body, nil)
  def charge(body, configs) do
    post(Api.url <> "/charges", encode_body(body), headers(configs))
  end

  @doc"""
  The Stripe API URL

  ## Examples

      iex> StripePost.Api.url
      "https://api.stripe.com/v1"

  """
  def url(), do: "https://api.stripe.com/v1"

  @doc"""
  Build the headers for your API

  ## Examples

      iex> StripePost.Api.headers(%{content_type: "application/json", secret_key: "abc123"})
      [{"Authorization", "Bearer abc123"}, {"Content-Type", "application/json"}]

      iex> StripePost.Api.headers(%{secret_key: "abc123"})
      [{"Authorization", "Bearer abc123"}, {"Content-Type", "application/x-www-form-urlencoded"}]

      iex> StripePost.Api.headers(%{})
      [{"Authorization", "Bearer sk_test_abc123"}, {"Content-Type", "application/x-www-form-urlencoded"}]

      iex> StripePost.Api.headers()
      [{"Authorization", "Bearer sk_test_abc123"}, {"Content-Type", "application/x-www-form-urlencoded"}]

  """
  def headers(), do: headers(%{})
  def headers(nil), do: headers(%{})
  def headers(data) do
    h = %{content_type: "application/x-www-form-urlencoded"}
    |> Map.merge(app_headers())
    |> Map.merge(reject_nil(data))

    [{"Authorization", "Bearer #{h[:secret_key]}"},
     {"Content-Type", h[:content_type]}]
  end

  @doc"""
  Encode the provided hash map for the URL.

  ## Examples

      iex> StripePost.Api.encode_body(%{a: "one", b: "two"})
      "a=one&b=two"

      iex> StripePost.Api.encode_body(%{a: "o ne"})
      "a=o+ne"

  """
  def encode_body(map), do: URI.encode_query(map)


  defp app_headers() do
    %{content_type: appenv(:content_type), secret_key: appenv(:secret_key)}
    |> reject_nil
  end

  defp appenv(key), do: Application.get_env(:stripe_post, key)

  defp reject_nil(map) do
    map
    |> Enum.reject(fn{_k,v} -> v == nil end)
    |> Enum.into(%{})
  end
end