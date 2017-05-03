require 'sinatra'
require 'sinatra/flash'
require 'coolline'
require 'pry-byebug'

if development?
  require 'sinatra/reloader'
  also_reload('**/*.rb')
end

# App class for RubyBooks application
class RubyBooksApp < Sinatra::Application
  enable :sessions

  get('/') do
    erb(:index)
  end

  get('/login') do
    erb(:login)
  end

  post('/login') do
    login_info = params.fetch(:login_info)
    login(login_info)
  end

  get('/logout') do
    logout
  end

  get('/signup') do
    erb(:signup)
  end

  post('/signup') do
    signup(params.fetch(:signup))
  end

  get('/books') do
    @books = Book.all
    erb(:books)
  end

  post('/books') do
    book = params.fetch('book').keys_to_symbol
    Book.new(book).save
  end

  get('/users') do
    @users = User.all
    erb(:users)
  end

  get('/:username/books') do
    @books = Book.where(username: username).all
    erb(:userbooks)
  end

  get('/my_books') do
    # use admin? method
  end
end

require_relative('helpers/init')
