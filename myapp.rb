# encoding: utf-8

require 'sinatra'
require 'date'
require 'sinatra/reloader' if development?
require 'active_record'
require 'mysql2'

# Import files for database
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection(:development)

class Tweet < ActiveRecord::Base
end

# User クラス
class User
  # ツイートを保存するハッシュ
  # 何番目のつぶやき(key) -> つぶやき内容(value)
  @tweethash

  # コンストラクタ
  def initialize(id, display_name)
    @id = id
    @display_name = display_name
    @tweethash = {}
  end

  # ToString
  def to_s
    "#{@display_name}(@#{@id})"
  end

  def id
    @id
  end

  def tweethash
    @tweethash
  end
end

# 登録されたユーザーを保持 User型の配列
users = Array.new()
present_user = nil

# ログイン
get '/login/:userid' do |userid|
  if users.select{|user| user.id == userid}.size == 0 then
    "Login failed: Please register user."
  elsif users.select{|user| user.id == userid}.size != 0 then
    present_user = users.select{ |user|
      user.id == userid
    }.first
    "Login successful: You logged in as (@#{userid})."
  else
    "Login failed: No user id @#{userid}."
  end
end

# 投稿された全ユーザーのツイートを表示
get '/' do
	#erb :timeline
  tweets = Tweet.order("id")
  tweets.map{ |tweet|
    user = users.select{|user| user.id == tweet.user_id}.first
    "#{tweet.id}: #{user.to_s}<br>#{tweet.tsubuyaki}<br>"
  }
end

# ツイート投稿
get '/post/:text' do |text|
  if present_user != nil then
  tweet = Tweet.new
  tweet.tsubuyaki = text
  tweet.user_id = present_user.id
  tweet.t_date = Time.now
  tweet.save

  hash = {present_user.tweethash.size + 1 => text}
  present_user.tweethash.merge!(hash)

  redirect to('/')
  else
    "Please log in."
  end
end

# ツイート削除
get '/delete/:id' do |id|
  begin
    tweet = Tweet.find(id)
    tweet.destroy
    "Deletion success."
  rescue
    "No such tweet"
  end
end

# ユーザ指定ツイート表示
get '/user/tweets/:userid' do |userid|
  begin
    tweets = Tweet.where("user_id = '#{userid}'")
    tweets.map{ |tweet|
      user = users.select{|user| user.id == tweet.user_id}.first
      "#{tweet.id}: #{user.to_s}<br>#{tweet.tsubuyaki}<br>"
    }
  rescue
    "No such user id."
  end
end

# ユーザー作成
get '/user/create/:id/:disp_name' do |id, disp_name|
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
get '/user/delete/:userid' do |userid|
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

# ユーザーリスト
get '/user' do
  users.map{ |user|
    user.to_s + "<br>"
  }
end

# 現在の操作ユーザー
get '/p' do
  present_user.to_s
end
