require 'sinatra'
require 'faraday'
require 'pry'
require 'dotenv'

enable :sessions
set :session_secret, 'super secret'

path = 'https://courseplatform-rails.herokuapp.com/api/v1'
get '/' do
    if session[:access_token]
        redirect '/courses'
    else
        erb :login, {:layout => :index_layout}
    end
end

get '/courses' do
    api = "#{path}/original/courses/"
    response = Faraday.get(api, nil ,{'access_token' => session[:access_token]})
    @courses = JSON.parse(response.body)
    erb :home, {:layout => :index_layout}
end

get '/course/:id' do
    api = "#{path}/original/courses/#{params[:id]}"
    response = Faraday.get(api,nil,{'access_token' => session[:access_token]})
    @course = JSON.parse(response.body)["course"]
    @bought = JSON.parse(response.body)["bought"]
    erb :course, {:layout => :index_layout}
end

get '/course/:id/buy' do
    api = "#{path}/original/courses/#{params[:id]}"
    response = Faraday.post(api,nil,{'access_token' => session[:access_token]})
    response_body = JSON.parse(response.body)
    binding.pry
    if response_body["error_code"]
        @error = response_body["error_message"]
        erb :error, {:layout => :index_layout}
    else
        redirect "/record/#{response.body}"
    end
end

get '/records' do
    api = "#{path}/orderrecord/"
    response = Faraday.get(api,nil,{'access_token' => session[:access_token]})
    @records = JSON.parse(response.body)
    erb :records, {:layout => :index_layout}
end

get '/record/:course_id' do
    api = "#{path}/orderrecord/#{params[:course_id]}"
    response = Faraday.get(api,nil,{'access_token' => session[:access_token]})
    @record = JSON.parse(response.body)
    erb :single_record, {:layout => :index_layout}
end

get '/filter/course_type' do
    api = "#{path}/orderrecord/filter/course_type/?type=#{params[:course_type]}"
    response = Faraday.get(api,nil,{'access_token' => session[:access_token]})
    @records = JSON.parse(response.body)
    puts "#{@records}"
    erb :records, {:layout => :index_layout}
end

get '/filter/unexpired' do
    api = "#{path}/orderrecord/filter/unexpired/"
    response = Faraday.get(api,nil,{'access_token' => session[:access_token]})
    @records = JSON.parse(response.body)
    erb :records, {:layout => :index_layout}
end




post '/login' do
    api = "#{path}/sessions/?email=#{params[:email]}&password=#{params[:password]}"
    response = Faraday.post(api)
    response_body = JSON.parse(response.body)
    if response_body["error_code"]
        @error = response_body["error_message"]
        erb :login, {:layout => :index_layout}
    else
        session[:access_token] = response.headers["access_token"]        
        redirect '/courses'
    end
end

get '/signup' do
    erb :signup, {:layout => :index_layout}
end
post '/signup' do
    api = "#{path}/signup/?user[email]=#{params[:email]}&user[password]=#{params[:password]}&user[password_confirmation]=#{params[:password_confirmation]}"
    response = Faraday.post(api)
    response_body = JSON.parse[response.body]
    if response_body["error_code"]
        @error = response_body["error_message"]
        erb :signup, {:layout => :index_layout}
    else
        session[:access_token] = response.headers["access_token"]        
        erb :home, {:layout => :index_layout}
    end
end

get '/logout' do
    session.clear
    redirect '/'
end