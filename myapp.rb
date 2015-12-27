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
  end

  # ToString
  def to_s
    "#{@display_name}(@#{@id})"
  end

  def id
    @id
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

  def date
    @date
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

  def add(tweet)
    @@tweets.insert(-1, tweet)
  end

  def dispTweets
    @@tweets.map{ |tweet|
      "#{tweet.user}: #{tweet.text} on #{tweet.date}"
    }
  end
end

tl = TimeLine.new()
# 登録されたユーザーを保持 User型の配列
users = Array.new()
default_user = User.new("stringamp", "いと")
users.insert(-1, default_user)
present_user = default_user

# Home 投稿されたツイートを表示
get '/home' do
	#erb :timeline
  tl.dispTweets.map{ |str|
    str + "<br>"
  }
end

# タイムラインに投稿
get '/home/post/:text' do |text|
  tl.add(Tweet.new(text, Time.now, present_user))
  redirect to('/home')
end

# ユーザー作成
get '/createuser/:id/:disp_name' do |id, disp_name|
  #同一idを持つユーザーがいなければユーザー作成
  if users.select{ |user| user.id == id}.size == 0 then
    newuser = User.new(id, disp_name)
    users.insert(-1, newuser)
    "User create successful"
  else
    "User create failed: Same id already exists"
  end
end

# ユーザー削除
get '/deluser/:userid' do |userid|
  if present_user.id == userid
    "Deletion failed: Please logout (@#{userid})."
  elsif users.select{|user| user.id == userid}.size != 0 then
    users.reject!{ |user|
      user.id == userid
    }
    "Deletion successful: (@#{userid})."
  else
    "Deletion failed: No user id @#{userid}."
  end
end

# ユーザー切り替え
get '/changeuser/:userid' do |userid|
  if present_user.id == userid
    "Login failed: You already logged in as (@#{userid})."
  elsif users.select{|user| user.id == userid}.size != 0 then
    present_user = users.select{ |user|
      user.id == userid
    }.first
    "Login successful: You logged in as (@#{userid})."
  else
    "Login failed: No user id @#{userid}."
  end
end

# ユーザーリスト
get '/userlist' do
  users.map{ |user|
    user.to_s + "<br>"
  }
end

get '/p' do
  present_user.to_s
end
