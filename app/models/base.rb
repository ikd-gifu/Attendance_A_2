class Base < ApplicationRecord
    validates :base_name, presence: true, length: { maximum: 50 }
    validates :attendance_type, presence: true, length: { maximum: 10 }
end
