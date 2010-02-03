# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rubytravel_session',
  :secret      => 'e34e4fe062e209c00637657481efc1a77a4251e6b8f86ad2b504d4b122557b280bbe40066e70fa8a78ac084e46fb7a43dd942f3ede8350cda7c984ce9047df2c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
