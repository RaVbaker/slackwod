require 'sinatra'
require 'koala'
require 'dotenv'
require 'json'
Dotenv.load

get '/' do
  access_token = ENV["ACCESS_TOKEN"]
  graph = Koala::Facebook::API.new(access_token)
  posts = graph.get_connection("udziewczynrestauracja", "posts", fields: "message,full_picture,created_time")
  lunch_posts = posts.select { |post| post["message"].to_s.match /lunch|zapraszamy|smacznego/i }
  lunch_post = lunch_posts.first
  lunch_text = lunch_post["message"]
  lunch_photo = lunch_post["full_picture"]
  page_id, item_id = lunch_post["id"].split("_")
  posted_at = Time.parse(lunch_post["created_time"])

  extra_message = "posted at: #{posted_at.to_s}\nlink: https://www.facebook.com/#{page_id}/posts/#{item_id}"
  content_type :json
  JSON(text: lunch_text, attachments: [{ text: extra_message, image_url: lunch_photo }])
end
