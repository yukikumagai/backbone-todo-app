class Item < ActiveRecord::Base
  # Associations
  belongs_to :list

  # Validations
  validates :shortdesc, presence: true
  validates :list,      presence: true

  def as_json(options = nil)
    super({ except: %i[longdesc list_id] }.merge(options || {}))
  end
end
