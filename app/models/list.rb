class List < ActiveRecord::Base
  # Associations
  has_many :items, dependent: :destroy

  # Callbacks
  before_create :generate_token

  # Validations
  validates :token, uniqueness: true, allow_nil: true

  # Scopes / finders
  def self.find_by_token(token)
    includes(:items).where(token: token).limit(1).first
  end

  # Returns the Pusher channel name for this list.
  def channel_name
    @channel_name ||= "list-#{Rails.env}-#{sanitise_token(token)}"
  end

  def as_json(options = nil)
    super({
      except:  :id,
      methods: [:total_count, :remaining_count],
      include: {
        items: { only: %i[id created_at updated_at shortdesc isdone] }
      }
    }.merge(options || {}))
  end

  def total_count
    items.count
  end

  def remaining_count
    items.where(isdone: false).count
  end

  private

  def generate_token
    loop do
      candidate = sanitise_token(ActiveSupport::SecureRandom.base64(8))
      unless self.class.exists?(token: candidate)
        self.token = candidate
        break
      end
    end
  end

  # Strips characters that are invalid in Pusher channel names.
  def sanitise_token(str)
    str.gsub(%r{[/+=]}, '')
  end
end
