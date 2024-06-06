# frozen_string_literal: true

require_relative 'client'

# lib/client_runner.rb

# puts 'enter your name'
# name = gets.chomp

client = Client.new(3336)
while true do
  output = ""
  until output != ""
    output = client.capture_output
  end
  if output.include?(":")
    print output
    client.provide_input(gets.chomp)
  else
    puts output
  end
end
