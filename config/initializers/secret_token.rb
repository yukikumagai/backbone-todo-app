# Be sure to restart your server when you modify this file.
#
# The secret key is read from the environment so that it is never hard-coded
# in the repository.  Set SECRET_TOKEN to a random string of at least 30
# characters in your environment / Heroku config before deploying.
Todos::Application.config.secret_token =
  ENV.fetch('SECRET_TOKEN') do
    raise 'SECRET_TOKEN environment variable is not set'
  end
