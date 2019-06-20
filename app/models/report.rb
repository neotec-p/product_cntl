class Report < ActiveRecord::Base
  belongs_to :asynchro_status
  belongs_to :report_type
  belongs_to :user
  
  has_and_belongs_to_many :productions
  has_and_belongs_to_many :process_orders
  has_and_belongs_to_many :material_orders
  has_and_belongs_to_many :material_stocks
  has_and_belongs_to_many :washer_orders
  has_and_belongs_to_many :summations


  def self.available_reports(cond_report_type_id, cond_user_first_name, cond_user_last_name, cond_date_from, cond_date_to)
    conds = "1 = 1"
    conds_param = []

    if cond_report_type_id.present?
      conds += "reports.report_type_id = ?"
      conds_param << cond_report_type_id
    end
    if cond_user_first_name.present?
      conds += " AND users.first_name LIKE ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_user_first_name.strip)]
    end
    if cond_user_last_name.present?
      conds += " AND users.last_name LIKE ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_user_last_name.strip)]
    end
    if cond_date_from.present?
      conds += " AND ? <= reports.created_at"
      conds_param << cond_date_from
    end
    if cond_date_to.present?
      conds += " AND reports.created_at < ?"
      conds_param << (cond_date_to + 1.days)
    end

    self.includes(:user).where([conds] + conds_param).references(:user)
  end
end
