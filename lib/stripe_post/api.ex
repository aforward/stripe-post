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
    configs = %{secret_key: "sk_test_abc123"}

  """
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

      iex> StripePost.Api.headers(%{secret_key: "abc123"})
      [{"Authorization", "Bearer abc123"}, {"Content-Type", "application/x-www-form-urlencoded"}]
  """
  def headers(%{secret_key: secret_key}) do
    [{"Authorization", "Bearer #{secret_key}"},
     {"Content-Type", "application/x-www-form-urlencoded"}]
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

end