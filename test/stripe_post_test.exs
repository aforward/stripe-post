defmodule StripePostTest do
  use ExUnit.Case
  doctest StripePost
  doctest StripePost.Url
  doctest StripePost.Opts

  test "the truth" do
    assert 1 + 1 == 2
  end
end
