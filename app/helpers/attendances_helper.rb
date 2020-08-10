module AttendancesHelper

  def attendance_state(attendance)
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    return false
  end

  def working_times(start, finish, next_day)
    if next_day == true
      format("%.2f", (((finish - start) / 60) / 60.0) + 24)
    else
     format("%.2f", (((finish - start) / 60) / 60.0))
    end
  end
  
  def overtime(designated_work_end_time, next_day, scheduled_end_time, worked_on)
    if next_day == true
      format("%.2f", (((scheduled_end_time - worked_on.to_datetime.in_time_zone.change(hour: 17, min: 30, sec: 0)) / 60) / 60.0) + 24)
    else
      format("%.2f", (((scheduled_end_time - worked_on.to_datetime.in_time_zone.change(hour: 17, min: 30, sec: 0)) / 60) / 60.0))
    end
  end
  
end
