describe 'GET /posts/top' do
  it 'fails validation with empty params' do
    get top_posts_path

    expect(response).to have_http_status(422)
    expect(response.parsed_body).to eq({ 'errors' => { 'n' => ['can\'t be blank'] } })
  end

  it 'fails validation with invalid params' do
    get top_posts_path, params: { n: 'foo' }

    expect(response).to have_http_status(422)
    expect(response.parsed_body).to eq({ 'errors' => { 'n' => ['is invalid'] } })
  end

  it 'returns top posts' do
    DB[:posts].multi_insert([
      { title: 't06', content: 'c06', rating: BigDecimal('3.3333333333333333'), ratings_count: 3,   ratings_sum: 10   },
      { title: 't08', content: 'c08', rating: BigDecimal('3.2857142857142857'), ratings_count: 21,  ratings_sum: 69   },
      { title: 't05', content: 'c05', rating: BigDecimal('4.0454545454545455'), ratings_count: 22,  ratings_sum: 89   },
      { title: 't10', content: 'c10', rating: BigDecimal('3.0242214532871972'), ratings_count: 289, ratings_sum: 874  },
      { title: 't02', content: 'c02', rating: BigDecimal('5.0000000000000000'), ratings_count: 2,   ratings_sum: 10   },
      { title: 't09', content: 'c09', rating: BigDecimal('3.0323253388946820'), ratings_count: 959, ratings_sum: 2908 },
      { title: 't07', content: 'c07', rating: BigDecimal('3.2857142857142857'), ratings_count: 35,  ratings_sum: 115  },
      { title: 't04', content: 'c04', rating: BigDecimal('4.2500000000000000'), ratings_count: 8,   ratings_sum: 34   },
      { title: 't11', content: 'c11', rating: BigDecimal('2.9826589595375723'), ratings_count: 346, ratings_sum: 1032 },
      { title: 't03', content: 'c03', rating: BigDecimal('4.6666666666666667'), ratings_count: 3,   ratings_sum: 14   },
      { title: 't12', content: 'c12', rating: BigDecimal('2.9415121255349501'), ratings_count: 701, ratings_sum: 2062 },
      { title: 't01', content: 'c01', rating: BigDecimal('5.0000000000000000'), ratings_count: 3,   ratings_sum: 15   },
      { title: 't13', content: 'c13', rating: BigDecimal('2.7793427230046948'), ratings_count: 213, ratings_sum: 592  },
    ])

    get top_posts_path, params: { n: 1 }

    expect(response).to have_http_status(200)

    expect(response.parsed_body).to eq([
      { 'title' => 't01', 'content' => 'c01' }
    ])

    get top_posts_path, params: { n: 6 }

    expect(response).to have_http_status(200)

    expect(response.parsed_body).to eq([
      { 'title' => 't01', 'content' => 'c01' },
      { 'title' => 't02', 'content' => 'c02' },
      { 'title' => 't03', 'content' => 'c03' },
      { 'title' => 't04', 'content' => 'c04' },
      { 'title' => 't05', 'content' => 'c05' },
      { 'title' => 't06', 'content' => 'c06' }
    ])

    get top_posts_path, params: { n: 20 }

    expect(response).to have_http_status(200)

    expect(response.parsed_body).to eq([
      { 'title' => 't01', 'content' => 'c01' },
      { 'title' => 't02', 'content' => 'c02' },
      { 'title' => 't03', 'content' => 'c03' },
      { 'title' => 't04', 'content' => 'c04' },
      { 'title' => 't05', 'content' => 'c05' },
      { 'title' => 't06', 'content' => 'c06' },
      { 'title' => 't07', 'content' => 'c07' },
      { 'title' => 't08', 'content' => 'c08' },
      { 'title' => 't09', 'content' => 'c09' },
      { 'title' => 't10', 'content' => 'c10' },
      { 'title' => 't11', 'content' => 'c11' },
      { 'title' => 't12', 'content' => 'c12' },
      { 'title' => 't13', 'content' => 'c13' }
    ])
  end
end
