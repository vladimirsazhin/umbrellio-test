describe 'POST /posts/create' do
  let :valid_params do
    {
      title: 'foo',
      content: 'bar',
      author_login: 'john',
      author_ip: '1.2.3.4'
    }
  end

  it 'creates a Post with valid params' do
    post create_post_path, params: valid_params

    expect(response).to have_http_status(200)
    expect(response.parsed_body['id']).to be_an(Integer)
    expect(response.parsed_body['title']).to eq(valid_params[:title])
    expect(response.parsed_body['content']).to eq(valid_params[:content])
    expect(response.parsed_body['rating']).to eq(0)
    expect(response.parsed_body['author']['id']).to be_an(Integer)
    expect(response.parsed_body['author']['login']).to eq(valid_params[:author_login])
    expect(response.parsed_body['author']['ip']).to eq(valid_params[:author_ip])
  end

  it 'creates a Post with valid required params' do
    post create_post_path, params: valid_params.slice(:title, :content)

    expect(response).to have_http_status(200)
    expect(response.parsed_body['id']).to be_an(Integer)
    expect(response.parsed_body['title']).to eq(valid_params[:title])
    expect(response.parsed_body['content']).to eq(valid_params[:content])
    expect(response.parsed_body['rating']).to eq(0)
    expect(response.parsed_body['author']).to be_nil
  end

  it 'fails validation with empty params' do
    post create_post_path

    expect(response).to have_http_status(422)
    expect(response.parsed_body).to eq({
      'errors' => { 'content' => ['can\'t be blank'], 'title' => ['can\'t be blank'] }
    })
  end

  it 'fails validation with blank title' do
    post create_post_path, params: valid_params.except(:title)

    expect(response).to have_http_status(422)
    expect(response.parsed_body).to eq({ 'errors' => { 'title' => ['can\'t be blank'] }})
  end

  it 'fails validation with blank content' do
    post create_post_path, params: valid_params.except(:content)

    expect(response).to have_http_status(422)
    expect(response.parsed_body).to eq({ 'errors' => { 'content' => ['can\'t be blank'] }})
  end

  it 'creates a Post with valid params and IPv6 author_ip' do
    post create_post_path, params: valid_params.merge(author_ip: '2001:4860:4860::8888')

    expect(response).to have_http_status(200)
    expect(response.parsed_body['author']['ip']).to eq('2001:4860:4860::8888')

    post create_post_path, params: valid_params.merge(author_ip: '2001:4860:4860:0:0:0:0:8888')

    expect(response).to have_http_status(200)
    expect(response.parsed_body['author']['ip']).to eq('2001:4860:4860::8888')

    post create_post_path, params: valid_params.merge(author_ip: '2001:0db8:85a3:0000:0000:8a2e:0370:7334')

    expect(response).to have_http_status(200)
    expect(response.parsed_body['author']['ip']).to eq('2001:db8:85a3::8a2e:370:7334')
  end

  it 'fails validation with invalid author_ip' do
    post create_post_path, params: valid_params.merge(author_ip: '1.2.3.256')
    expect(response).to have_http_status(422)
    expect(response.parsed_body).to eq({ 'errors' => { 'author_ip' => ['is invalid'] }})

    post create_post_path, params: valid_params.merge(author_ip: '1.2.3.4/255')
    expect(response).to have_http_status(422)
    expect(response.parsed_body).to eq({ 'errors' => { 'author_ip' => ['is invalid'] }})
  end
end
