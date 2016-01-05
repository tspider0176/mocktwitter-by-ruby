Mock twitter app
====
## Description
Twitter-like web application by Ruby and Sinatra framework for homework on university.

## Environment
* ruby 2.2.3p173
* Bundler version 1.11.2
* MySQL Server version: 5.6.26 Homebrew

## Function
* For newcomer
    - Register this web app.
    - See timeline which created by registered user.
    - See registered user's list.
    - See registered user's post on user's page.
* For registered user
    - Post text like below to timeline.
        - Plain text
        - URL
        - Embed Youtube Player(If you post youtube url, app automatically insert embed link)
    - Delete own post.

## Install
Clone repository and change to cloned directory.  
Install ruby gems

    bundle install

Create necessary database and some tables on mysql.

    mysql -u root -p -h localhost < bootstrap.sql  

Start mysql server.

    mysql.server start  

Run  

    ruby myapp.rb

After using it, stop mysql server.

    mysql.server stop
