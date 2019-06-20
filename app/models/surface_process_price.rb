class SurfaceProcessPrice < ProcessPrice
  def self.available(cond_customer_code, cond_code, cond_trader_id, cond_process)
    conds = "1 = 1"
    conds_param = []

    if cond_customer_code.present?
      conds += " AND customer_code = ?"
      conds_param << cond_customer_code
    end
    if cond_code.present?
      conds += " AND code = ?"
      conds_param << cond_code
    end
    if cond_trader_id.present?
      conds += " AND trader_id = ?"
      conds_param << cond_trader_id
    end
    if cond_process.present?
      conds += " AND process LIKE ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_process.strip)]
    end

    where([conds] + conds_param)
  end
end
