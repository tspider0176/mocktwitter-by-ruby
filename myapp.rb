# encoding: utf-8

require 'sinatra'
require 'date'
require 'sinatra/reloader' if development?
require 'active_record'
require 'mysql2'
require 'uri'

# Import files for database
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection(:development)

class Tweet < ActiveRecord::Base
end

class User < ActiveRecord::Base
end

present_user = nil

# トップページ
get '/' do
	begin
    @title = "Mock twitter"
    @user = present_user

    tweets = Tweet.order("id")
      @data = tweets.map{ |tweet|
      user = User.find(tweet.user_id)

      # URLを含む文字列だった場合はURLに<a href="...">～</a>を加える
      if tweet.tsubuyaki.include?("http") then
        urls = URI.extract(tweet.tsubuyaki)
        text = tweet.tsubuyaki

        # リンク済みの地点
        linkedpos = 0
        urls.each do |url|
          if linkedpos < text.length then
            #現在リンク済み以降のurlを検索 -> 重複したurlが入れ子でリンクされるのを回避
            urlpos= text.index(url, linkedpos)

            # YoutubeのURLとそれ以外のURLでリンクの種類を変える
            uri = URI.parse(url).host
            if uri == "www.youtube.com" then
              # フレームに加えURLも変更する必要がある
              # ex. https://www.youtube.com/embed/F_p4WG_t3Ug
              parsed = URI.split(url)
              embedurl = parsed[0] + "://" + parsed[2] + "/embed/" + parsed[7][2..12]
              # text内のurlを埋め込み用URLへ置換
              text.sub!(url, embedurl)

              # リンク挿入
              text.insert(text.index(embedurl, urlpos), "<iframe width=\"560\" height=\"315\" src=\"")
              text.insert(text.index(embedurl, urlpos) + embedurl.length, "\" frameborder=\"0\" allowfullscreen></iframe>")
            else
              # リンク挿入
              text.insert(text.index(url, urlpos), "<a href=\"")
              text.insert(text.index(url, urlpos) + url.length, "\">#{url}</a>")
            end

            # リンク済み地点を進める(<a>内のURLと表示されるURL分)
            # このループでリンク処理されたurl以降の判定に使うので結構曖昧
            linkedpos = urlpos + url.length + url.length
          end
        end

        "#{tweet.id},#{user.name}(@#{user.id}),#{text},#{tweet.t_date}"
      else
        "#{tweet.id},#{user.name}(@#{user.id}),#{tweet.tsubuyaki},#{tweet.t_date}"
      end
    }
    erb :index
  rescue
    if tweets.size == 0 then
      @data = []
      erb :index
    else
      @text = "Tweets display error."
      erb :error
    end
  end
end

# 登録ページ
get '/register' do
  @title = "ユーザー登録"
  erb :register
end

# ログイン
post '/login' do
  begin
    present_user = User.find(params[:userid])
    "Login successful: You logged in as (@#{params[:userid]})."
    redirect('/')
  rescue
    @text = "Login failed: No user id @#{params[:userid]}."
    erb :error
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
    @text = "Tweet deletion failed: No such tweet"
    erb :error
  end
end

# ユーザーリスト
get '/userlist' do
  begin
    @userarr = User.all
    @p_user = present_user

    erb :users
  rescue
    @text = "User display failed: No user."
    erb :error
  end
end

# ユーザー作成
post '/user/create' do
  #同一idを持つユーザーがいなければユーザー作成
  begin
    User.where("id = '#{param[:userid]}'")
    @text = "User creation failed: Same id already exists."
    erb:error
  rescue
    begin
    # ユーザー作成
    user = User.new
    user.id = params[:userid]
    user.name = params[:username]
    user.save

    redirect('/')
    rescue
      @text = "User creation failed during creating user."
      erb :error
    end
  end
end

# ユーザー削除
post '/user/delete/:userid' do |userid|
  begin
    user = User.find(userid)

    # ユーザーが今までに呟いたツイートを全て削除
    tweets = Tweet.where("user_id = '#{userid}'")
    tweets.each do |tweet|
      tweet.destroy
    end

    # ユーザー削除
    user.destroy
    present_user = nil

    redirect('/')
  rescue
    @text = "User deletion failed: No user id @#{userid}."
    erb :error
  end
end

# ユーザ指定ツイート表示
get '/user/:userid' do |userid|
  begin
    @title = "ユーザーぺージ"
    @user = present_user

    tweets = Tweet.where("user_id = '#{userid}'")
    @data = tweets.map{ |tweet|
      user = User.find(userid)

      # URLを含む文字列だった場合はURLに<a href="...">～</a>を加える
      if tweet.tsubuyaki.include?("http") then
        urls = URI.extract(tweet.tsubuyaki)
        text = tweet.tsubuyaki

        # リンク済みの地点
        linkedpos = 0
        urls.each do |url|
          if linkedpos < text.length then
            #現在リンク済み以降のurlを検索 -> 重複したurlが入れ子でリンクされるのを回避
            urlpos= text.index(url, linkedpos)

            # YoutubeのURLとそれ以外のURLでリンクの種類を変える
            uri = URI.parse(url).host
            if uri == "www.youtube.com" then
              # フレームに加えURLも変更する必要がある
              # ex. https://www.youtube.com/embed/F_p4WG_t3Ug
              parsed = URI.split(url)
              embedurl = parsed[0] + "://" + parsed[2] + "/embed/" + parsed[7][2..12]
              # text内のurlを埋め込み用URLへ置換
              text.sub!(url, embedurl)

              # リンク挿入
              text.insert(text.index(embedurl, urlpos), "<iframe width=\"560\" height=\"315\" src=\"")
              text.insert(text.index(embedurl, urlpos) + embedurl.length, "\" frameborder=\"0\" allowfullscreen></iframe>")
            else
              # リンク挿入
              text.insert(text.index(url, urlpos), "<a href=\"")
              text.insert(text.index(url, urlpos) + url.length, "\">#{url}</a>")
            end

            # リンク済み地点を進める(<a>内のURLと表示されるURL分)
            # このループでリンク処理されたurl以降の判定に使うので結構曖昧
            linkedpos = urlpos + url.length + url.length
          end
        end

        "#{tweet.id},#{user.name}(@#{user.id}),#{text},#{tweet.t_date}"
      else
        "#{tweet.id},#{user.name}(@#{user.id}),#{tweet.tsubuyaki},#{tweet.t_date}"
      end
    }
    erb :userpage
  rescue
    @text = "No such user id."
    erb :error
  end
end
