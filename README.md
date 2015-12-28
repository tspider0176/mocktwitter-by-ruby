## Mock twitter app
Install ruby gems

    bundle install

Make environment at mysql.

    mysql -u root -p -h localhost < bootstrap.sql  

Start mysql server.

    mysql.server start  

Run  

    ruby myapp.rb

Stop mysql server.

    mysql.server stop
