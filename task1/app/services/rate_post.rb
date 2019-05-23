class RatePost
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :post_id, :integer
  attribute :value, :integer

  validates_presence_of :post_id, :value
  validates_inclusion_of :value, in: 1..5, allow_blank: true, message: :invalid

  def call
    validate!

    DB.transaction do
      begin
        DB[:ratings].insert(post_id: post_id, value: value)
      rescue Sequel::ForeignKeyConstraintViolation
        errors.add(:post_id, :invalid)
        raise_validation_error
      end

      new_ratings_sum = Sequel[:ratings_sum] + value
      new_ratings_count = Sequel[:ratings_count] + 1

      DB[:posts]
        .where(id: post_id)
        .returning(:rating)
        .update(
          ratings_sum: new_ratings_sum,
          ratings_count: new_ratings_count,
          rating: Sequel.cast(new_ratings_sum, BigDecimal) / new_ratings_count
        )
        .first
        .fetch(:rating)
        .to_s
    end
  end
end
