module FilesMerger

	@limit_of_columns = false
	@final_file_name = ""
	@files_to_merge = {origin: "", files: {}}
	@imported_files = {}
	@files_origin = ""
	@header_read = true
	@final_file = []
	@first_line = ""
	@delimiter = ";"
	@new_delimiter = ""
	@columns = {option: true, columns: []}
	@sort_by = {option: false, column: ""}
	#order: "fstart" or "fend"
	@eliminate_duplicity = {option: false, key: "", order: "fstart"}
	@file_parameters = {option: false, path: ""}
	@file_extension = :csv

	private
	class Line

		attr_accessor :columns

		def add_columns_and_values columns, values

			@columns = {}
			if columns.length != values.length
				raise "The quantity of columns and values must to be the same."
			end

			for i in 0...columns.length
				@columns[columns[i].to_sym] = values[i].chomp
			end
		end

		def get_value_from_col column
			@columns[column.to_sym]
		end

		def get_line delimiter
			line = ""
			@columns.each do |key, value|
				line << "#{value}#{delimiter}"
			end

			line[0...line.length-1]
		end

		def print_line
			line = ""
			@columns.each do |key, value|
				line << "#{value};"
			end
			puts line
		end
	end

	public
	def self.set_file_parameters args
		@file_parameters[:option] = args[:option]
		@file_parameters[:path] = args[:path]
	end

	#set file final file extension
	public
	def self.file_extension value
		if value == :csv or value == :txt
			@file_extension = value
		else
			raise "The parameter must be a :csv or :txt."
		end
	end

	#set the rule for input parameters
	public
	def self.final_file_name file_name
		@final_file_name = file_name
	end

	#set the option for duplicity
	public
	def self.elim_duplicity args
		@eliminate_duplicity[:option] = args[:option]
		@eliminate_duplicity[:key] = args[:key]
		@eliminate_duplicity[:order] = args[:order]
	end

	#set the delimiter
	public
	def self.delimiter char
		if char != "" and char
			@delimiter = char
		else
			raise 'Invalid value for delimiter!'
		end
	end

	#set a new delimiter for the final file
	public
	def self.new_delimiter char
		if char != "" and char
			@new_delimiter = char
		else
			raise 'Invalid value for the new delimiter!'
		end
	end

	#set option for sorting
	public
	def self.set_sort args
		@sort_by[:option] = args[:option]
		@sort_by[:column] = args[:column]
	end

	public
	def self.limit_of_columns option
		@limit_of_columns = option
	end

	public
	def self.add_columns args
		@columns[:option] = args[:option]
		@columns[:columns] = args[:columns]
	end

	#add files to be merged
	#args :file is an array, but @files_to_merge :file is a hash
	public
	def self.files_to_merge args
		if args[:origin] != ""
			@files_to_merge[:origin] = args[:origin]
		end

		for i in 0...args[:files].length

			temp = args[:files][i]

			if !File.exist?(@files_to_merge[:origin] + temp)
				temp = args[:origin] << temp
				raise "The file #{temp} doesn't exist."
			end

			file_name = File.basename(temp)
			@files_to_merge[:files][file_name.to_sym] = args[:origin] + temp
			@imported_files[file_name.to_sym] = nil
		end
	end

	#import all the lines from the files to the respective arrays
	private
	def import_files
		read_header = true
		#each file
		@files_to_merge[:files].each do |key, value|

			#each line of files
			imported_lines = Array.new
			File.open(value, "r").each do |line|

				if !read_header

					if line != "" and line != nil
						file_line = Line.new
						file_line.add_columns_and_values(@columns[:columns], line.chomp.split(@delimiter))
						#check the rule for limit of lines
						if @limit_of_columns
							if @columns[:columns].length != file_line.columns.length
								raise "All files to merge must have the same number of columns."
							end
						end
						imported_lines << file_line
					end
				else
					if @columns[:option]
						@columns[:columns] = line.chomp.split(@delimiter)
						if @columns[:columns].length == 1
							puts "Only 1 column found. If it's not right, check the delimiter and the new one (if setted)."
						end
					end
					read_header = false
				end
			end

			@imported_files[key] = imported_lines
			read_header = true
		end
	end

	#merge all the files
	private
	def merge_files
		import_files()

		#verify the rule for limit of lines
		if @respect_limit_of_lines

			k = @imported_files.keys[0]
			lines = @imported_files[k].length

			@imported_files.each do |key, value|
				if value.length != lines
					return "The quantity of columns must to be the same for each file."
				end
			end
		end

		#merge
		@imported_files.each do |key, value|
			for i in 0...value.length
				@final_file << value[i]
			end
		end

		return @final_file
	end

	private
	def print_final_file array
		if @has_header
			header = ""
			for i in 0...@columns.length
				header << "#{@columns[i]};"
			end
			puts header
		end

		line = Line.new

		for i in 0...array.length
			line = array[i]
			line.print_line
		end
	end

	private
	def merge_sort array

		def merge(left_sorted, right_sorted)
			res = []
			l = 0
			r = 0

			loop do
				break if r >= right_sorted.length and l >= left_sorted.length

				if r >= right_sorted.length or (l < left_sorted.length and left_sorted[l][left_sorted[l].length-7...left_sorted[l].length].to_s < right_sorted[r][right_sorted[r].length-7...right_sorted[r].length].to_s)
					res << left_sorted[l]
					l += 1
				else
					res << right_sorted[r]
					r += 1
				end
			end

			return res
		end

		def mergesort_iter(array_sliced)
			return array_sliced if array_sliced.length <= 1

			mid = array_sliced.length/2 - 1
			left_sorted = mergesort_iter(array_sliced[0..mid])
			right_sorted = mergesort_iter(array_sliced[mid+1..-1])

			return merge(left_sorted, right_sorted)
		end

		mergesort_iter(array)
	end

	private
	def sort_by_col
		array_temp = []

		for i in 0...@final_file.length

			line = @final_file[i]
			column_value = line.get_value_from_col(@sort_by[:column])
			array_temp << "#{i}@#{column_value}"

		end

		array_temp = merge_sort array_temp
		array_aux = []

		array_temp.each do |element|

			char_index = element.index("@").to_i
			element_index = element[0...char_index].to_i
			array_aux << @final_file[element_index]

		end

		return array_aux
	end

	private
	def eliminate_duplicity

		def migrate_indexes from, teller

			to = []

			for i in 0...teller.length
				to << from[teller[i]]
			end

			return to
		end

		indexes =[]
		aux_key =[]

		case @eliminate_duplicity[:order]
		when "fend"

			cursor = @final_file.length-1
			while cursor > -1 do
				current_value = @final_file[cursor].get_value_from_col(@eliminate_duplicity[:key])

				if !aux_key.include?(current_value)
					indexes << cursor
					aux_key << current_value
				end

				cursor -= 1
			end

			@final_file = migrate_indexes(@final_file, indexes)

		when "fstart"

			cursor = 0
			while cursor > @final_file.length-1 do
				current_value = @final_file[cursor].get_value_from_col(@eliminate_duplicity[:key])

				if !find(aux_key, current_value)
					indexes << cursor
					aux_key << current_value
				end

				cursor += 1
			end

			@final_file = migrate_indexes(@final_file, indexes)
		end
	end

	private
	def prepare_parameters
		if @file_parameters[:option]
			if File.exist?(@file_parameters[:path])
				file = File.open(@file_parameters[:path]).read
				eval(file)
			else
				raise "ERROR: The file source for parameters doesn't exist."
			end
		end
	end

	private
	def self.build

		prepare_parameters()

		merge_files()

		if @sort_by[:option]
			if @sort_by[:column] == "" or !@columns[:columns].include?(@sort_by[:column])
				raise "Invalid column for the sorting."
			else
				@final_file = sort_by_col
			end
		end

		if @eliminate_duplicity[:option]
			if @eliminate_duplicity[:key] == "" or @eliminate_duplicity[:order] == ""
				raise "Invalid option for eliminate duplicity."
			else
				eliminate_duplicity
			end
		end

		now = Time.now.strftime("%Y%m%d_%H%M%S")
		if @final_file_name != ""
			if File.exist?(@final_file_name + @file_extension.to_s())
				@final_file_name = "#{@final_file_name}_#{now}.#{@file_extension.to_s()}"
			else
				@final_file_name = "#{@final_file_name}_#{now}.#{@file_extension.to_s()}"
			end
		else
			@final_file_name = "MERGED_#{now}.#{@file_extension.to_s()}"
		end

		if @new_delimiter == "" or !@new_delimiter
			@new_delimiter = @delimiter
		end

		#create the file and write the header
		File.open(@final_file_name, "w") do |file|
			file.write @columns[:columns].join(@new_delimiter) + "\n"
		end

		#append the lines to the file
		File.open(@final_file_name, "a") do |file|

			if @eliminate_duplicity[:option] and @eliminate_duplicity[:order] == "fend" and @final_file.length >= 0

				(@final_file.length-1).downto(0) do |i|
					file.write @final_file[i].get_line(@new_delimiter) + "\n"
				end
			else

				for i in 0...@final_file.length
					file.write @final_file[i].get_line(@new_delimiter) + "\n"
				end
			end

			puts "File created at #{@final_file_name}"
		end
	end
end
