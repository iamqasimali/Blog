class Post < ApplicationRecord
  validates :title,  length: { minimum: 4, maximum: 500 }
  validates :body,  length: { minimum: 70, maximum: 99889 }
  belongs_to :user, optional: false
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :bookmarks, as: :bookmarkable, dependent: :destroy

  has_many :taggables, dependent: :destroy
  has_many :tags, through: :taggables

  def reading_time
    words_per_minute = 150
    text = Nokogiri::HTML(self.body).at('body').inner_text
    (text.scan(/\w+/).length / words_per_minute).to_i
  end
end