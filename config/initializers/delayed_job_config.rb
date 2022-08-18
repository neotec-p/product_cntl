# 実行モードフラグ。trueの時とfalseの時で動作が変わるようにする。
env_flag = ( ENV['RAILS_ENV']=='production' or ENV['RAILS_ENV'] == 'staging' )
# 失敗したJobを削除するか
Delayed::Worker.destroy_failed_jobs = ( ENV['RAILS_ENV']=='production' ? true : false)
# Sleepタイム
Delayed::Worker.sleep_delay = (env_flag ? 30 : 5)
# 最大実行回数
Delayed::Worker.max_attempts = (env_flag ? 5 : 3)
# 最大実行時間
# 5分経過して処理が戻らなければ、プロセスをkillする
Delayed::Worker.max_run_time = 5.minutes

# ログローテーション
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'), 50)
