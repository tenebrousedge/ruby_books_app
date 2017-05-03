# Adapted from https://gist.github.com/1444494

# Things you need to do before using this lib:
# require 'sinatra/flash' (gem sinatra-flash)
# register Sinatra::Flash
# register Sinatra::AuthInABox
# enable :sessions optionally configuring your favourite sessions settings
# Have a User model which defines self.authenticate(user, pass) and admin?
# In your forms (login, signup, etc) make sure you display flash[:errors]

# See the other files in the gist for Sequel/DataMapper models

# open up the Sinatra module
module Sinatra
  # authentication helper module for Sinatra
  module AuthInABox
    def auth_setup(params)
      params.each do |k, v|
        settings.authinabox[k] = v if settings.authinabox.key?(k)
      end
    end

    def self.registered(app)
      app.helpers Helpers
      app.set :authinabox,
              login_redirect: '/',
              logout_redirect: '/',
              signup_redirect: '/',
              login_url: '/login'
    end

    # open Sinatra Helpers module
    module Helpers
      def login(params, options = {})
        options = {
          redirect: true,         # Controls whether we redirect at all
          success_redirect: nil,  # Override success redirect URL
          failure_redirect: nil,  # Override failure redirect url
        }.merge(options)
        user = Rubybooks::User.authenticate(params[:username], params[:password])
        if user.nil?
          flash[:errors] = 'Login failed'
          redir_url = options[:failure_redirect] || request.fullpath
        else
          session[:user] = user.id
          redir_url = session[:login_return_to] || options[:success_redirect] ||
                      settings.authinabox[:login_redirect]
        end
        redirect redir_url if options[:redirect]
        user
      end

      def logout(options = {})
        options = {
          redirect: true,         # Whether we redirect at all
          redirect_to: nil,       # Overrides where we redirect to
        }.merge(options)
        session[:user] = nil
        redirect options[:redirect_to] ||
          settings.authinabox[:logout_redirect] if options[:redirect]
      end

      def signup(params, options = {})
        options = {
          login: true,            # Whether we login after creating the account
          redirect: true,         # Controls whether we redirect at all
          success_redirect: nil,  # Override where to redirect on success
          failure_redirect: nil,  # Override where to redirect on failure
        }.merge(options)
        user = Rubybooks::User.new(params)
        if user.save
          session[:user] = user.id if options[:login]
          redirect options[:success_redirect] ||
                   settings.authinabox[:signup_redirect] if options[:redirect]
        else
          flash[:errors] = '<ul><li>' << user.errors.full_messages
            .join('</li><li>') << '</li></ul>'
          redirect options[:failure_redirect] ||
            request.fullpath if options[:redirect]
        end
        user
      end

      def login_required(options = {})
        options = {
          redirect: true, # Controls whether we redirect at all
          login_url: nil, # Overrides redirect if they aren't authenticated
        }.merge(options)
        return true if session[:user]
        session[:login_return_to] = request.fullpath
        redirect options[:login_url] ||
          settings.authinabox[:login_url] if options[:redirect]
        false
      end

      def admin_required(options = {})
        options = {
          redirect: true, # Controls whether we redirect at all
          login_url: nil, # Overrides redirect if they aren't authenticated
          # Flash text to set. False/nil to disable
          error_msg: 'You need to be an admin'
        }.merge(options)
        unless session[:user]
          session[:login_return_to] = request.fullpath
          redirect options[:login_url] ||
            settings.authinabox[:login_url] if options[:redirect]
          return false
        end
        unless current_user.admin?
          flash[:errors] = options[:error_msg] if options[:error_msg]
          session[:login_return_to] = request.fullpath
          redirect options[:login_url] ||
            settings.authinabox[:login_url] if options[:redirect]
          return false
        end
        true
      end

      def current_user
        return unless session[:user]
        Rubybooks::User.get(session[:user])
      end

      def admin?
        current_user && current_user.admin?
      end

      def user?
        current_user
      end
    end
  end

  register AuthInABox
end
