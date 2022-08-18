class AsynchroSummate
  def self.summate_month(user, summation, finish_flag = false, file_name = "")
    begin
      summation.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_WAIT)
      summation.save!

      #仕掛品棚卸票出力
      report_t120 = self.print_t120(user, summation.target_ymd, file_name)
      summation.reports << report_t120
      summation.save!

      #材料棚卸票出力
      report_t121 = self.print_t121(user, summation.target_ymd, file_name)
      summation.reports << report_t121
      summation.save!

      if finish_flag
        target_productions = Production.find_summation_targets
        
        ActiveRecord::Base::transaction do
          target_productions.each{ |production|
            production.summation = summation
            production.save!
          }
        end
      end

      summation.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_DONE)
      summation.save!

    rescue => e
puts e.message + "\n"
puts e.backtrace.join("\n")
      summation.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_ERROR)
      summation.save!

      raise e
    end
  end

  def self.print_t120(user, target_ymd, file_name = "")
    conds  = " productions.summation_id IS NULL"
    conds += " and process_types.protected_flag IS NULL" #計画と倉入は除外
    conds += " and production_details.result_amount_production IS NOT NULL"

    production_details = ProductionDetail.includes([:production, {:process_detail => :process_type}]).where([conds]).references(:productions)
    production_details = production_details.select {|x| x.production != nil } # for debug 
    
    report = nil
    ActiveRecord::Base::transaction do
      report = AsynchroPrintMiddleProductionList.prepare_report_with_target_ymd(user, target_ymd, file_name)
      
      AsynchroPrintMiddleProductionList.report_with_target_ymd(report, user, target_ymd, file_name, *production_details)
    end
    
    return report
  end
  
  def self.print_t121(user, target_ymd, file_name = "")
    material_stocks = MaterialStock.includes([:material, :material_order]).where(["material_stocks.collect_flag = ?", FLAG_OFF])
    washer_stocks = WasherStock.includes([:washer, :washer_order]).where(["washer_stocks.collect_flag = ?", FLAG_OFF])
    
    report = nil
    ActiveRecord::Base::transaction do
      report = AsynchroPrintMaterialStockList.prepare_report_with_target_ymd(user, target_ymd, file_name)
      
      AsynchroPrintMaterialStockList.report_with_target_ymd(report, user, target_ymd, file_name, material_stocks.to_a, washer_stocks.to_a)
    end
    
    return report
  end

end
