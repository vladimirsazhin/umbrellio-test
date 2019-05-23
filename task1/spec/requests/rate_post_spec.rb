describe 'POST /posts/rate' do
  it 'fails validation with empty params' do
    post rate_post_path

    expect(response).to have_http_status(422)
    expect(response.parsed_body).to eq({
      'errors' => { 'post_id' => ['can\'t be blank'], 'value' => ['can\'t be blank'] }
    })
  end

  it 'fails validation with invalid post_id' do
    post rate_post_path, params: { post_id: 999, value: 5 }

    expect(response).to have_http_status(422)
    expect(response.parsed_body).to eq({ 'errors' => { 'post_id' => ['is invalid'] } })
  end

  it 'fails validation with invalid value' do
    post rate_post_path, params: { value: 0 }

    expect(response).to have_http_status(422)
    expect(response.parsed_body).to eq({
      'errors' => { 'post_id'=>['can\'t be blank'], 'value' => ['is invalid'] }
    })

    post rate_post_path, params: { value: 6 }

    expect(response).to have_http_status(422)
    expect(response.parsed_body).to eq({
      'errors' => { 'post_id'=>['can\'t be blank'], 'value' => ['is invalid'] }
    })
  end

  it 'rates a Post and returns new rating' do
    post = DB[:posts].returning(:id, :rating).insert(title: 'foo', content: 'bar').first

    expect(post.fetch(:rating)).to eq(0)

    post rate_post_path, params: { post_id: post.fetch(:id), value: 1 }

    expect(response).to have_http_status(200)
    expect(response.parsed_body).to eq(1.0)

    post rate_post_path, params: { post_id: post.fetch(:id), value: 2 }

    expect(response).to have_http_status(200)
    expect(response.parsed_body).to eq(1.5)

    post rate_post_path, params: { post_id: post.fetch(:id), value: 4 }

    expect(response).to have_http_status(200)
    expect(response.parsed_body).to eq(2.3333333333333335)

    post rate_post_path, params: { post_id: post.fetch(:id), value: 2 }

    expect(response).to have_http_status(200)
    expect(response.parsed_body).to eq(2.25)

    post rate_post_path, params: { post_id: post.fetch(:id), value: 4 }

    expect(response).to have_http_status(200)
    expect(response.parsed_body).to eq(2.6)

    post rate_post_path, params: { post_id: post.fetch(:id), value: 5 }

    expect(response).to have_http_status(200)
    expect(response.parsed_body).to eq(3.0)
  end
end
