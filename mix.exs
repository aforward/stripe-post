defmodule StripePost.Mixfile do
  use Mix.Project

  @git_url "https://github.com/aforward/stripe-post"
  @home_url @git_url
  @version "0.4.1"

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

  def application do
    [extra_applications: [:logger],
     mod: {StripePost.Application, []}]
  end

  defp deps do
    [{:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
     {:poison, "~> 3.1.0"},
     {:httpoison, "~> 0.11.1"},
     {:version_tasks, "~> 0.10"},
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
