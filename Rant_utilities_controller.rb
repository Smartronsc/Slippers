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
    
    @sorter = File_io.new(@files.file_function[2])          
    @sorter.processor("sorter")  
=begin 
  case selection
    when "0"
      puts(Controller.methods.sort)
    when "1"
      @matcher = File_io.new(@files.file_function[1])     # Filter   
      @matcher.processor("matcher")  
    when "2"
      @uri = File_io.new(@files.file_function[2])       
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
        categories_in:    { path: "/home/brad/software/csv/categories",   file: "productioncategories.csv" },
#        categories_in:   { path: "/home/brad/software/csv/categories",   file: "testcategories.csv" },
        companies_in:     { path: "/home/brad/software/csv/companies",    file: "productioncompanies.csv" },
        master_in:        { path: "/home/brad/software/csv/masters",      file: "master.csv" },
#        master_in:       { path: "/home/brad/software/csv/masters",      file: "mastertest.csv" },
        master_out:       { path: "/home/brad/software/csv/masters",      file: "masterout.csv" },
        no_category_out:  { path: "/home/brad/software/csv/masters",      file: "nocategory.csv" },
        sort_in:          { path: "/home/brad/software/csv/sort",         file: "sortin.csv" },
        sort_out:         { path: "/home/brad/software/csv/sort",         file: "sortout.csv" },  
        audit_out:        { path: "/home/brad/software/csv/masters",      file: "audit.csv" }      
      }
    # These are the different combinations they are useful to be accessed in
    @file_function = [
      { :function => "Deduplicater", :master_in => [@file_list[:masterin]], :master_out => [@file_list[:master_out]], :audit_out => [@file_list[:audit_out]] },  
      { :function => "Matcher", :master_in => [@file_list[:master_in]], :company_in => [@file_list[:companies_in]],  :category_in => [@file_list[:categories_in]],
                                :master_out => [@file_list[:master_out]], :no_category_out => [@file_list[:no_category_out]], audit_out: [@file_list[:audit_out]] },
      { :function => "Sorter", :sort_in =>[@file_list[:sort_in]], :sort_out =>[@file_list[:sort_out]], audit_out: [@file_list[:audit_out]] },
      { :function => "Remote", :master_in =>[@uri_list[:remote_file]] },
        ]
  end
end 

class File_io 
  attr_accessor :uri_list, :file_list, :file_function 

  def initialize(setup)
    puts("Initializing file_io")
    @files           = Files.new 
    @function        = setup[:function]
    @master_in       = setup[:master_in]
    @master_out      = setup[:master_out]
    @category_in     = setup[:category_in]
    @company_in      = setup[:company_in]
    @sort_in         = setup[:sort_in]
    @sort_out        = setup[:sort_out]
    @no_category_out = setup[:no_category_out]
    @audit_out       = setup[:audit_out]
  end

  def processor(process)
    case process
      when "deduplicator"
        @deduplicator = Deduplicator.new
        @deduplicator.remove_duplicate_locations()
      when "matcher"
        @matcher = Matcher.new(@files.file_function[1])
        @matcher.record_matcher()   
      when "sorter"
        @sorter = Sorter.new(@files.file_function[2])
        @sorter.record_sorter()    
      when "remote_filter"
        @filter = Uri.new(@files.file_function[3])
        @filter.remote()     
    else
        puts @function
        puts @master_in
        puts @category_in
        puts @company_in
        puts @sort_in
        puts @sort_out
        puts @master_in
        puts @master_out
        puts @no_category_out
        puts @audit_out
    end
  end
end

class Matcher
  attr_accessor :file_list, :file_function  
  
  def initialize(setup)
    puts("Initializing matcher")
    @function           = setup[:function]
    @master_in          = setup[:master_in]
    @master_out         = setup[:master_out]
    @master_in_file     = setup[:master_in_file]
    @category_in        = setup[:category_in]
    @company_in         = setup[:company_in]
    @company_in_data    = setup[:company_in_data]
    @category_in_data   = setup[:category_in_data]
    @no_category_out    = setup[:no_category_out]
    @audit_out          = setup[:audit_out]
    initialize_files
  end
  
  def record_matcher()
    
    attr_accessor = :master_in, :category_in_data, :company_in_data, :master_out, :no_category_out, :audit_out 
    
    production_count  = 0                                     # records pushed to production
    rework_count      = 0                                     # records without a home
    processed_count   = 0                                     # total records processed                         
    pushed            = false                                 # no categories matched the words that compose the company name
    company_name_data = Array.new                             # initialize the array for the company name split into words
    category_slots    = Array.new                             # initialize the array for four possible categories for this company record
    @file_master_in   = @master_in
    path_name = @file_master_in[0].fetch(:path)
    file_name = @file_master_in[0].fetch(:file)
    master_in = path_name + "/" + file_name
    open( master_in ) { |record|                              # as each record is read in from the comma separated values in the master file
      record.each_line { |line| 
        processed_count += 1
        master_in_data = line.split(",")                       
        company_name = master_in_data[9]                      # pick out the company name from the split up line               
        company_name = company_name.split.map(&:capitalize)   # capitalize first letter of each word to match category format
          @category_in_data.each do |category|                # for each production category
            if company_name.include?(category)                # check the category against each word in the company name
              if category_slots.length < 4                    # if there is a match put it in a slot as long as there is room 
                category_slots.push(category)                 # keep this category which will become part of the record
                pushed = true                                 # this flag routes the record into production
              end                                             # end of if there is a match put it in a slot as long as there is room 
            end                                               # end of check for a match between the company name and the production category
          end                                                 # end of for each production category 
        line = format_for_output(master_in_data, category_slots)
        if pushed                                             # pushed ? @master_out.puts(line) : @no_category_out.puts(line)
          @master_out.puts(line)
          production_count +=1
        else
          @no_category_out.puts(line)
          rework_count += 1
        end
        pushed = false
        category_slots = []
      }
    }
    puts("Categories in production: " + @category_in_data.length().to_s)
    puts("Total records processed: " + processed_count.to_s)
    puts("Records pushed to production: " + production_count.to_s)
    puts("Records needing more attention: " + rework_count.to_s)
  end 
  
  def initialize_files()
    
    attr_accessor = :master_in_file, :category_in_data, :company_in_data, :master_out, :no_category_out, :audit_out, :sort_in, :sort_out
    
    @file_category_in = @category_in
    path_name = @file_category_in[0].fetch(:path)
    file_name = @file_category_in[0].fetch(:file)
    @category_in_data = Array.new
    category_in = path_name + "/" + file_name
    open( category_in ) { |record| 
      record.each_line { |line|
       @category_in_data.push(line.chomp)
      }
    }

    @file_company_in = @company_in
    path_name = @file_company_in[0].fetch(:path)
    file_name = @file_company_in[0].fetch(:file)
    @company_in_data = Array.new
    company_in = path_name + "/" + file_name
    open( company_in ) { |record| 
      record.each_line { |line| 
        @company_in_data.push(line.chomp)
      }
    }
    
    @file_master_out  = @master_out
    path_name         = @file_master_out[0].fetch(:path)
    file_name         = @file_master_out[0].fetch(:file)
    new_master_out    = path_name + "/" + file_name
    @master_out       = File.new(new_master_out, "w+")
    
    @file_no_category_out = @no_category_out
    path_name         = @file_no_category_out[0].fetch(:path)
    file_name         = @file_no_category_out[0].fetch(:file)
    no_category_out   = path_name + "/" + file_name
    @no_category_out   = File.new(no_category_out, "w+")
    
    @file_audit_out   = @audit_out
    path_name         = @file_audit_out[0].fetch(:path)
    file_name         = @file_audit_out[0].fetch(:file)
    new_audit_out     = path_name + "/" + file_name
    @audit_out        = File.new(new_audit_out, "w+")
  end
  
  def format_for_output(data, category_slots)
    # the product has 5 categories the first 2 are duplicates initially
    line = [category_slots[0], category_slots[0], category_slots[1], category_slots[2], category_slots[3],
      data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], 
      data[10], data[11], data[12], data[13], data[14], data[15], data[16], data[17], data[18],
      data[19], data[20], data[21], data[22], data[23]].join(",") 
    return line.chomp
  end
end 

class Sorter
  
  attr_accessor = :sort_in, :sort_out, :audit_out
  
  def initialize(setup)
    puts("Initializing sorter")
    @function         = setup[:function]
    @sort_in          = setup[:sort_in]
    @sort_out         = setup[:sort_out]
    @audit_out        = setup[:audit_out]
    initialize_files
  end
  
  def initialize_files()
    @file_audit_out   = @audit_out
    path_name         = @file_audit_out[0].fetch(:path)
    file_name         = @file_audit_out[0].fetch(:file)
    new_audit_out     = path_name + "/" + file_name
    @audit_out        = File.new(new_audit_out, "w+")
  
    @file_sort_in     = @sort_in
    path_name         = @file_sort_in[0].fetch(:path)
    file_name         = @file_sort_in[0].fetch(:file)
    @sort_in           = path_name + "/" + file_name
    
    @file_sort_out    = @sort_out
    path_name         = @file_sort_out[0].fetch(:path)
    file_name         = @file_sort_out[0].fetch(:file)
    new_sort_out      = path_name + "/" + file_name
    @sort_out          = File.new(new_sort_out, "w+")
  end
  
  def record_sorter()
    record_count = 0
    records = File.readlines(@sort_in).sort
    File.open(@sort_out,"w") do |file|
      record_count += 1
      file.puts records
    end
    puts("Records sorted: " + records.length.to_s)
  end
end

class Uri
  
  attr_accessor :uri_list, :file_list, :file_function  
  
  def initialize(setup)
    puts("Initializing uri")
    @function       = setup[:function]
    @category_out   = setup[:category_in]
    @company_in     = setup[:company_in]
    @master_in      = setup[:master_in]
    @master_out     = setup[:master_out]
    @nocategory_out = setup[:no_category_out]
    @audit_out      = setup[:audit_out]
  end
  
  def remote()
    @file_in = @master_in
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
 