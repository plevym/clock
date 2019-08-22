class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  after_initialize :set_uuid, if: :new_record?

  def set_uuid
    self.id ||= SecureRandom.uuid
  end
end
