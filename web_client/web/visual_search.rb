require 'rubygems'
require 'sinatra'
require File.dirname(__FILE__) + '/../tag'
require File.dirname(__FILE__) + '/../vendor/rack-uploads/lib/rack/uploads'

use Rack::Uploads

get "/tag" do
  erb :tag
end

post "/tag" do
  tag_name = params["tag_name"]
  file_location = File.dirname(__FILE__) + "/../originals/snapshot.jpg"
  

  Tag.store(tag_name, file_location)
  "Tagged your image"
end

get "/search" do
  erb :search
end

post "/search" do
  require 'reduce' 
  file_location = File.dirname(__FILE__) + "/../originals/search.jpg"
  env['rack.uploads'].each do |upload|
    upload.mv(file_location)
  end

  Reduce.search(file_location)
  File.open("result", 'r'){|f| f.read }
end

