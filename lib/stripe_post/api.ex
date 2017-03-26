defmodule StripePost.Api do

  @doc """
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

end