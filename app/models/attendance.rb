class Attendance < ApplicationRecord
  belongs_to :user

  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  validates :business_process_content, length: { maximum: 200 }, allow_blank: true
  
  # validates :scheduled_end_time, presence: true
  # validates :overtime_application_target_superior_id, presence: true

  # def without_scheduled_end_time_is_invalid
  #   errors.add(:scheduled_end_time, "を入力してください。") if scheduled_end_time.nil?
  # end
  
  # def without_overtime_application_target_superior_id_is_invalid
  #   errors.add(:overtime_application_target_superior_id, "を入力してください。") if overtime_application_target_superior_id.nil?
  # end

  validate :finished_at_is_invalid_without_a_started_at
  validate :started_at_than_finished_at_fast_if_invalid

  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end

  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end
end
