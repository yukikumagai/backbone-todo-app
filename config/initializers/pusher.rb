require 'pusher'

# Credentials are read from environment variables so that secrets are never
# committed to version control.  Set PUSHER_APP_ID, PUSHER_KEY, and
# PUSHER_SECRET in your environment (or via a tool such as dotenv / Heroku
# config vars) before starting the application.
Pusher.app_id = ENV.fetch('PUSHER_APP_ID', '5493')
Pusher.key    = ENV.fetch('PUSHER_KEY',    '511a5abb7486107ce643')
Pusher.secret = ENV.fetch('PUSHER_SECRET', '')
