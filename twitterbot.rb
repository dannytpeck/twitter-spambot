require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts "Message to be tweeted should not exceed 140 characters."
    end
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
        when 'q' then puts "Goodbye!"
        when 't' then tweet(parts[1..-1].join(" "))
        when 'dm' then dm(parts[1], parts[2..-1].join(" "))
        when 'spam' then spam_my_followers(parts[1..-1].join(" "))
        when 'elt' then everyones_last_tweet
        when 's' then shorten(parts[1])
        when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
        when 'x' then spam_twitter
        else
          puts "Sorry, I don't know how to #{command}"
      end
    end
  end

  def dm(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message
    
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
    if screen_names.include?(target)
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "You can only DM people who follow you!"
    end
  end

  def followers_list
    screen_names = []
    @client.followers.each do |follower|
      screen_names << @client.user(follower).screen_name
    end
    screen_names
  end

  def spam_my_followers(message)
    screen_names = followers_list
    screen_names.each do |screen_name|
      dm(screen_name, message)
    end
  end

  def everyones_last_tweet
    friends = @client.friends
    friends.each do |friend|
      puts "#{@client.user(friend).screen_name} said..."
      puts "#{@client.user(friend).status.text}"
      puts ""
    end
  end

  def shorten(original_url)
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    puts "Shortening this URL: #{original_url}"
    shortened_url = bitly.shorten(original_url).short_url
    puts "Shortened URL: #{shortened_url}"
    shortened_url
  end

  def spam_twitter
    message = 0
    loop do
      message += 1
      tweet("I created a spam bot for twitter! Message: #{message.to_s}")
    end
  end

end

blogger = MicroBlogger.new
blogger.run
