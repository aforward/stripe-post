defmodule StripePost.Api do

  @moduledoc"""
  Take several options, and an HTTP method and send the request to StripePost

  The available options are comprised of those to helper generate the StripePost
  URL, to extract data for the request and authenticate your API call.

  URL `opts` (to help create the resolved StripePost URL):
    * `:base` - The base URL which defaults to `http://localhost:4000/v1`
    * `:resource` - The requested resource (e.g. /domains)

  Data `opts` (to send data along with the request)
    * `:body` - The encoded body of the request (typically provided in JSON)
    * `:params` - The query parameters of the request

  Header `opts` (to send meta-data along with the request)
    * `:api_key` - Defaults to the test API key `key-3ax6xnjp29jd6fds4gc373sgvjxteol0`
  """

  alias StripePost.{Content, Request, Response}

  @doc"""
  Issues an HTTP request with the given method to the given url_opts.

  Args:
    * `method` - HTTP method as an atom (`:get`, `:head`, `:post`, `:put`, `:delete`, etc.)
    * `opts` - A keyword list of options to help create the URL, provide the body and/or query params

  The options above can be defaulted using `Mix.Config` configurations,
  please refer to `StripePost` for more details on configuring this library.

  This function returns `{<status_code>, response}` if the request is successful, and
  `{:error, reason}` otherwise.

  ## Examples

      StripePost.Api.request(:get, resource: "customers", bearer_auth: "sk_test_ABC123")

  """
  def request(method, opts \\ []) do
    opts
    |> Request.create
    |> Request.send(method)
    |> Response.normalize
    |> Content.type
    |> Content.decode
  end

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
         Content.encode(body, headers[:body_type] || headers[:content_type]),
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

  defp app_headers() do
    %{content_type: appenv(:content_type), secret_key: appenv(:secret_key)}
    |> reject_nil
  end

  defp appenv(key), do: Application.get_env(:stripe_post, key)

  defp parse({:ok, %HTTPoison.Response{body: body, status_code: status_code}}) do
    {status_code, Jason.decode!(body)}
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