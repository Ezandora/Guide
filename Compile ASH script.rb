#!/usr/bin/env ruby

# Compile ASH script.rb
# This script is in the public domain.
# Compiles a collection of KoLMafia ASH scripts into one script, for distribution.
# This isn't particularly robust.
# Notable errors:
# This script might miss import statements, and will import import statements that are commented out.
# It will also not work on scripts outside of the KoLMafia directory that use absolute paths (relay/, scripts/)
# And it won't understand certain aspects of KoLMafia's internal import mechanics.
# Sorry!

def readFileContentsAtPath(file_path)
	begin
		return File.read(file_path)
	rescue
		return ''
	end
end

def writeFileContentsAtPath(file_path, contents)
	File.write(file_path, contents)
end

# This is OS dependent. We need to know the base mafia directory, for relay/ and scripts/ paths.
# So, we guess from the path we're given:
def findPathOfSuperdirectory(file_path, directory_name)
	file_dir = File.dirname(file_path)
	if file_dir == file_path # reached base
		return ''
	elsif File.basename(file_dir) == directory_name # found it
		return file_dir
	else # go up one
		return findPathOfSuperdirectory(file_dir, directory_name)
	end
end

def compileFile(file_path, seen_file_paths, root_directory)
	file_path = File.absolute_path(file_path) # Eliminate ../ from paths, for our already-imported check
	
	if seen_file_paths.include?(file_path) # already imported.
		return ''
	end
	seen_file_paths << file_path
	file_dir = File.dirname(file_path)
	file_contents = readFileContentsAtPath(file_path)
	if file_contents == ''
		return ''
	end
	
	result_lines = []
	file_lines = file_contents.split("\n")
	for line in file_lines
		if (not line.start_with?('import '))
			result_lines << line
		else
			matches = line.match('import "([^"]*)"')
			if (matches != nil)
				importing_file = matches[1]
				if (importing_file.start_with?('relay/') or importing_file.start_with?('scripts/')) #assume absolute paths
					if (root_directory.empty?)
						puts "Absolute path found, halting compilation."
						exit(1)
					end
					importing_path = File.join(root_directory, importing_file)
				else
					importing_path = File.join(file_dir, importing_file)
				end
				result_lines << compileFile(importing_path, seen_file_paths, root_directory)
			end
		end
	end
	return result_lines.join("\n")
end

def main(arguments)
	if arguments.length < 1
		puts 'Usage: ' + $0 + ' input_file_path [output_file_path]'
		puts 'If no output file path is provided, results will be written to "Compiled [input_file_path]"'
		return
	end
	input_file_path = arguments[0]
	output_file_path = ''
	if arguments.length > 1
		output_file_path = arguments[1]
	else
		output_file_path = 'Compiled ' + File.basename(input_file_path)
	end
	root_directory = File.join(__dir__, 'Source')
	compilation = compileFile(input_file_path, [], root_directory)
	if (not compilation.empty?)
		puts 'Writing compiled "' + input_file_path + '" to "' + output_file_path + '"'
		writeFileContentsAtPath(output_file_path, compilation)
	else
		puts 'Empty or missing file, writing nothing.'
	end
end

if __FILE__ == $0
	main(ARGV)
end
