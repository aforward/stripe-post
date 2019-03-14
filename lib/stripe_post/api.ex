defmodule StripePost.Api do

  @doc"""
  Retrieve data from the API using either :get or :post
  """
  def http(:get, %{source: source, headers: headers}), do: get(source, headers)
  def http(:get, %{source: source}), do: get(source)
  def http(:post, %{source: source, body: body, headers: headers}), do: post(source, body, headers)
  def http(:post, %{source: source, body: body}), do: post(source, body)
  def http(:post, %{source: source}), do: post(source)

  @doc"""
  Make an API call using GET.  Optionally provide any required headers
  """
  def get(source), do: get(source, nil)
  def get(source, headers) do
    source
    |> HTTPoison.get(encode_headers(headers))
    |> parse
  end

  @doc"""
  Post a message to the Stripe API by providing all the necessary
  information.  The answer will be

  If the call succeeds, the response will look like

      {status_code, body}

  Where the status_code is the response code from the API, e.g. 200

  If there is an error, we will return something like

      {:error, "some reason"}
  """
  def post(source), do: post(source, %{}, %{})
  def post(source, body), do: post(source, body, %{})
  def post(source, body, headers) do
    source
    |> HTTPoison.post(
         encode_body(headers[:body_type] || headers[:content_type], body),
         encode_headers(headers)
       )
    |> parse
  end

  @doc"""
  Build the headers for your API

  ## Examples

      iex> StripePost.Api.encode_headers(%{content_type: "application/json", secret_key: "abc123"})
      [{"Authorization", "Bearer abc123"}, {"Content-Type", "application/json"}]

      iex> StripePost.Api.encode_headers(%{secret_key: "abc123"})
      [{"Authorization", "Bearer abc123"}, {"Content-Type", "application/x-www-form-urlencoded"}]

      iex> StripePost.Api.encode_headers(%{})
      [{"Authorization", "Bearer sk_test_abc123"}, {"Content-Type", "application/x-www-form-urlencoded"}]

      iex> StripePost.Api.encode_headers()
      [{"Authorization", "Bearer sk_test_abc123"}, {"Content-Type", "application/x-www-form-urlencoded"}]

  """
  def encode_headers(), do: encode_headers(%{})
  def encode_headers(nil), do: encode_headers(%{})
  def encode_headers(data) do
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

      iex> StripePost.Api.encode_body(nil, %{a: "o ne"})
      "a=o+ne"

      iex> StripePost.Api.encode_body("application/x-www-form-urlencoded", %{a: "o ne"})
      "a=o+ne"

      iex> StripePost.Api.encode_body("application/json", %{a: "b"})
      "{\\"a\\":\\"b\\"}"

  """
  def encode_body(map), do: encode_body(nil, map)
  def encode_body(nil, map), do: encode_body("application/x-www-form-urlencoded", map)
  def encode_body("application/x-www-form-urlencoded", map), do: URI.encode_query(map)
  def encode_body("application/json", map), do: Poison.encode!(map)
  def encode_body(_encoding_type, map), do: encode_body(nil, map)

  defp app_headers() do
    %{content_type: appenv(:content_type), secret_key: appenv(:secret_key)}
    |> reject_nil
  end

  defp appenv(key), do: Application.get_env(:stripe_post, key)

  defp parse({:ok, %HTTPoison.Response{body: body, status_code: status_code}}) do
    {status_code, Poison.decode!(body)}
  end
  defp parse({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end

  def reject_nil(map) do
    map
    |> Enum.reject(fn{_k,v} -> v == nil end)
    |> Enum.into(%{})
  end
end