#!/usr/bin/ruby
# timetracker.rb - Add daily log from a text file to Day One and produce a report
# Jamie Bennett 2014 <jamie@jamiedbennett.com
# 
# Run it with launchd at 11pm and forget about it. Inspired by Brett Terpstrai's task paper to
# DayOne logger <http://brettterpstra.com/2012/02/25/automating-taskpaper-to-day-one-logs/>
# 
# Notes:
#   * Configure dayonepath and summaryfile path to reflect where your day one journal and daily log files are.
#   * The format of the daily log file is pretty specific, if you change the date format without modifying the
#     today format below you will break things.
#   * Run with a specifc date to log that days activity
#
require 'time'
require 'date'
require 'erb'

# Configuration options
dayonepath = "/path/to/your/dayone/journal/entries/Journal.dayone/entries/"
summaryfile = "/path/to/your/text/log/file.md"
addtodayone = true
printsummary = false
activities = {"email" => 0, "meeting" => 0, "research" => 0,
    "education" => 0, "review" => 0, "break" => 0, "exercise" => 0,
    "developing" => 0, "writing" => 0, "admin" => 0}

# Nothing to configure past this point
uuid = %x{uuidgen}.gsub(/-/,'').strip
datestamp = Time.now.utc.iso8601

# Day One template header
template = ERB.new <<-XMLTEMPLATE
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Creation Date</key>
	<date><%= datestamp %></date>
	<key>Entry Text</key>
	<string><%= entrytext %></string>
	<key>Starred</key>
	<false/>
	<key>UUID</key>
	<string><%= uuid %></string>
    <key>Tags</key>
    <array>
        <string>worklog</string>
    </array>
</dict>
</plist>
XMLTEMPLATE

today = Time.now().strftime('%Y-%m-%d')
file = summaryfile.strip

# Accept a date as the only argument, useful for recording a previous date
if ARGV[0]
    d = Date.parse(ARGV[0]) rescue nil
    if d
        today = ARGV[0]
        datestamp = "#{today}T09:00:00Z"
    else
        puts "Invalid date argument, please use yyyy-mm-dd format\n"
        exit(0)
    end
end

entries = ""
totaltime = 0
if File.exists?(file)
    f = File.open(file)
    lines = f.read
    f.close

    currenttime = 0
    duration = 0
    lines = lines.split("\n")
    lines.each do |line|
        if line.include? today
            entries += "* #{line}\n"
            
            # Calculate the time spent on the item
            thistime = line.split(" ")[2]
            minutes = ((thistime.split(":")[0]).to_i * 60) + (thistime.split(":")[1]).to_i
            if currenttime > 0
                duration = currenttime - minutes
                totaltime += duration
            end
            currenttime = minutes
            
            # Add duration to the first tag found
            if line.include?("@")
                activities[line.split("@")[1]] += duration
            end
        end
    end
else
    puts "error: file #{file.strip} does not exist\n"
end

# Create summary text
summarytext = ""
activities.each_pair {|k, v| summarytext += "* Time spent in #{k}: #{v/60}hrs #{v%60}mins\n"}
summarytext += "* **Total time tracking today: #{totaltime/60}hrs #{totaltime%60} minutes**\n"

if printsummary
    puts "\n#{summarytext}"
end

# Add to Day One
if entries.length > 0 && addtodayone == true
    entrytext = "## Work \n\n#{entries}\n### Summary\n#{summarytext}"
    fh = nil
    fh = File.new(File.expand_path(dayonepath+uuid+".doentry"),'w+')
    if fh != nil
      fh.puts template.result(binding)
      fh.close
    else
      puts "Error creating new file\n"
    end
end
