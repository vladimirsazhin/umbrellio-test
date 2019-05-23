describe 'GET /authors/with-same-ips' do
  it 'returns authors with same ips' do
    user_ids = DB[:users].returning(:id).multi_insert([{ login: 'foo' }, { login: 'bar' }, { login: 'baz' }])

    DB[:posts].multi_insert([
      { title: 'foo', content: 'bar', author_id: user_ids[0], author_ip: '1.2.3.4' },
      { title: 'foo', content: 'bar', author_id: user_ids[0], author_ip: '2.3.4.5' },
      { title: 'foo', content: 'bar', author_id: user_ids[0], author_ip: '1.2.3.4' },
      { title: 'foo', content: 'bar', author_ip: '1.2.3.4' },
      { title: 'foo', content: 'bar', author_id: user_ids[1] },
      { title: 'foo', content: 'bar', author_id: user_ids[1], author_ip: '1.2.3.4' },
      { title: 'foo', content: 'bar', author_id: user_ids[1], author_ip: '3.4.5.6' },
      { title: 'foo', content: 'bar', author_ip: '1.2.3.4' },
      { title: 'foo', content: 'bar', author_id: user_ids[2], author_ip: '4.5.6.7' },
      { title: 'foo', content: 'bar', author_id: user_ids[2], author_ip: '1.2.3.4' },
      { title: 'foo', content: 'bar', author_id: user_ids[2], author_ip: '2.3.4.5' },
      { title: 'foo', content: 'bar', author_id: user_ids[2], author_ip: '2.3.4.5' }
    ])

    get authors_with_same_ips_path

    expect(response).to have_http_status(200)

    expect(response.parsed_body).to be_an(Array)
    expect(response.parsed_body.size).to eq(2)

    expect(response.parsed_body[0].keys).to eq(%w(ip logins))
    expect(response.parsed_body[0]['ip']).to eq('1.2.3.4')
    expect(response.parsed_body[0]['logins']).to match_array(%w(foo bar baz))

    expect(response.parsed_body[1].keys).to eq(%w(ip logins))
    expect(response.parsed_body[1]['ip']).to eq('2.3.4.5')
    expect(response.parsed_body[1]['logins']).to match_array(%w(foo baz))

    # eq([
    #   { 'ip' => '1.2.3.4', 'logins' => ['foo', 'bar', 'baz' ]},
    #   { 'ip' => '2.3.4.5', 'logins' => ['foo', 'baz' ]}
    # ])
  end
end
