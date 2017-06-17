files = ['teste1.csv', 'teste2.csv']

delimiter 				"|"
new_delimiter			";"
files_to_merge		origin: Dir.home() << "/Desktop/", files: files
final_file_name		"FINAL_FILE"
set_sort 				  option: true, column:"column_name"
elim_duplicity		option: true, key: "column_name", order: "fend" #:fend or :fstart
limit_of_columns	true
file_extension		:csv #:txt or :csv
