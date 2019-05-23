class GetTopPosts
  include ActiveModel::Model

  attr_accessor :n

  validates_presence_of :n

  validates_numericality_of :n, only_integer: true, greater_than: 0, allow_blank: true, message: :invalid

  def call
    validate!

    DB[:posts]
      .limit(n)
      .select(:title, :content)
      .order(:rating, :ratings_count)
      .reverse
  end
end
