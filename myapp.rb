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

class User < ActiveRecord::Base
end

present_user = nil

# 投稿された全ユーザーのツイートを表示
get '/' do
	begin
    @title = "Mock twitter"
    @user = present_user

    tweets = Tweet.order("id")
    @data = tweets.map{ |tweet|
      user = User.find(tweet.user_id)
      "#{tweet.id},#{user.name}(@#{user.id}),#{tweet.tsubuyaki},#{tweet.t_date}"
    }
    erb :index
  rescue
    if tweets.size == 0 then
      "No tweets."
    else
      "Tweets display error."
    end
  end
end

# ログイン
post '/login' do
  begin
    present_user = User.find(params[:userid])
    "Login successful: You logged in as (@#{params[:userid]})."
    redirect('/')
  rescue
    "Login failed: No user id @#{params[:userid]}."
  end
end

# ログアウト
post '/logout' do
  present_user = nil
  redirect('/')
end

# ツイート投稿
post '/post' do
  if present_user != nil then
    tweet = Tweet.new
    tweet.tsubuyaki = params[:tsubuyaki]
    tweet.user_id = present_user.id
    tweet.t_date = Time.now
    tweet.save

    redirect('/')
  else
    "Please log in."
  end
end

# ツイート削除
post '/delete/:id' do |id|
  begin
    tweet = Tweet.find(id)
    tweet.destroy
    redirect('/')
  rescue
    "No such tweet"
  end
end

# ユーザー作成
get '/user/create/:id/:disp_name' do |id, disp_name|
  #同一idを持つユーザーがいなければユーザー作成
  begin
    User.where("id = '#{id}'")
    user = User.new
    user.id = id
    user.name = disp_name
    user.save

    "User create successful: Please log in."
  rescue
    "User create failed: Same id already exists."
  end
end

# ユーザ指定ツイート表示
get '/user/tweets/:userid' do |userid|
  begin
    tweets = Tweet.where("user_id = '#{userid}'")
    tweets.map{ |tweet|
      user = User.find(userid)
      "#{tweet.id}: user.name (@#{user.id}) on #{tweet.t_date} <br>#{tweet.tsubuyaki}<br>"
    }
  rescue
    "No such user id."
  end
end

# ユーザー削除
get '/user/delete/:userid' do |userid|
  begin
    user = User.find(userid)
    user.destroy
    "Deletion successful: (@#{userid})."
  rescue
    "Deletion failed: No user id @#{userid}."
  end
end

# ユーザーリスト
get '/user' do
  content_type :html

  begin
    User.all.each do |user|
      body << "#{user.name} (@#{user.id})<br>"
    end
    body
  rescue
    "No user."
  end
end

# 現在の操作ユーザー
get '/p' do
  present_user.to_s
end
