#!/usr/bin/ruby
# https://codereview.stackexchange.com/questions/10312/communication-between-two-classes-in-ruby
# https://www.codementor.io/crismali/avoid-instance-variables-use-getters-and-setters-du107rgbi
# Rant!Rave Copyright 2017 RichardBradleySmith.com
class Files
  # define the getters and setters
  attr_accessor :file_list, :file_function
  
  def initialize()
    #weapons
    @file_list = {
        input:      { path: "/home/brad/software/csv/categories",  file: "productioncategories.csv" },
        categories: { path: "/home/brad/software/csv/categories",  file: "productioncatories.csv" },
        companies:  { path: "/home/brad/software/csv/companies",   file: "productioncompanies.csv" },
        master:     { path: "/home/brad/software/csv/masters",     file: "master.csv" }, 
        audit:      { path: "/home/brad/software/csv/masters",     file: "audit.csv" }      
      }

    @file_function = [
      { function: "Category to Company", using: [@file_list[:input]], providing: [@file_list[:audit]], category: [@file_list[:categories]], company: [@file_list[:companies]] },
      ]
  end
end 

class Controller
 def initialize()
    puts("Initializing")
    # Files defines all the static file stuff 
    @files    = Files.new 
    # File_io contains all the thing that can be done with the static file stuff 
    @function = File_io.new(@files.file_function[0])   
  end  
 
 def start
   @function.file_control()   
   self.show_menu
 end
 
 def show_menu
   puts <<-DELIMITER
   1. Remove duplicate location
   4. Go to another place!
     DELIMITER
   selection = gets.chomp
 
   case selection
     when "0"
       puts(Controller.methods.sort)
     when "1"
       self.remove_duplicate_locations
   else
         exit
   end
 end

class File_io 
  attr_reader :action

  def initialize(setup)
    @function   = setup[:function]
    @using      = setup[:using]
    @providing  = setup[:providing]
    @category   = setup[:category]
    @company    = setup[:company]
  end

  def file_control()
    puts @function
    puts @using
    puts @providing
    puts @category
    puts @company
  end

  def remove_duplicate_locations()
    line_out      = ""
    line_split    = []
    duplicate     = 0
    latitude      = 0
    longitude     = 0
    latitude_out  = 0
    longitude_out = 0
    output        = 0
    read          = 0
    master      = File.new("/home/brad/software/csv/allready/master.csv", "w") 
    duplicates  = File.new("/home/brad/software/csv/allready/dupfinal.csv", "w")
    
    File.readlines("/home/brad/software/csv/allready/newfinal.csv").each do |line| 
      read += 1 
      # if line_out is blank initialize the process, get a fresh line, split it, then get the next line
      #  now we are set up for the next line and line_out has  the previouse line for processing in the else if else logic  
      if line_out == ""
        line_out      = line
        line_split    = line.split(",")
        latitude_out  = line_split[22] 
        longitude_out = line_split[23]
        else
          # split the "next line" which is the current line, compare to the previous line
          #  if it is the same location write the previous line out as a duplicate audit trail
          #   the current becomes the previous which sets us for the next line to be read in 
          #    location has not changed yet so keep comparing it to new input until it does
          line_split = line.split(",")
          if latitude_out == line_split[22] && longitude_out == line_split[23]
            duplicate += 1
            duplicates.puts line_out
            line_out = line
            else
              # location has changed so write the previous record, update the location to match the "new" previous
              #  make the current record the "new" previous and get a new line to compare the location of
              master.puts line_out
              latitude_out  = line_split[22] 
              longitude_out = line_split[23]
              line_out      = line
              output += 1
          end
      end
    end 
    master.puts line_out
    output +=1
    puts("read: " + read.to_s + " duplicate: " + duplicate.to_s + " output: " + output.to_s)  
  end
end 

  puts("===============================================")
  controller = Controller.new  
  controller.start()
  puts("===============================================")
  
end  
 