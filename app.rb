# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################
require "geocoder"

events_table = DB.from(:events)
rsvps_table = DB.from(:rsvps)
users_table = DB.from(:users)


before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

get "/" do
    puts events_table.all
    @events = events_table.all.to_a
    view "events"
end
                            

get "/events/:id" do
    @event = events_table.where(id: params[:id]).to_a[0]
    @rsvps = rsvps_table.where(event_id: @event[:id])
    @going_count = rsvps_table.where(event_id: @event[:id], going: true).count
    @users_table = users_table
    @exact_address= @event[:exact_address]

    results = Geocoder.search(@exact_address)
    view "event"
end

get "/events/:id/rsvps/new" do
    @event = events_table.where(id: params[:id]).to_a[0]
    view "new_rsvp"
end

get "/events/:id/rsvps/create" do
    puts params
    @event = events_table.where(id: params["id"]).to_a[0]
    rsvps_table.insert(event_id: params["id"],
                       user_id: session["user_id"],
                       going: params["going"],
                       comments: params["comments"])


account_sid = ENV["TWILIO_SID"]
auth_token = ENV["TW_AUTH"]
client = Twilio::REST::Client.new(account_sid, auth_token)

client.messages.create(
 from: "+18458394112", 
 to: "+13128601168",
 body: "Thanks for signing up for a Pick-up! Check back in prior to gameday to make sure we have #'s"
)

redirect "/events/#{@event[:id]}"
end


# delete the rsvp (aka "destroy")
get "/rsvps/:id/destroy" do
    puts "params: #{params}"

    rsvp = rsvps_table.where(id: params["id"]).to_a[0]
    @event = events_table.where(id: rsvp[:event_id]).to_a[0]

    rsvps_table.where(id: params["id"]).delete

    redirect "/events/#{@event[:id]}"
end


get "/users/new" do
    view "new_user"
end

post "/users/create" do
    puts params
    hashed_password = BCrypt::Password.create(params["password"])
    users_table.insert(name: params["name"], email: params["email"], password: hashed_password)
    view "create_user"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    user = users_table.where(email: params["email"]).to_a[0]
    puts BCrypt::Password::new(user[:password])
    if user && BCrypt::Password::new(user[:password]) == params["password"]
        session["user_id"] = user[:id]
        @current_user = user
        view "create_login"
    else
        view "create_login_failed"
    end
end

get "/logout" do
    session["user_id"] = nil
    @current_user = nil
    view "logout"
end

get "/new_event_sure" do
    view "new_event_sure"
end

get "/new_event" do
    view "new_event"
end

post "/create_event" do
    puts params
    events_table.insert(sport: params["sport"], 
                    description: params["description"],
                    date: params["date"],
                    start_time: params["time"],
                    location: params["location"],
                    exact_address: params["address"],
                    min_players: params["min_players"])
    view "created_event"
end



def view(template); erb template.to_sym; end
before { puts "Parameters: #{params}" }                                     

