# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_fix_the_buses_session',
  :secret      => '02e760a67fe95afd0a2cbff684c8b8733a195a6198ab64c9dccb33a8e3dec0ca8e2b88a7a64ca63b2a1ad51cd9f8fe944585decb4e880ad33cc8cc0c87ec5c3e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
