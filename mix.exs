defmodule StripePost.Mixfile do
  use Mix.Project

  @git_url "https://github.com/aforward/stripe-post"
  @home_url @git_url
  @version "0.4.0"

  def project do
    [app: :stripe_post,
     version: @version,
     elixir: "~> 1.4",
     name: "StripePost",
     description: "A minimal library for posting messages to the Stripe API.",
     package: package(),
     source_url: @git_url,
     homepage_url: @home_url,
     docs: [main: "StripePost",
            extras: ["README.md"]],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {StripePost.Application, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
     {:poison, "~> 3.1.0"},
     {:httpoison, "~> 0.11.1"},
     {:fn_expr, "~> 0.1.0"},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp package do
    [name: :stripe_post,
     files: ["lib", "mix.exs", "README*", "README*", "LICENSE*"],
     maintainers: ["Andrew Forward"],
     licenses: ["MIT"],
     links: %{"GitHub" => @git_url}]
  end
end
