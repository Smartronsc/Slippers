#!/usr/bin/ruby
# https://codereview.stackexchange.com/questions/10312/communication-between-two-classes-in-ruby
# https://www.codementor.io/crismali/avoid-instance-variables-use-getters-and-setters-du107rgbi
# Rant!Rave Copyright 2017 RichardBradleySmith.com

class Controller
 def initialize()
   puts("Initializing controller")
   @files = Files.new 
  end  
 
 def start   
   self.show_menu
 end
 
 def show_menu
   puts <<-DELIMITER
   1. Remove duplicate locations
   2. List remote file
   3. Matcher
     DELIMITER
#   selection = gets.chomp
    
    @matcher = File_io.new(@files.file_function[1])         # Filter   
    @matcher.processor("matcher")  
=begin 
  case selection
     when "0"
       puts(Controller.methods.sort)
     when "2"
      @uri = File_io.new(@files.file_function[2])         # Filter   
      @uri.processor("remote_filter")  
   else
     exit
   end
=end
 end

class Files
  # define the getters and setters or in this case the combined attr_accessor
  attr_accessor :file_list, :file_function, :uri_list  
  
  def initialize()
    @uri_list = {
      remote_file:  { uri: "/home/brad/software/csv/masters/audit.csv" },     
      }
    # These are the different files we can access in combination as needed
    @file_list = {
        categories: { path: "/home/brad/software/csv/categories",  file: "productioncategories.csv" },
        companies:  { path: "/home/brad/software/csv/companies",   file: "productioncompanies.csv" },
        master:     { path: "/home/brad/software/csv/masters",     file: "master.csv" },
        masterout:  { path: "/home/brad/software/csv/masters",     file: "masterout.csv" },  
        audit:      { path: "/home/brad/software/csv/masters",     file: "audit.csv" }      
      }
    # These are the different combinations they are useful to be accessed in
    @file_function = [
      { :function => "Deduplicater", :using => [@file_list[:master]], :creating => [@file_list[:masterout]], :audit => [@file_list[:audit]] },  
      { :function => "Matcher", :using => [@file_list[:master]],  :creating => [@file_list[:masterout]], :category => [@file_list[:categories]], :company => [@file_list[:companies]], audit: [@file_list[:audit]] },
      { :function => "Remote", :using =>[@uri_list[:remote_file]] },
        ]
  end
end 

class File_io 
  attr_accessor :uri_list, :file_list, :file_function 

  def initialize(setup)
    puts("Initializing file_io")
    @files        = Files.new 
    @function     = setup[:function]
    @using        = setup[:using]
    @creating     = setup[:creating]
    @category     = setup[:category]
    @company      = setup[:company]
    @masterout    = setup[:masterout]
    @audit        = setup[:audit]
  end

  def processor(process)
    case process
      when "deduplicator"
        @deduplicator = Deduplicator.new
        @deduplicator.remove_duplicate_locations()
      when "matcher"
        @matcher = Matcher.new(@files.file_function[1])
        @matcher.record_matcher()     
      when "remote_filter"
        @filter = Uri.new(@files.file_function[2])
        @filter.remote()     
    else
        puts @function
        puts @using
        puts @category
        puts @company
        puts @master
        puts @masterout
        puts @audit
    end
  end
end

class Matcher
  attr_accessor :file_list, :file_function  
  
  def initialize(setup)
    puts("Initializing matcher")
    @function     = setup[:function]
    @using        = setup[:using]
    @creating     = setup[:creating]
    @category     = setup[:category]
    @company      = setup[:company]
    @master       = setup[:master]
    @materout     = setup[:masterout]
    @audit        = setup[:audit]
  end
   
  def record_matcher()
    
    @file_using = @using
    path_name = @file_using[0].fetch(:path)
    file_name = @file_using[0].fetch(:file)
    master = path_name + "/" + file_name
    open( master ) { |record| 
      record.each_line { |line| 
#        p line 
      }
    }
    
    @file_category = @category
    path_name = @file_category[0].fetch(:path)
    file_name = @file_category[0].fetch(:file)
    category = path_name + "/" + file_name
    open( category ) { |record| 
      record.each_line { |line| 
        p line 
      }
    }

    @file_company = @company
    path_name = @file_company[0].fetch(:path)
    file_name = @file_company[0].fetch(:file)
    category = path_name + "/" + file_name
    open( category ) { |record| 
      record.each_line { |line| 
#        p line 
      }
    }

    @file_creating = @creating
    path_name  = @file_creating[0].fetch(:path)
    file_name  = @file_creating[0].fetch(:file)
    new_master = path_name + "/" + file_name
    masterout  = File.new(new_master, "w+")
    
    @file_audit = @audit
    path_name   = @file_audit[0].fetch(:path)
    file_name   = @file_audit[0].fetch(:file)
    new_audit   = path_name + "/" + file_name
    audit       = File.new(new_audit, "w+")
=begin
        count  += 1
        commas = line.count(',')
        if line.chomp.empty?
          audit.puts count 
        elsif commas < 24
          audit.puts line + " " + count.to_s
        else
          masterout.puts line
        end
      }
    }
=end
  end
end 

class Uri
  attr_accessor :uri_list, :file_list, :file_function  
  
  def initialize(setup)
    puts("Initializing uri")
    @function     = setup[:function]
    @using        = setup[:using]
    @creating     = setup[:creating]
    @category     = setup[:category]
    @company      = setup[:company]
    @master      = setup[:master]
    @materout     = setup[:masterout]
    @audit        = setup[:audit]
  end
  
  def remote()
    @file_in = @using
    open_file = @file_in[0].fetch(:master)
    open( open_file ) { |record| 
      record.each_line { |line| 
        p line
      }
    }
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
 