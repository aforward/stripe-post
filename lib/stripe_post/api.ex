defmodule StripePost.Api do
  @moduledoc """
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

  alias StripePost.{Opts, Content, Request, Response}

  @doc """
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
  def request(method, opts), do: request(method, opts, nil)

  def request(method, provided_opts, configured_opts) do
    provided_opts
    |> Opts.merge(configured_opts)
    |> (fn opts ->
          case method do
            :post -> Opts.merge(opts, content_type: "application/x-www-form-urlencoded")
            _ -> opts
          end
        end).()
    |> _request(method)
  end

  defp _request(opts, method) do
    opts
    |> Request.create()
    |> Request.send(method)
    |> Response.normalize()
    |> Content.type()
    |> Content.decode()
  end
end
