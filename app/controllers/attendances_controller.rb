class AttendancesController < ApplicationController
  protect_from_forgery with: :null_session
  
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_one_day_overtime_application, :update_one_day_overtime_application,
                                  :edit_overtime_application_notification, :update_overtime_application_notification,
                                  :edit_attendance_change_application_notification, :update_attendance_change_application_notification,:attendance_modifying_log]
  before_action :logged_in_user, only: [:update, :edit_one_month, :edit_one_day_overtime_application, :update_one_day_overtime_application, 
                                        :edit_overtime_application_notification, :update_overtime_application_notification,:attendance_modifying_log]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: [:edit_one_month, :edit_one_day_overtime_application]

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])

    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  def edit_one_month #before_actionのadmin_or_correct_userに追加 #勤怠変更申請
    if current_user.admin?
      flash[:danger] = '権限がありません'
      redirect_to root_url
    end
    @selected_superior_users_for_change = User.where(superior: true).where.not(id: @user.id)
  end

  def update_one_month #勤怠変更申請
    ActiveRecord::Base.transaction do
      attendance_change_application_params.each do |id, item|
        if item[:attendance_change_application_target_superior_id].present? #"否認"の場合 target_superior_id は nil
          attendance = Attendance.find(id)
            if attendance.attendance_change_application_status == nil || attendance.attendance_change_application_status == "" || attendance.attendance_change_application_status == "否認" #"なし"含む
              # if item[:started_at] == "" || item[:finished_at] == "" || item[:started_at_after_change] == "" || item[:finished_at_after_change] == ""
                # attendance = false
              # if item[:started_at_after_change].present? && item[:finished_at_after_change].present?
                # if attendance.started_at_before_change == nil && attendance.finished_at_before_change == nil
                  attendance.started_at_before_change = attendance.started_at
                  attendance.finished_at_before_change = attendance.finished_at #未申請、否認、無しの場合に申請する場合の処理
                # end
                attendance.started_at_after_change = item[:started_at]
                attendance.finished_at_after_change = item[:finished_at]
                attendance.next_day = item[:next_day]
                attendance.note = item[:note]
                attendance.attendance_change_application_target_superior_id = item[:attendance_change_application_target_superior_id]
                attendance.attendance_change_application_status = item[:attendance_change_application_status]
                attendance.update_attributes!(item)
              # end
              # 申請中に変更する場合の処理
            elsif attendance.attendance_change_application_status == "申請中" || attendance.attendance_change_application_status == "承認"
              if item[:started_at] == "" || item[:finished_at] == "" || item[:started_at_after_change] == "" || item[:finished_at_after_change] == "" || item[:started_at_after_change] == nil || item[:finished_at_after_change] == nil
                attendance = false #変更後出社、変更後退社時間のいずれかがない場合は無効
              elsif ((attendance.started_at_after_change.hour != item[:started_at_after_change].to_time.hour) || (attendance.started_at_after_change.min != item[:started_at_after_change].to_time.min)) || ((attendance.finished_at_after_change.hour != item[:finished_at_after_change].to_time.hour) || (attendance.finished_at_after_change.min != item[:finished_at_after_change].to_time.min))
                if attendance.started_at_before_change == nil && attendance.finished_at_before_change == nil
                  attendance.started_at_before_change = attendance.started_at
                  attendance.finished_at_before_change = attendance.finished_at
                end
                attendance.started_at_after_change = item[:started_at_after_change]
                attendance.finished_at_after_change = item[:finished_at_after_change]
                attendance.next_day = item[:next_day]
                attendance.update_attributes!(item)
              elsif attendance.started_at_after_change == item[:started_at_after_change] && attendance.finished_at_after_change == item[:finished_at_after_change]
              end
              # 承認済みの場合に再申請する場合の処理
            # elsif attendance.attendance_change_application_status == "承認"
            #   if attendance.started_at_after_change != item[:started_at_after_change] || attendance.finished_at_after_change != item[:finished_at_after_change]
            #     attendance.started_at_after_change = item[:started_at_after_change]
            #     attendance.finished_at_after_change = item[:finished_at_after_change]
            #     attendance.attendance_change_application_status = item[:attendance_change_application_status]
            #     # attendance.update_attributes!(item)
            #   # elsif attendance.started_at_after_change == item[:started_at_after_change] && attendance.finished_at_after_change == item[:finished_at_after_change]
            #   end
            elsif item[:started_at] == "" || item[:finished_at] == "" || item[:started_at_after_change] == "" || item[:finished_at_after_change] == ""
              attendance = false #出社、退社、変更後出社、変更後退社時間のいずれかがない場合は無効
              # break
            end
        else item[:attendance_change_application_target_superior_id].blank?
          if item[:started_at] == "" || item[:finished_at] == "" || item[:started_at_after_change] == "" || item[:finished_at_after_change] == ""
            attendance = false
            # break
          end
        end
      end
    end
    flash[:success] = "1ヶ月分の勤怠変更を申請しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  def edit_one_day_overtime_application # 1日分の残業申請
    @user = User.find(params[:id])
    @selected_superior_users = User.where(superior: true).where.not(id: @user.id)
    # @day = Date.parse(params[:day])
    # @attendance = @user.attendances.find_by(params[:date])
    # @attendance = Attendance.find(params[:id])
    @attendance = Attendance.find_by(worked_on: params[:date], user_id: params[:id]) #日付データ取得
    # @day = @attendance
  end

  def update_one_day_overtime_application # 1日分の残業申請
    @user = User.find(params[:id])
    @attendance = Attendance.find_by(worked_on: params[:attendance][:date], user_id: params[:id])
    
    if params[:attendance][:scheduled_end_time].blank?
      flash[:danger] = "終了予定時間を入力してください。"
    elsif params[:attendance][:overtime_application_target_superior_id].blank?
      flash[:danger] = "申請先上長を選択してください。"
    else
      @attendance.update_attributes(one_day_overtime_application_params)
      flash[:success] = "#{User.find(params[:attendance][:overtime_application_target_superior_id]).name}に残業を申請しました。"
    end
    redirect_to user_url
  end

    # if @attendance.update_attributes(one_day_overtime_application_params)
    #   flash[:success] = "#{@user.name}の残業申請を更新しました。"
    # else
    #   flash[:danger] = "#{@user.name}の残業申請の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    # end
    # redirect_to user_url

  def edit_attendance_change_application_notification #勤怠変更のお知らせ
    # @user = User.find(params[:id])
    @attendances = Attendance.where(attendance_change_application_target_superior_id: params[:id], attendance_change_application_status: "申請中")
    # @users = User.where(id: @attendances.select(:user_id))
    @users = User.joins(:attendances).group("users.id").where(attendances:{attendance_change_application_status: "申請中"}).where.not(attendances:{user_id: params[:id]})
  end

  def update_attendance_change_application_notification #勤怠変更のお知らせ
    n1 = 0 #数値であることを定義　これにより以下でnが数値として認識される
    n2 = 0 #この階層（flashメッセージと同じ）でないとエラーになる
    n3 = 0
    ActiveRecord::Base.transaction do
      attendance_change_application_notification_params.each do |id, item|
        if item[:change_for_attendance_change] == "true" #itemの中にchangeとovertime_application_statusが入っている　文字列の形
          attendance = Attendance.find(id) #データベースの中の同じidのattendanceレコードを探してきている
            if item[:attendance_change_application_status] == "承認"
              n1 = n1 + 1
              attendance.started_at = attendance.started_at_after_change
              attendance.finished_at = attendance.finished_at_after_change
              attendance.update_attributes!(item)
              # if attendance.attendance_change_application_status == "承認" && attendance.attendance_change_application_target_superior_id.present? && attendance.change_for_attendance_change == true
              #   attendance = attendance.dup
              #   attendance.save
              # end
            elsif item[:attendance_change_application_status] == "否認"
              n2 = n2 + 1
              attendance.started_at = attendance.started_at_before_change
              attendance.finished_at = attendance.finished_at_before_change
              attendance.started_at_before_change = nil
              attendance.finished_at_before_change = nil
              attendance.started_at_after_change = nil
              attendance.finished_at_after_change = nil
              attendance.note = nil
              attendance.next_day = false
              item[:change_for_attendance_change] = "false"
              attendance.attendance_change_application_target_superior_id = nil
              attendance.update_attributes!(item)
            elsif item[:attendance_change_application_status] == "なし" #勤怠が"なし"の場合、申請自体なかったことにする
              n3 = n3 + 1 #"なし"をカウントする為、104行目を含むif文は以下の"なし"の処理より上に持ってくる
              attendance.started_at = attendance.started_at_before_change #以下で申請したattendanceレコードを空にする
              attendance.finished_at = attendance.finished_at_before_change
              attendance.started_at_before_change = nil
              attendance.finished_at_before_change = nil
              attendance.started_at_after_change = nil
              attendance.finished_at_after_change = nil
              attendance.next_day = false
              attendance.note = nil
              attendance.attendance_change_application_target_superior_id = nil
              item[:attendance_change_application_status] = "" #パラメーターとして飛んできているovertime_application_status、changeも元に戻す
              item[:change_for_attendance_change] = "false" #paramsなので文字列
              attendance.update_attributes!(item)
            end
        end
      end
    end
      # ActiveRecord::Base.transaction do # トランザクションを開始します。
      #   attendance_change_application_notification_params.each do |id,item|
      #     attendance = Attendance.find(id)
      #     if attendance.attendance_change_application_status == "承認" && attendance.attendance_change_application_target_superior_id.present? && attendance.change_for_attendance_change == "true"
      #       attendance = attendance.dup
      #       attendance.save
      #     end
      #   end
      # end
    flash[:success] = "勤怠変更申請を#{n1}件承認、#{n2}件否認、#{n3}件取り消しました。"
    redirect_to user_url
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to user_url(date: params[:date])
  end

  def edit_overtime_application_notification #残業申請のお知らせ
    @attendances = Attendance.where(overtime_application_target_superior_id: params[:id], overtime_application_status: "申請中")
    # @users = User.where(id: @attendances.select(:user_id))
    @users = User.joins(:attendances).group("users.id").where(attendances:{overtime_application_status: "申請中"}).where.not(attendances:{user_id: params[:id]})
  end
  
  def update_overtime_application_notification #残業申請のお知らせ
    n1 = 0 #数値であることを定義　これにより以下でnが数値として認識される
    n2 = 0 #この階層（flashメッセージと同じ）でないとエラーになる
    n3 = 0
    ActiveRecord::Base.transaction do
      overtime_application_notification_params.each do |id, item|
        if item[:change] == "true" #itemの中にchangeとovertime_application_statusが入っている　文字列の形
          attendance = Attendance.find(id) #データベースの中の同じidのattendanceレコードを探してきている
            if item[:overtime_application_status] == "承認"
              n1 = n1 + 1
            elsif item[:overtime_application_status] == "否認"
              n2 = n2 + 1
              attendance.scheduled_end_time = nil
              attendance.next_day = false
              attendance.business_process_content = nil
              attendance.overtime_application_target_superior_id = nil
            elsif item[:overtime_application_status] == "なし" #勤怠が"なし"の場合、申請自体なかったことにする
              n3 = n3 + 1 #"なし"をカウントする為、104行目を含むif文は以下の"なし"の処理より上に持ってくる
              attendance.scheduled_end_time = nil #以下で申請したattendanceレコードを空にする
              attendance.next_day = false
              attendance.business_process_content = nil
              attendance.overtime_application_target_superior_id = nil
              item[:overtime_application_status] = "" #パラメーターとして飛んできているovertime_application_status、changeも元に戻す
              item[:change] = "false" #paramsなので文字列
            end
          attendance.update_attributes!(item)
        end
      end
    end
    flash[:success] = "残業申請を#{n1}件承認、#{n2}件否認、#{n3}件取り消しました。"
    redirect_to user_url
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to user_url(date: params[:date])
  end

  def affiliation_manager_approval_application #所属長承認申請
  end

  def attendance_change_application_confirmation_show #勤怠変更申請の確認リンク
    @user = User.find(params[:id])
    @attendance = Attendance.find(params[:id])
    @first_day = params[:date].to_date.beginning_of_month
    @last_day = @first_day.end_of_month
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day)
    @worked_sum = @attendances.where.not(started_at: nil).count
  end

  def overtime_application_confirmation_show #残業の確認リンク
    @user = User.find(params[:id])
    @attendance = Attendance.find(params[:id])
    @first_day = params[:date].to_date.beginning_of_month
    @last_day = @first_day.end_of_month
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day)
    @worked_sum = @attendances.where.not(started_at: nil).count
  end
  
  def attendance_modifying_log #勤怠修正ログ
    
    if Attendance.where(user_id: @user.id).where.not(worked_on: nil).present?
      @start_year =  Attendance.where(user_id: @user.id).minimum(:worked_on).year
      @end_year = Attendance.where(user_id: @user.id).maximum(:worked_on).year
    end
    
    if params[:date][0].present?
      @first_day = params[:date].to_date.beginning_of_month
      @last_day = @first_day.end_of_month
      @attendance = @user.attendances.where(worked_on: @first_day..@last_day)
      @attendance_logs = @attendance.where(user_id: @user.id, attendance_change_application_status: "承認")
      @selected_year = params[:date].to_date
    else
      params[:date] = params[:date][:year] + "-" + params[:date][:month] + "-" + "01"
      @first_day = params[:date].to_date.beginning_of_month
      @last_day = @first_day.end_of_month
      @attendance = @user.attendances.where(worked_on: @first_day..@last_day)
      @attendance_logs = @attendance.where(user_id: @user.id, attendance_change_application_status: "承認")
      @selected_year = params[:date].to_date
    end
    # if params[:date][:year].present? && params[:date][:month].present?
    #   params[:date] = params[:date][:year] + "-" + params[:date][:month] + "-" + "01"
    #   @first_day = params[:date].to_date.beginning_of_month
    #   @last_day = @first_day.end_of_month
    #   @attendance = @user.attendances.where(worked_on: @first_day..@last_day)
    #   @attendance_logs = @attendance.where(user_id: @user.id, attendance_change_application_status: "承認")
    # else
    #   @first_day = params[:date].to_date.beginning_of_month
    #   @last_day = @first_day.end_of_month
    #   @attendance = @user.attendances.where(worked_on: @first_day..@last_day)
    #   @attendance_logs = @attendance.where(user_id: @user.id, attendance_change_application_status: "承認")
    # end
  end

  private
    #勤怠変更の申請
    def attendance_change_application_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :started_at_after_change, :finished_at_after_change, :note, :next_day, :attendance_change_application_target_superior_id, :attendance_change_application_status])[:attendances]
    end

    #勤怠変更申請のお知らせ
    def attendance_change_application_notification_params
      params.require(:user).permit(change_applicant_attendances: [:change_for_attendance_change, :attendance_change_application_status])[:change_applicant_attendances]
    end

    #1日分の残業申請
    def one_day_overtime_application_params #モーダルのフィールドがattendanceの中にデータを入れる構造になっているためrequire(:attendance)
      params.require(:attendance).permit(:scheduled_end_time, :next_day, :business_process_content, :overtime_application_target_superior_id, :overtime_application_status)
    end
    
     #残業申請のお知らせ
    def overtime_application_notification_params
      params.require(:user).permit(applicant_attendances: [:change, :overtime_application_status])[:applicant_attendances]
    end

  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
     flash[:danger] = "編集権限がありません。"
     redirect_to(root_url)
    end
  end
end
