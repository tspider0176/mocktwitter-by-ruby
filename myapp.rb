# encoding: utf-8

require 'sinatra'
require 'date'
require 'sinatra/reloader' if development?

# User クラス
class User
  # コンストラクタ
  def initialize(id, display_name)
    @id = id
    @display_name = display_name
    @tweets
  end

  # ToString
  def to_s
    "#{@display_name}(@#{@id})"
  end
end

# Tweet クラス
class Tweet
  # コンストラクタ
  def initialize(text, date, user)
    @text = text
    @date = date
    @user = user
  end

  # ToString
  def to_s
    "tweet:\n#{text}\nby #{user}"
  end

  def user
    @user
  end

  def text
    @text
  end
end

class TimeLine
  # 全ツイートを保持
  # Tweet型の配列
  @@tweets

  def initialize
   @@tweets = Array.new()
  end

  def to_s
    "timeline"
  end

  def register(tweet)
    @@tweets.insert(-1, tweet)
  end

  def dispTweets
    @@tweets.map{ |tweet|
      "#{tweet.user}: #{tweet.text}"
    }
  end
end

tl = TimeLine.new()
user = User.new("stringamp", "いと")

# Home 投稿されたツイートを表示
get '/home' do
	#erb :timeline
  tl.dispTweets.map{ |str|
    str + "<br>"
  }
  
end

# タイムラインに投稿
get '/home/post/:text' do |text|
  tl.register(Tweet.new(text, Time.now, user))
  redirect to('/home')
end
