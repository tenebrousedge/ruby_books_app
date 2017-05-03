require 'sinatra'
require 'sinatra/flash'
require 'coolline'
require 'pry-byebug'
require 'date'
require 'rubybooks'

Sequel.extension :migration
if development?
  require 'sinatra/reloader'
  also_reload('**/*.rb')
end

# App class for Rubybooks application
class RubyBooksApp < Sinatra::Application
  enable :sessions

  register do
    def auth (type)
      condition do
        redirect "/login" unless send("#{type}?")
      end
    end
  end
  # index page
  # contents: login or signup forms
  # title
  get('/') do
    @books = Rubybooks::Book.all
    erb(:index)
  end

  post('/login') do
    login_info = params.fetch(:login_info)
    login(login_info)
  end

  get('/logout', auth: :user) do
    logout
  end

  post('/signup') do
    signup(params.fetch(:signup))
  end

  get('/books') do
    @books = Rubybooks::Book.where(id: Sequel.~(Rubybooks::BooksUsers.where(returned: 'NULL')))
    erb(:books)
  end

  get('/books/new', auth: :admin) do
    erb(:new_book)
  end

  post('/books/new', auth: :admin) do
    book = params.fetch('book').keys_to_symbol
    Rubybooks::Book.new(book).save
  end

  get('/users', auth: :admin) do
    @users = Rubybooks::User.all
    erb(:users)
  end

  get('/:username/books', auth: :admin) do
    @books = Rubybooks::Book.where(username: username).all
    erb(:userbooks)
  end

  get('/my_books', auth: :user) do
    @books = current_user.checkouts.books
    erb(:userbooks)
  end

  post('/checkout/:id', auth: :user) do
    due = DateTime.now + 7
    Rubybooks::BooksUsers.insert(book_id: id, user_id: current_user.id, due: due, checkout: Time.now)
    redirect 'my_books'
  end

  post('/return_book/:id', auth: :user) do
    Rubybooks::BooksUsers.where(book_id: id).update(returned: Time.now)
    redirect 'my_books'
  end
end

require_relative('helpers/init')
