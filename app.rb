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

before do #используется до всех функций
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

end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
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