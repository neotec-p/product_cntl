class MaterialSupplier < Supplier
  def self.available(cond_id, cond_name, cond_address)
    conds = "1 = 1"
    conds_param = []

    if cond_id.present?
      conds += " AND id = ?"
      conds_param << cond_id
    end
    if cond_name.present?
      conds += " AND name LIKE ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_name.strip)]
    end
    if cond_address.present?
      conds += " and address like ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_address.strip)]
    end

    where([conds] + conds_param)
  end
end
