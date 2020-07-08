require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def is_barber_exist? db, name
	db.execute('select * from Barbers where name=?', [name]).length > 0
end	

def seed_db db, barbers

	barbers.each do |barber|
		if !is_barber_exist? db, barber
			$db.execute 'insert into Barbers (name) values (?)', [barber]
		end
	end	
end

before do #используется до всех get/post  при перезагрузке любой страницы
	@barbers = $db.execute 'select * from Barbers'
end

configure do
	$db = get_db
	$db.execute 'CREATE TABLE IF NOT EXISTS
		"Users" 
		(
			"id" 		INTEGER PRIMARY KEY AUTOINCREMENT, 
			"username" 	TEXT, 
			"phone" 	TEXT, 
			"datestamp" TEXT, 
			"barber" 	TEXT, 
			"color" 	TEXT
			)'

	$db.execute 'CREATE TABLE IF NOT EXISTS
		"Barbers" 
		(
			"id" 		INTEGER PRIMARY KEY AUTOINCREMENT, 
			"name" 	TEXT 
			)'	

	seed_db $db, ['Петя', 'Люда', 'Вася', 'Толик']

	$db.execute 'CREATE TABLE IF NOT EXISTS
		Posts 
		(
			id INTEGER PRIMARY KEY AUTOINCREMENT, 
			created_date DATE, 
			content TEXT
		)'

	$db.execute 'CREATE TABLE IF NOT EXISTS
		Comments
		(
			id INTEGER PRIMARY KEY AUTOINCREMENT, 
			created_date DATE, 
			content TEXT,
			post_id INTEGER
		)'	
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			

	@results_post = $db.execute 'select * from Posts order by id desc'

	erb :index
end

get '/about' do
	erb :about
end

get '/visit' do
	erb :visit
end



post '/visit' do

		@username = params[:username]
		@phone = params[:phone]
		@datetime = params[:datetime]
		@barber = params[:barber]
		@color = params[:color]

		hh = {:username => 'Введите имя',
			:phone => 'Введите телефон',
			:datetime => 'Введите дату'}

		@error = hh.select {|key, | params[key] == ""}.values.join(", ")

		if @error != ''
			return erb :visit
		end

#		db = get_db
		$db.execute 'insert into
			Users
				(
					username,
					phone,
					datestamp,
					barber,
					color
				)
				values(	?, ?, ?, ?, ?)', [@username, @phone, @datetime, @barber, @color]

#		erb "OK. #{@username}, #{@phone}, #{@datetime}, #{@barber}, #{@color}"
		erb "<h2>Вы записались</h2>"
	end

get '/showusers' do
	@results = $db.execute 'select * from Users order by id desc'
  	erb :showusers
end

def get_db
	db = SQLite3::Database.new 'shop.db'
	db.results_as_hash = true
	return db 
end

get '/new' do
  	erb :new
end

post '/new' do
  content = params[:content]

  if content.length == 0
  	@error = 'Введите текст'
  	return erb :new
  end

  $db.execute'insert into Posts (content, created_date) values ( ?, datetime())', [content]

  redirect to '/'
#  erb "You typed #{content}"
end

get '/details/:post_id' do
	post_id = params[:post_id]

	results_post = $db.execute 'select * from Posts where id = ?', [post_id]
	@row = results_post[0]

	@comments = $db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	erb :details
end

post '/details/:post_id' do
	post_id = params[:post_id]
	content = params[:content]	
	$db.execute 'insert into Comments (content, created_date, post_id) values ( ?, datetime(), ?)', [content, post_id]

	redirect to('/details/' + post_id)
end