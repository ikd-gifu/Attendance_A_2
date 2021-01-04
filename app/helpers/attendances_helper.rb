module AttendancesHelper

  def attendance_state(attendance)
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    return false
  end

  def working_times(start, finish, next_day)
    if next_day == true && (finish < start)
      format("%.2f", (((finish.floor_to(15.minutes) - start.floor_to(15.minutes)) / 60) / 60.0) + 24)
    else
      format("%.2f", (((finish.floor_to(15.minutes) - start.floor_to(15.minutes)) / 60) / 60.0))
    end
  end
  
  # def working_times(start, finish, next_day)
  #   if next_day == true
  #     format("%.2f", (((finish - start) / 60) / 60.0) + 24)
  #   else
  #     format("%.2f", (((finish - start) / 60) / 60.0))
  #   end
  # end

    #15分単位で表示する
  def format_hour(time)
    format("%2d",  time.hour)
  end

  def format_min(time)
    format("%2d", (time.min / 15) * 15)
  end

  def overtime(designated_work_end_time, next_day, scheduled_end_time, worked_on)
    @corrected_scheduled_end_time = scheduled_end_time.change(month: worked_on.month, day: worked_on.day, sec: 0)
    @corrected_designated_work_end_time = worked_on.to_datetime.in_time_zone.change(hour: 17, min: 30, sec: 0)
    if next_day == true
      format("%.2f", (((@corrected_scheduled_end_time.floor_to(15.minutes) - @corrected_designated_work_end_time.floor_to(15.minutes)) / 60) / 60.0) + 24)
    else
      format("%.2f", (((@corrected_scheduled_end_time.floor_to(15.minutes) - @corrected_designated_work_end_time.floor_to(15.minutes)) / 60) / 60.0))
    end
  end
  
end
