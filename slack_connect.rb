require 'http'
require 'dotenv/load'

# SLACK_WEBHOOK_URL = ENV['SLACK_WEBHOOK_URL']
# チャンネル:test_ohya
# SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/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"

# チャンネル:techstudy_mentors
SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/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" 



# スラックに投稿するメソッド
def post_message_to_slack(text)
  payload = {
    text: text
  }.to_json

  HTTP.post(SLACK_WEBHOOK_URL, body: payload)
end
