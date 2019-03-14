defmodule StripePostTest do
  use ExUnit.Case
  doctest StripePost
  doctest StripePost.Url
  doctest StripePost.Opts
  doctest StripePost.Content
  doctest StripePost.Request

  test "the truth" do
    assert 1 + 1 == 2
  end
end
