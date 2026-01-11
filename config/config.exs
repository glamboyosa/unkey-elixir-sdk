import Config

# Optional test secret config (for local development/testing)
if File.exists?("config/test.secret.exs") do
  import_config("test.secret.exs")
end
