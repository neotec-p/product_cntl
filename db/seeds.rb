# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

ProcessType.delete_all
process_type = ProcessType.new(:name=> '計画', :seq => 1, :processor_flag => 0, :protected_flag => 1)  #1
process_type.id = 1
process_type.expense_sum_category = 0
process_type.search_flag = 1
process_type.save!
process_type = ProcessType.new(:name=> 'ヘッダー', :seq => 2, :processor_flag => 0, :plan_process_flag => 1, :ratio_flag => 1, :process_category => 1)  #2
process_type.id = 2
process_type.expense_sum_category = 1
process_type.search_flag = 1
process_type.save!
process_type = ProcessType.new(:name=> '脱油（ＨＤ）', :seq => 3, :processor_flag => 0, :barrel_flag => 1, :ratio_flag => 2, :process_category => 1)  #3
process_type.id = 3
process_type.expense_sum_category = 2
process_type.save!
process_type = ProcessType.new(:name=> '中間検査（ＨＤ）', :seq => 4, :processor_flag => 0, :process_category => 1)  #4
process_type.id = 4
process_type.expense_sum_category = 2
process_type.save!
process_type = ProcessType.new(:name=> '追加１', :seq => 5, :processor_flag => 3, :plan_process_flag => 2, :process_category => 1)  #5
process_type.id = 5
process_type.expense_sum_category = 3
process_type.search_flag = 1
process_type.save!
process_type = ProcessType.new(:name=> 'ローリング１', :seq => 6, :processor_flag => 0, :plan_process_flag => 3, :ratio_flag => 3, :process_category => 2)  #6
process_type.id = 6
process_type.expense_sum_category = 4
process_type.search_flag = 1
process_type.save!
process_type = ProcessType.new(:name=> '脱油（Ｒ１）', :seq => 7, :processor_flag => 0, :barrel_flag => 1, :process_category => 2)  #7
process_type.id = 7
process_type.expense_sum_category = 4
process_type.save!
process_type = ProcessType.new(:name=> '中間検査（Ｒ１）', :seq => 8, :processor_flag => 0, :process_category => 2)  #8
process_type.id = 8
process_type.expense_sum_category = 4
process_type.save!
process_type = ProcessType.new(:name=> '追加２', :seq => 9, :processor_flag => 3, :plan_process_flag => 4, :process_category => 2)  #9
process_type.id = 9
process_type.expense_sum_category = 5
process_type.search_flag = 1
process_type.save!
process_type = ProcessType.new(:name=> 'ローリング２', :seq => 10, :processor_flag => 0, :plan_process_flag => 5, :ratio_flag => 4, :process_category => 2)  #10
process_type.id = 10
process_type.expense_sum_category = 6
process_type.search_flag = 1
process_type.save!
process_type = ProcessType.new(:name=> '脱油（Ｒ２）', :seq => 11, :processor_flag => 0, :barrel_flag => 1, :process_category => 2)  #11
process_type.id = 11
process_type.expense_sum_category = 6
process_type.save!
process_type = ProcessType.new(:name=> '中間検査（Ｒ２）', :seq => 12, :processor_flag => 0, :process_category => 2)  #12
process_type.id = 12
process_type.expense_sum_category = 6
process_type.save!
process_type = ProcessType.new(:name=> '追加３', :seq => 13, :processor_flag => 3, :plan_process_flag => 6, :process_category => 2)  #13
process_type.id = 13
process_type.expense_sum_category = 7
process_type.search_flag = 1
process_type.save!
process_type = ProcessType.new(:name=> '熱処理', :seq => 14, :processor_flag => 1, :ratio_flag => 5, :process_category => 3)  #14
process_type.id = 14
process_type.expense_sum_category = 8
process_type.search_flag = 1
process_type.save!
process_type = ProcessType.new(:name=> '追加４', :seq => 15, :processor_flag => 3, :process_category => 3)  #15
process_type.id = 15
process_type.expense_sum_category = 9
process_type.search_flag = 1
process_type.save!
process_type = ProcessType.new(:name=> '表面処理', :seq => 16, :processor_flag => 2, :ratio_flag => 6, :process_category => 3)  #16
process_type.id = 16
process_type.expense_sum_category = 10
process_type.search_flag = 1
process_type.save!
process_type = ProcessType.new(:name=> '追加５', :seq => 17, :processor_flag => 3, :process_category => 3)  #17
process_type.id = 17
process_type.expense_sum_category = 11
process_type.search_flag = 1
process_type.save!
process_type = ProcessType.new(:name=> '検査１', :seq => 18, :processor_flag => 0, :process_category => 4)  #18
process_type.id = 18
process_type.expense_sum_category = 11
process_type.search_flag = 1
process_type.save!
process_type = ProcessType.new(:name=> '検査２', :seq => 19, :processor_flag => 0, :process_category => 4)  #19
process_type.id = 19
process_type.expense_sum_category = 11
process_type.search_flag = 1
process_type.save!
process_type = ProcessType.new(:name=> '梱包', :seq => 20, :processor_flag => 0, :process_category => 4)  #20
process_type.id = 20
process_type.expense_sum_category = 11
process_type.save!
process_type = ProcessType.new(:name=> '倉入', :seq => 21, :processor_flag => 0, :protected_flag => 2)  #21
process_type.id = 21
process_type.expense_sum_category = 0
process_type.search_flag = 1
process_type.save!

Role.delete_all
role = Role.new(:name=> '製造部')
role.id = 1
role.save!
role = Role.new(:name=> '購買部')
role.id = 2
role.save!
role = Role.new(:name=> '営業部')
role.id = 3
role.save!
role = Role.new(:name=> '経理部')
role.id = 4
role.save!
role = Role.new(:name=> 'システム管理者')
role.id = 99
role.save!

ReportType.delete_all
report_type = ReportType.new(:code => 'T010', :name=> '工程管理票', :dt_format => "%Y%m%d")  #1
report_type.id = 1
report_type.seq = 1
report_type.save!
report_type = ReportType.new(:code => 'T020', :name=> '品質チェックシート', :dt_format => "%Y%m%d")  #2
report_type.id = 2
report_type.seq = 2
report_type.save!
report_type = ReportType.new(:code => 'T030', :name=> '現品票', :dt_format => "%Y%m%d")  #3
report_type.id = 3
report_type.seq = 3
report_type.save!
report_type = ReportType.new(:code => 'T040', :name=> '生産計画日程表（ＨＤ）', :dt_format => "%Y%m%d")  #4
report_type.id = 4
report_type.seq = 4
report_type.save!
report_type = ReportType.new(:code => 'T041', :name=> '生産計画日程表（ＲＯ）', :dt_format => "%Y%m%d")  #23
report_type.id = 23
report_type.seq = 5
report_type.save!
report_type = ReportType.new(:code => 'T050', :name=> 'FAX注文書', :dt_format => "%Y%m%d")  #5
report_type.id = 5
report_type.seq = 6
report_type.save!
report_type = ReportType.new(:code => 'T060', :name=> '二次加工注文書', :dt_format => "%Y%m%d")  #6
report_type.id = 6
report_type.seq = 7
report_type.save!
report_type = ReportType.new(:code => 'T070', :name=> '現品票（追加工）', :dt_format => "%Y%m%d")  #7
report_type.id = 7
report_type.seq = 8
report_type.save!
report_type = ReportType.new(:code => 'T080', :name=> '不良一覧', :dt_format => "%Y%m%d")  #8
report_type.id = 8
report_type.seq = 9
report_type.save!
report_type = ReportType.new(:code => 'T120', :name=> '仕掛品棚卸票', :dt_format => "%Y%m%d")  #12
report_type.id = 12
report_type.seq = 10
report_type.save!
report_type = ReportType.new(:code => 'T121', :name=> '材料棚卸票', :dt_format => "%Y%m%d")  #22
report_type.id = 22
report_type.seq = 11
report_type.save!
report_type = ReportType.new(:code => 'T140', :name=> '材料購入履歴', :dt_format => "%Y%m%d")  #14
report_type.id = 14
report_type.seq = 12
report_type.save!
report_type = ReportType.new(:code => 'T141', :name=> '座金購入履歴', :dt_format => "%Y%m%d")  #21
report_type.id = 21
report_type.seq = 13
report_type.save!
report_type = ReportType.new(:code => 'T150', :name=> '材料管理票', :dt_format => "%Y%m%d")  #15
report_type.id = 15
report_type.seq = 14
report_type.save!

Status.delete_all
status = Status.new(:name=> '通常')
status.id = 1
status.save!
status = Status.new(:name=> '不良')
status.id = 2
status.save!
status = Status.new(:name=> '保留')
status.id = 3
status.save!

DefectiveProcessType.delete_all
defective_process_type = DefectiveProcessType.new(:name=> 'H', :seq=>1)
defective_process_type.id = 1
defective_process_type.save!
defective_process_type = DefectiveProcessType.new(:name=> 'H+', :seq=>2)
defective_process_type.id = 2
defective_process_type.save!
defective_process_type = DefectiveProcessType.new(:name=> 'RO1', :seq=>3)
defective_process_type.id = 3
defective_process_type.save!
defective_process_type = DefectiveProcessType.new(:name=> 'RO1+', :seq=>4)
defective_process_type.id = 4
defective_process_type.save!
defective_process_type = DefectiveProcessType.new(:name=> 'RO2', :seq=>5)
defective_process_type.id = 5
defective_process_type.save!
defective_process_type = DefectiveProcessType.new(:name=> 'RO2+', :seq=>6)
defective_process_type.id = 6
defective_process_type.save!

SummationType.delete_all
summation_type = SummationType.new(:name=> "月末集計")
summation_type.id = 1
summation_type.save!
summation_type = SummationType.new(:name=> "週末集計")
summation_type.id = 2
summation_type.save!
summation_type = SummationType.new(:name=> "月次集計（帳票のみ）")
summation_type.id = 3
summation_type.save!

AsynchroStatus.delete_all
asynchro_status = AsynchroStatus.new(:name=> "処理受付")
asynchro_status.id = 1
asynchro_status.save!
asynchro_status = AsynchroStatus.new(:name=> "処理中")
asynchro_status.id = 2
asynchro_status.save!
asynchro_status = AsynchroStatus.new(:name=> "正常終了")
asynchro_status.id = 3
asynchro_status.save!
asynchro_status = AsynchroStatus.new(:name=> "エラー")
asynchro_status.id = 9
asynchro_status.save!

Company.delete_all
company = Company.new
company.id = 1
company.name = "ネオテック株式会社"
company.short_name = "ネオテック㈱"
company.zip_code = "399-6461"
company.address = "長野県塩尻市宗賀字牧野３７１２"
company.tel = "0263-52-6002"
company.fax = "0263-52-6039"
company.product_dept = "製造Ｇ"
company.save!

ProcessRatio.delete_all
process_ratio = ProcessRatio.new
process_ratio.id = 1
process_ratio.hd = 8 
process_ratio.barrel  = 1
process_ratio.ro1 = 5  
process_ratio.ro2 = 5  
process_ratio.heat = 2 
process_ratio.surface = 2
process_ratio.conf_inspection = 0.1
process_ratio.save!
