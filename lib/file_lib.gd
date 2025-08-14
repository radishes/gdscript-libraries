class_name FileLib extends Node
## Static helper methods for working with files.


## Save [param content] to a file at [param path].
static func save_file(path:String, content):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file.is_open():
		file.store_string(content)
		file.close()
	else:
		print("Error writing to file: '{0}'!".format([path]))


## Load the file at [param path] and return its content.
static func load_file(path:String):
	if not FileAccess.file_exists(path):
		print("ERROR: File not found: {0}".format([path]))
		print_stack()
		return
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return content


## Load a file containing JSON data and return the parsed contents.
static func load_json(path:String):
	var json = JSON.new()
	if json.parse(load_file(path)) == 0:
		return json.get_data()


## Create a directory at [param path].
static func create_dir(path:String) -> void:
	var dir = DirAccess.open(path)
	if not dir.dir_exists(path):
		dir.make_dir_recursive(path)


## Return the final part of [param path], either a filename or the deepest nested
## directory. If [param strip_extension] is true, then strip the final `.` character and 
## anything following it from the result.
## Example: `get_basename("res://my_dir/my_file.cool", true)` returns `my_file`.
static func get_basename(path:String, strip_extension:=false) -> String:
	var basename = path.rsplit("/")[-1]
	if strip_extension:
		basename = basename.split(".")[0]
	return basename


## A crude method for combining path parts into a single path.
static func make_path(paths_list:Array) -> String:
	var sep = "/"
	var path = ""
	for p in paths_list:
		var p2 = p.lstrip(sep).rstrip(sep)
		path = "{0}{1}{2}".format([path, sep if (path and p2) else "", p2])
	return path


## Provided a path to a file containing CSV data, run `FileAccess.get_csv_line()` on each 
## line and return the processed lines of the file as an Array.
static func get_csv_lines(file_path:String, header:=true) -> Array:
	var lines = []
	if not FileAccess.file_exists(file_path):
		print("File not found: {0}".format([file_path]))
		return []
	var file = FileAccess.open(file_path, FileAccess.READ)
	if header:
		file.get_line()  # Discard header line.
	while !(file.eof_reached()):
		var line = file.get_csv_line()
		# File.get_csv_line() returns truthy value [""] on a blank line in the file. Check more explicitly.
		if len(line) > 1 or (len(line) == 1 and line[0]):
			lines.append(line)
	file.close()
	return lines


## Return a list of the names of all the files in [param path]. If [parameter ending_filter] 
## is provided, then only filenames which end with the provided filter string are included in the list.
## This allows filtering by file extension, i.e. ending filter of `".tscn"` will return all .tscn 
## files in the provided path.
static func list_files_in_directory(path:String, ending_filter:="") -> Array:
	var files = []
	var dir = DirAccess.open(path)
	DirAccess.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with(ending_filter):
			files.append(file)
	dir.list_dir_end()
	return files
