# timetracker.rb
Simple daily timetracking with a text file, storing the results in Day One  

## Usage

The default is to log the current dates activity

    ruby ./timetracker.rb

To log a specific date:

    ruby ./timetracker.rb 2014-03-20

Alternatively run it with launchd (or your favourite daemon) at 11:55pm and forget about it.

## Log file

The log file format needs to be precise. It comprises of a date, time, activity, and **one** tag. The tag is what determines the type of activity and is what the duration calculation uses to determine task switching. End the day with an entry with no tag.

    - 2014-03-19 23:06 | End of day
    - 2014-03-19 22:48 | Email chew @email
    - 2014-03-19 19:24 | Research for report on the benefits of Vegetarianism @research

## Notes
* Don't forget to configure the dayonepath and summaryfile path to reflect where your day one journal and log file are.
* The format of the daily log file is pretty specific, if you change the date format without modifying the today format in the script you will break things.
* The script only recognises a few tags, add your own to the top of the file.
* Yes, I know the script is limited, and yes, I plan to improve it over time. It works for me and Yes, I accept patches ;)

