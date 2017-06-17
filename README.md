#FilesMerger
***

FilesMerger is a Gem that facilitates the merger of _*.csv*_ and _*.txt*_ files, providing a simple way for doing so.

##With this gem you can:
***
* Set a new delimiter for the merged file;
* Set the complete path for each file or just the file names and an root diretory;
* Set a name for the final merged file;
* Sort the lines by an espeficic column;
* Eliminate duplicates chosing priority by order;
  * Soon you'll be able to eliminate all duplicates.
* Ensure that all the files have the same number of columns.

##Compatibility
***
Until now, no problems with any version of Ruby.

##Installation
***

**By Bundle**

Add this line of code to your Gemfile application:

`gem 'files_merger'`

Then execute:

`bundle`

**Manually**

Execute the following code:

`gem install files_merger`

##Usage
***

The FilesMerger is very simple to use, see:

First, you just need to decide if the parameters are going to be inputted via external file or code through the method **set_file_parameters**. It accepts two parameters:

* _option_
  * *true* if the parameters will be inputted from an external file;
  * *false* if not.
* _path_
  * the path to the external file.

**Example:**

`FilesMerger.set_file_parameters option: true, path: "parameters.rb"`

If any parameters are passed, the default is
`option: false, path: ""`

If the chosen option was *true*, the file must follow the example below:

`files = ['test1.csv', 'test2.csv']

delimiter 				";"
new_delimiter			" " #tab
files_to_merge    origin: "C:/Windows/User/Desktop/", files: files
#files_to_merge		origin: "C:/Windows/User/Desktop/", files: ['teste1.csv', 'teste1.csv']
final_file_name		"/Desktop/FINAL_FILE"
set_sort 				  option: true, column:"column_name"
elim_duplicity    option: true, key: "column_name", order: "fend"
limit_of_columns	true
file_extension		:csv`

But, if you are going to use via code, follow the example:

`FilesMerger.delimiter ";"
FilesMerger.new_delimiter "|"
FilesMerger.files_to_merge    origin: "C:/Windows/User/Desktop/", files: files
...`
or
`FilesMerger.delimiter(";")
...`

It's Ruby syntax. You decide.

After set the parameters, call the build mehod, responsable for all the magic.

`FilesMerger.build`

##Methods

These are the are the accepted methods, for now:

* **delimiter**
  * Set delimiter in the files to merge.
  * Examples of Values:
    * ";"
    * ","
    * " " or in code "\\t"- tab
    * "|"

Ex:
`FilesMerger.delimiter ","`

* **new_delimiter**
  * Set a new delimiter for the file after the merging;
  * If it's not used, the the delimiter will be the same used in the files.
  * Examples of Values:
    * ";"
    * ","
    * " " or in code "\\t"- tab
    * "|"

Ex:
  `FilesMerger.new_delimiter ";"`

* **files_to_merge**
  * Set the files to be merged;
  * Receives the an array with the names of all the files to be merged and the root folder of the files;
  * If all are in the same folder, you can just pass a root path and an array with just the names and extension of the files.

Ex:
  `files = ['teste1.csv', 'teste2.csv']

  FilesMerger.files_to_merge(origin: Dir.home() << "/Desktop/", files: files)`

  or

  `files = ['C:/Windows/User/Desktop/teste1.csv', 'C:/Windows/User/Desktop/teste2.csv']

  FilesMerger.files_to_merge(origin: "", files: files)`

* **final_file_name**
  * Set the name of the file resulted from the merging;
  * If not used, the default name will be _"MERGED_YYYYmmDDHHMM.csv"_ (or .txt);

* **set_sort**
  * Sorts the file lines;
  * The sorting will always be from up(smaller) to down(bigger);
  * If not used, nothing will be sorted.
  * parameters:
    * _option_ - if you want to sort the file lines;
      * values: *true* or *false*
    * _column_ - the column to be used as criterion for the sorting;

Ex:
  `FilesMerger.set_sort(option: true, column:"column_name")`

* **elim_duplicity**
  * Eliminates duplicated lines;
  * Parameters:
    * _option_ - if you want to eliminate duplicates;
      * Values: *true* or *false*.
    * _key_ - the main value to be used as criterion.
    * _order_ - the order used to go through the lines. If from above, the firt occurance will be kept, if from below, the last one will be kept. Pay attention if you used the sort option.
      * Values:
        * *fend* - from end.
        * *fstart* - from start.

Ex:
  `FilesMerger.elim_duplicity(option: true, key: "columns_name", order: "fend")`

* **limit_of_columns**
  * Determinates if all files must respect a limit of columns;
  * Parameters:
    * Values: _true_ or _false_;

Ex:
  `FilesMerger.limit_of_columns(true)`

* **file_extension**
  * Set the extension for the file resulted from the mergin;
  * Parameters:
    * Values: :csv or :txt.

Ex:
  `FilesMerger.file_extension(:csv)`
  or
  `FilesMerger.file_extension(:txt)`
