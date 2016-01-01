Mock twitter app
====
## Description
Twitter-like web application by ruby and sinatra for self learning.

## Environment
* ruby 2.2.3p173
* Bundler version 1.11.2
* MySQL Server version: 5.6.26 Homebrew

## Install
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
