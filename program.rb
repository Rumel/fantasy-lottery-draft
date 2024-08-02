# frozen_string_literal: true

require 'json'
require 'optparse'

options = {
  debug: false,
  filename: nil
}

OptionParser.new do |opts|
  opts.banner = 'Usage: program.rb [options]'

  opts.on('-f', '--file FILENAME', 'File to process') do |filename|
    options[:filename] = filename
  end

  opts.on('-d', '--debug', 'Enable debug mode') do |_filename|
    options[:debug] = true
  end
end.parse!

if options[:filename].nil?
  puts 'Missing filename'
  exit 1
end

json = JSON.parse(File.read(options[:filename]))

seed = json['randomSeed']
teams = json['teams']

lottery = []
teams.each do |team|
  team['weight'].times do
    lottery << team['name']
  end
end

team_order = []

puts 'Starting the lottery draft'

out_line = ''
teams.size.times do |i|
  puts 'Shuffling'
  unless options[:debug]
    5.times do
      sleep 1
      print '.'
    end
    print "\n"
  end

  lottery.shuffle!(random: Random.new(seed))
  selected_team = lottery.first
  puts ''
  puts "Selected #{selected_team}!"
  puts ''
  s = "Round #{i + 1}: #{selected_team}"
  out_line += "#{s}\n"

  team_order << selected_team
  lottery.delete_if { |team| team == selected_team }
end

puts 'Draft finished!'
puts out_line

File.write("output/#{File.basename(options[:filename], '.*')}-output.txt", out_line)
