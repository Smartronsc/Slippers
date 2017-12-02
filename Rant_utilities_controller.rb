#!/usr/bin/ruby
# https://codereview.stackexchange.com/questions/10312/communication-between-two-classes-in-ruby
# https://www.codementor.io/crismali/avoid-instance-variables-use-getters-and-setters-du107rgbi
# Rant!Rave Copyright 2017 RichardBradleySmith.com

class Controller
 def initialize()
    puts("Initializing controller")
    # Files defines every thing that makes up the world of files and uris
    @files    = Files.new 
  end  
 
 def start   
   self.show_menu
 end
 
 def show_menu
   puts <<-DELIMITER
   1. Remove duplicate locations
   2. List development categories
     DELIMITER
   selection = gets.chomp
 
  case selection
     when "0"
       puts(Controller.methods.sort)
     when "1"
      @function = File_io.new(@files.file_function[0])    # Deduplicator
      @function.process_control("deduplicator", @function)
     when "2"
      # File_io contains the useful combination of files to process at one time 
      @uri = File_io.new(@files.file_function[2])         # Reader   
      @uri.process_control("category_development", @uri)
   else
     exit
   end
 end

class Files
  # define the getters and setters or in this case the combined attr_accessor
  attr_accessor :file_list, :file_function, :uri_list  
  
  def initialize()
    @uri_list = {
      category_production:  { uri: "http://24.4.249.252/home/rs/Software/csv/chicago1.csv" }, 
      category_development: { uri: "/home/brad/software/csv/categories/productioncategories.csv" }
           
      }
    # These are the different files we can access in combination as needed
    @file_list = {
        categories: { path: "/home/brad/software/csv/categories",  file: "productioncategories.csv" },
        companies:  { path: "/home/brad/software/csv/companies",   file: "productioncompanies.csv" },
        master:     { path: "/home/brad/software/csv/masters",     file: "master.csv" },
        masterin:   { path: "/home/brad/software/test",            file: "masterin.csv" },
        masterout:  { path: "/home/brad/software/test",            file: "masterout.csv" },  
        audit:      { path: "/home/brad/software/csv/masters",     file: "audit.csv" }      
      }
    # These are the different combinations they are useful to be accessed in
    @file_function = [
      { function: "Deduplicater", using: [@file_list[:masterin]], creating: [@file_list[:masterout]], logging: [@file_list[:audit]] },  
      { function: "Matcher", using: [@file_list[:masterin]],  creating: [@file_list[:masterout]], category: [@file_list[:categories]], company: [@file_list[:companies]], logging: [@file_list[:audit]] },
      { function: "Reader", using: [@uri_list[:category_development]] },
        ]
  end
end 

class File_io 
  attr_reader :file_list, :file_function

  def initialize(setup)
    puts("Initializing file_io")
    @function     = setup[:function]
    @using        = setup[:using]
    @creating     = setup[:creating]
    @logging      = setup[:logging]
    @category     = setup[:category]
    @company      = setup[:company]
    @uri          = setup[:uri]
  end

  def process_control(process, uri)
    case process
      when "deduplicator"
        @deduplicator = Deduplicator.new
        @deduplicator.remove_duplicate_locations()
      when "category_development"
        @uri = Uri.new
        @uri.write_categories("development", @using)   
    else
        puts @function
        puts @using
        puts @logging
        puts @category
        puts @company
        puts @uri
    end
  end
end

class Uri
  attr_accessor :uri_list 
  
  def initialize()
     puts("Initializing uri")
   end
   
  def write_categories(area, using)
    case(area)
    when "development"
      @file_in = using[0]
      open_file = @file_in[:uri]
      open( open_file ) do |record|
        record.each_line do |line|
#         puts line if line['sometext']
          puts line
          end
      end
    end
  end
end 

class Deduplicator
  
  def initialize()
     puts("Initializing deduplicator")
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
    masterout     = File.new("/home/brad/software/csv/test/masterout.csv", "w") 
    duplicates    = File.new("/home/brad/software/csv/test/duplicates.csv", "w")
    
    File.readlines("/home/brad/software/csv/test/masterin.csv").each do |line| 
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
          #    location has not changed yet so keep comparing it to new masterin until it does
          line_split = line.split(",")
          if latitude_out == line_split[22] && longitude_out == line_split[23]
            duplicate += 1
            duplicates.puts line_out
            line_out = line
            else
              # location has changed so write the previous record, update the location to match the "new" previous
              #  make the current record the "new" previous and get a new line to compare the location of
              masterout.puts line_out
              latitude_out  = line_split[22] 
              longitude_out = line_split[23]
              line_out      = line
              output += 1
          end
      end
    end 
    masterout.puts line_out
    output +=1
    puts("read: " + read.to_s + " duplicate: " + duplicate.to_s + " output: " + output.to_s)  
  end
end 



  puts("===============================================")
  controller = Controller.new  
  controller.start()
  puts("===============================================")
  
end  
 