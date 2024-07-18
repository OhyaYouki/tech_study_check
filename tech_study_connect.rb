
# 総会の日付を配列で定義する
TARGET_DATES = [
  '2024/07/30',
  '2024/08/29',
  '2024/09/26',
  '2024/10/30',
  '2024/11/28'
]


# slackに投稿文章(質問有り)
QUESTION_TEXT = <<~TEXT
      <!here>
      返信準備ができる方は、準備を行ってください。
      ※総会日は対応無しです。
      対応する方はこの投稿にスタンプを押して、対応をお願いします。
      ■質問対応の優先順位
      転職・教養 > テックスタディ
      ■テックスタディカリキュラム
      https://content.tech-study.in/
      ■テックスタディ メンター用コンソール
      https://content.tech-study.in/connect/mentor/console
      ■返信時の注意点
      原則受講生のお名前を文章に含めない or 含める場合はどんな簡単な名前であっても手打ちせず、コピー＆ペーストの徹底をお願いします。（田中様、など）
      理由：変換ミス等で、お名前を間違えることの防止。
      また対応終了後は、通常受講生の対応に影響が出るリスクを下げるため
      ■テックスタディカリキュラム
      ■テックスタディ メンター用コンソール
      のブラウザは✗で閉じておくようお願いします。
    TEXT

# # slackに投稿文章(質問無し)
NO_QUESTION_TEXT = "定期チェック結果：質問はありません"


# 総会日の送信文
GENERAL_MEETING_NOTICE = '本日は総会日ですので、終日対応は無しです。'





# ツール全体で使うインスタンス変数の定義
def tech_study_initialize(url, email, password)
  @url = url
  @options = Selenium::WebDriver::Chrome::Options.new
  @options.add_argument('--headless')
  # @d = Selenium::WebDriver.for :chrome
  @d = Selenium::WebDriver.for :chrome, options: @options
  @credentials = { email: email, password: password }
end


# テックスタディへアクセス
def visit_url
  @d.get(@url)
  sleep 2 
end


# ブラウザを閉じる
def close_browser
  @d.quit
end


# ログイン
def login
  # 要素取得
  email_field = @d.find_element(:id, 'user_email')
  password_field = @d.find_element(:id, 'user_password')

  # 値入力
  email_field.send_keys(@credentials[:email])
  password_field.send_keys(@credentials[:password])

  # ログインボタンクリック
  login_button = @d.find_element(:name, 'commit')
  login_button.click

  sleep 2
end


# テックスタディにアクセスしてからトップページを表示するまで
def perform_login_flow
  visit_url
  login
  visit_url
end


# 質問数を取得し、質問数に応じた投稿文の取得
def count_based_message
  #待ち人数の要素を取得
  chat_alert_count = @d.find_element(:css, '.chat-alert-count').text
  count = chat_alert_count.scan(/\d+/).first.to_i

  message = count == 0 ? NO_QUESTION_TEXT : QUESTION_TEXT

  return message  
end


def today_is_meeting_day?
  # 現在の日時を取得
  now = Time.now
  # 現在の日付を 'YYYY/MM/DD' 形式の文字列に変換
  current_date = now.strftime('%Y/%m/%d')
      
  if TARGET_DATES.include?(current_date)
    if now.hour == 13
      # 総会日文章送信
      post_message_to_slack(GENERAL_MEETING_NOTICE)
    end
    # 14時以降は何もしない
    return true
  end
  
  return false
end

