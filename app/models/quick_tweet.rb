class QuickTweet < ApplicationRecord
  validates :content, presence: true, length: { minimum: 10, maximum: 1000 }, uniqueness: true
  validate :content_emptiness
  before_save :purify

  after_create_commit -> {
    broadcast_prepend_to :quick_tweets, target: "quick_tweets", locals: { quick_tweets: :quick_tweets }
    #                      turbo_stream_from          with be replace by this            with this id             using these values
  }
  default_scope { order(created_at: :desc) }

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  belongs_to :user, optional: true
  has_one_attached :image, dependent: :destroy
  has_many :bookmarks, as: :bookmarkable, dependent: :destroy

  # trim leading and trailing spaces: suggested by @diwash007
  def content_emptiness
    pure_text = Nokogiri::HTML(content).
      xpath('//text()').map(&:text).join('').
      strip
    if pure_text.length <= 0
      errors.add :content, "is completely empty, please write something!"
    end
  end

  def purify
    self.content = ApplicationController.helpers.purify self.content
  end
  def title
    Nokogiri::HTML(self.content).xpath('//text()').map(&:text).join(' ').truncate(100)
  end

  def excerpt
    Nokogiri::HTML(self.content).xpath('//text()').map(&:text).join(' ').truncate(300)
  end

  def generate_og_image
    image_file_io, image_name = ApplicationController.helpers.create_og_image(self.title)
    self.image.attach(io: image_file_io, filename: image_name, content_type: 'image/png')
  end

end


