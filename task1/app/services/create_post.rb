require 'ipaddr'

class CreatePost
  include ActiveModel::Model

  attr_accessor :title, :content, :author_login, :author_ip

  validates_presence_of :title, :content

  validate :validate_author_ip

  def call
    validate!

    DB.transaction do
      author = find_or_create_author

      DB[:posts]
        .returning(:id)
        .insert(
          title: title,
          content: content,
          author_id: author.try(:fetch, :id),
          author_ip: author_ip
        )
        .first
        .merge(title: title, content: content, rating: 0, author: author)
    end
  end

  private

  def find_or_create_author
    return if author_login.blank?

    { id: existing_author_id || created_author_id, login: author_login, ip: author_ip }
  end

  def existing_author_id
    DB[:users].where(login: Sequel.function(:lower, author_login)).get(:id)
  end

  def created_author_id
    id = DB[:users]
         .returning(:id)
         .insert_conflict(target: Sequel.function(:lower, :login))
         .insert(login: author_login)
         .first
         .try(:fetch, :id)

    id || existing_author_id
  end

  def validate_author_ip
    return if author_ip.blank?

    raise IPAddr::Error if author_ip.include?('/')

    @author_ip = IPAddr.new(author_ip).to_s
  rescue IPAddr::Error
    errors.add(:author_ip, :invalid)
  end
end
