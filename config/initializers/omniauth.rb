Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['ABLE_GATE_GOOGLE_CLIENT_ID'], ENV['ABLE_GATE_GOOGLE_CLIENT_SECRET'], domain: 'localhost'
end
