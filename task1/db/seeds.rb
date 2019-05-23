require 'securerandom'

app = ActionDispatch::Integration::Session.new(Rails.application)

user_logins = Array.new(100) { SecureRandom.hex(12) }

20_000.times do |i|
  app.post('/posts/create', params: {
    title: SecureRandom.hex(50),
    content: SecureRandom.hex(100),
    author_login: user_logins.sample,
    author_ip: "1.2.#{rand(1..100)}.#{rand(1..100)}"
  })

  post_id = app.response.parsed_body.fetch('id')

  rand(0..50).times do
    app.post('/posts/rate', params: {
      post_id: post_id,
      value: rand(1..5)
    })
  end

  puts "#{i + 1} posts created" if ((i + 1) % 1000).zero?
end
