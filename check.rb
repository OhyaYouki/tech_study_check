require 'selenium-webdriver'
require 'dotenv/load'
require 'time'
require 'rufus-scheduler'


# ファイルの読み込み
require './tech_study_connect'
require './slack_connect'



# 変数定義
url = ENV['TECH_STUDY_URL']
email = ENV['TECH_STUDY_OHYA_EMAIL']
password = ENV['TECH_STUDY_OHYA_PASSWORD']



# Rufusスケジューラのインスタンスを作成
scheduler = Rufus::Scheduler.new

# スケジュールと対応するメッセージを定義
tasks = [
  { time: '0 13 * * *', message: '13:00 の確認' },
  { time: '0 14 * * *', message: '14:00 の確認' },
  { time: '0 15 * * *', message: '15:00 の確認' },
  { time: '0 16 * * *', message: '16:00 の確認' },
  { time: '0 17 * * *', message: '17:00 の確認' },
  { time: '0 18 * * *', message: '18:00 の確認' },
  { time: '0 19 * * *', message: '19:00 の確認' },
  { time: '0 20 * * *', message: '20:00 の確認' },
  { time: '0 21 * * *', message: '21:00 の確認' },
  { time: '30 21 * * *', message: '21:30 の確認' }
]



# 特定の時間にタスクをスケジュール
tasks.each do |task|
  scheduler.cron task[:time] do
    puts task[:message]

    begin
      # 使用するインスタンス変数の定義
      tech_study_initialize(url, email, password)

      # 今日が総会かどうかを判断
      next if today_is_meeting_day?

      # テックスタディへのログイン
      perform_login_flow

      # 質問数を取得し、質問数に応じた投稿文の取得
      message = count_based_message

      # slackへ投稿
      post_message_to_slack(message)

    rescue => e
      puts e.full_messages

      # エラーが発生した時のメッセージ
      message = "【開発者用】未知のエラーが発生しました: #{e.message}"
      
      # slackへ投稿
      post_message_to_slack(message)
    ensure
      close_browser
    end
  end
end

# スケジュールがタスクを実行できるようにスクリプトを実行し続ける
scheduler.join