use Mix.Config

# You will need to configure your public and private keys in Stripe.
# optionally you can also set the default content type
# https://dashboard.stripe.com/account/apikeys
# config :stripe_post,
#   reload_on_init: true # <-- set to true if you want to cache all your client ID
#   secret_key: "sk_test_abc123"
#   public_key: "pk_test_abc123"
#   content_type: "application/x-www-form-urlencoded"
#
# Within the application we will reference these using
#   Application.get_env(:stripe_post, :reload_on_init)
#   Application.get_env(:stripe_post, :secret_key)
#   Application.get_env(:stripe_post, :public_key)
#   Application.get_env(:stripe_post, :content_type)
#

if (File.exists?("./config/#{Mix.env}.exs")) do
  import_config "#{Mix.env}.exs"
end
