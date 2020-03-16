# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################


# Database schema - this should reflect your domain model
DB.create_table! :events do
  primary_key :id
  String :sport
  String :description, text: true
  String :date
  String :start_time
  String :location
  String :exact_address
  Fixnum :min_players
end
DB.create_table! :rsvps do
  primary_key :id
  foreign_key :event_id
  foreign_key :user_id
  Boolean :going
  String :comments, text: true
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
events_table = DB.from(:events)

events_table.insert(sport: "Basketball", 
                    description: "Let's get a run going!",
                    date: "June 21",
                    start_time: "3 pm",
                    location: "SPAC",
                    exact_address: "2311 Campus Dr, Evanston, IL 60208",
                    min_players:8)

events_table.insert(sport: "Volleyball", 
                    description: "Looking for 6 for VB",
                    date: "July 4",
                    start_time: "6 pm",
                    location: "E2",
                    exact_address: "1890 Maple Ave, Evanston, IL 60201",
                    min_players:6)

events_table.insert(sport: "Basketball", 
                    description: "Will reserve the court when we get 6 players",
                    date: "July 4",
                    start_time: "6 pm",
                    location: "E2",
                    exact_address: "1890 Maple Ave, Evanston, IL 60201",
                    min_players:6)

events_table.insert(sport: "Tennis", 
                    description: "Court reserved for 4",
                    date: "July 29",
                    start_time: "4 pm",
                    location: "SPAC",
                    exact_address: "2311 Campus Dr, Evanston, IL 60208",
                    min_players:6)