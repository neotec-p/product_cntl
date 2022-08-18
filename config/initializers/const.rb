
DISP_NONE = "---"

FLAG_ON = 1
FLAG_OFF = 0
FLAG_NON = -1

#ロール
ROLE_PRODUCTION = 1   #製造部
ROLE_PURCHASE   = 2   #購買部
ROLE_SALES      = 3   #営業部
ROLE_ACCOUTING  = 4   #経理部
ROLE_ADMIN      = 99  #システム管理者

#マスタのデフォルト有効開始日
DEFAULT_START_YMD = "1000-01-01"
DEFAULT_END_YMD = "9999-12-31"

#マスタのデフォルト有効終了日

# 非同期処理状態
ASYNCHRO_STATUS_YET = 1     #処理受付
ASYNCHRO_STATUS_WAIT = 2    #処理中
ASYNCHRO_STATUS_DONE = 3    #終了
ASYNCHRO_STATUS_ERROR = 9   #エラー発生

# 締め処理区分
SUMMATION_TYPE_MONTH = 1          #月末集計
SUMMATION_TYPE_WEEK = 2           #週末集計
SUMMATION_TYPE_MONTH_REPORT = 3   #月末集計（帳票のみ）

# ページネーション
PAGINATE_PER_PAGE       = 20          # 1ページ件数
PAGINATE_PER_PAGE_EDIT  = 10          # 編集画面での1ページ件数
PAGINATE_PER_PAGE_STOCK = 5           # 在庫画面での1ページ件数
PAGINATE_PER_PAGE_POP   = 5           # ポップアップ画面での1ページ件数

PAGINATE_PER_PAGE_PRODUCT  = 50          # 生産状況（工程別）での1ページ件数

IMAGES_DIR          = 'images'
REPORT_OUTPUT_DIR   = 'reports'
REPORT_TEMPLATE_DIR = 'app/reports'

# 状態管理ID
STATUS_ID_NORMAL    = 1 #正常
STATUS_ID_BAD       = 2 #不良
STATUS_ID_SUSPENDED = 3 #保留

# 管理NO枝番のデフォルト値
DEFAULT_PRODUCTION_BRANCH1_NO = 1
DEFAULT_PRODUCTION_BRANCH2_NO = 0

# 生産の工程区分のデフォルト値
DEFAULT_PRODUCTION_PROCESS_TYPE_ID = 1
# 生産の状態管理IDのデフォルト値
DEFAULT_PRODUCTION_STATUS_ID = STATUS_ID_NORMAL

# 工程詳細の最大登録数
PROCESS_DETAIL_MAX_COUNT = 15

# 工程分類
PROCESS_CATEGORY_HD = 1             #HD工程
PROCESS_CATEGORY_RO = 2             #RO工程

# 必須工程フラグ
PROTECTED_FLAG_START = 1            #計画工程
PROTECTED_FLAG_FINISH = 2           #倉入工程

# 工程分類
PROCESS_CATEGORY_HEADER = 1         #半製品（転造前）
PROCESS_CATEGORY_ROLLING = 2        #半製品（転造後）
PROCESS_CATEGORY_PROCESS_ORDER = 3  #外注処理中
PROCESS_CATEGORY_FINISH = 4         #梱包待ち

# 工程費フラグ
RATIO_FLAG_HD = 1                   #HD
RATIO_FLAG_BARREL = 2               #バレル
RATIO_FLAG_RO1 = 3                  #RO1
RATIO_FLAG_RO2 = 4                  #RO2
RATIO_FLAG_HEAT = 5                 #熱処理
RATIO_FLAG_SURFACE = 6              #表面処理

# 工程費集計分類
EXPENSE_SUM_CATEGORY_HD = 1                 #HD
EXPENSE_SUM_CATEGORY_BARREL = 2             #バレル
EXPENSE_SUM_CATEGORY_HD_ADDITION = 3        #追加工１
EXPENSE_SUM_CATEGORY_RO1 = 4                #RO1
EXPENSE_SUM_CATEGORY_RO1_ADDITION = 5       #追加工２
EXPENSE_SUM_CATEGORY_RO2 = 6                #RO2
EXPENSE_SUM_CATEGORY_RO2_ADDITION = 7       #追加工３
EXPENSE_SUM_CATEGORY_HEAT = 8               #熱処理
EXPENSE_SUM_CATEGORY_HEAT_ADDITION = 9      #追加工４
EXPENSE_SUM_CATEGORY_SURFACE = 10           #表面処理
EXPENSE_SUM_CATEGORY_SURFACE_ADDITION = 11  #追加工５

# 計画工程フラグ
PLAN_PROCESS_FLAG_HD = 1            #HD
PLAN_PROCESS_FLAG_HD_ADDITION = 2   #追加工１
PLAN_PROCESS_FLAG_RO1 = 3           #RO1
PLAN_PROCESS_FLAG_RO1_ADDITION = 4  #追加工２
PLAN_PROCESS_FLAG_RO2 = 5           #RO2
PLAN_PROCESS_FLAG_RO2_ADDITION = 6  #追加工３

# 外注加工フラグ
PROCESSOR_FLAG_NULL = 0             #なし
PROCESSOR_FLAG_HEAT = 1             #熱処理
PROCESSOR_FLAG_SURFACE = 2          #表面処理
PROCESSOR_FLAG_ADDITION = 3         #追加工

# 田中熱工フラグ
TANAKA_FLAG_0SHARP = 1              #"0#"           
TANAKA_FLAG_TP = 2                  #"T/P"

# 帳票種類
REPORT_TYPE_T010 = 'T010'           #現品管理票
REPORT_TYPE_T020 = 'T020'           #品質チェックシート
REPORT_TYPE_T040 = 'T040'           #日程計画表（ＨＤ）
REPORT_TYPE_T041 = 'T041'           #日程計画表（ＲＯ）
REPORT_TYPE_T050 = 'T050'           #FAX注文書
REPORT_TYPE_T060 = 'T060'           #二次加工注文書
REPORT_TYPE_T070 = 'T070'           #現品票（追加工）
REPORT_TYPE_T080 = 'T080'           #不良一覧
REPORT_TYPE_T120 = 'T120'           #仕掛品棚卸票
REPORT_TYPE_T120_DETAIL = 'T120_D'  #仕掛品棚卸票_詳細
REPORT_TYPE_T121 = 'T121'           #材料棚卸票
REPORT_TYPE_T121_DETAIL_M = 'T121_D_M'  #材料棚卸票_詳細_材料
REPORT_TYPE_T121_DETAIL_W = 'T121_D_W'  #材料棚卸票_詳細_座金
REPORT_TYPE_T140 = 'T140'           #材料購入履歴
REPORT_TYPE_T141 = 'T141'           #座金購入履歴
REPORT_TYPE_T150 = 'T150'           #材料管理票

# 不良発生工程
DEFECTIVE_PROCESS_TYPE_HD = 1       #HD
DEFECTIVE_PROCESS_TYPE_HD_PLUS = 2  #HD+
DEFECTIVE_PROCESS_TYPE_RO1 = 3      #RO1
DEFECTIVE_PROCESS_TYPE_RO1_PLUS = 4 #RO1+
DEFECTIVE_PROCESS_TYPE_RO2 = 5      #RO2
DEFECTIVE_PROCESS_TYPE_RO2_PLUS = 6 #RO2+

# 機種毎生産計画子画面の表示週数
POP_MODEL_PRODUCTION_PLAN_WEEKS = 5

# カレンダーマスタ テンプレートCSV
CALENDARS_CSV_TEMPLATE_PATH = "/manual/カレンダーマスタ.csv"
# 操作マニュアル
MANUAL_PATH = "/manual/生産管理システム操作マニュアル.pdf"

# 画面タイプ
DISPLAY_TYPE_SIMPLE = 'simple'    # メインのみ

# 管理NOの初期NO
VOTE_NO_INIT = 100000 #50000
# LotNoの初期NO
LOT_NO_INIT = 6000
