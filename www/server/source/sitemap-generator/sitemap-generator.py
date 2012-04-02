# -*- coding: utf-8 -*-
#
# Sitemap generator
# Copyright © 2011-2012 Wacław Jacek
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# ---------------------------------------------------------------------
#
# This program uses "Universal Encoding Detector", published under
# GNU Lesser General Public License version 2.1
# (see: python2-chardet/COPYING).

import chardet
import os
import re
import sys

CHARSET_REGEXP_CONTENT_PART = 'content=[\'"]text/html;\s*charset=(?P<encoding>.*?)[\'"]'
CHARSET_REGEXP_HTTP_EQUIV_PART = 'http-equiv=[\'"]?content-type[\'"]?'
DIRECTORIES_LINK_TO_THEIR_INDEX_FILES = True
FILENAMES_TO_LIST_REGEXP = '\.html$'
FORWARD_REGEXP = '<meta\s+http-equiv=[\'"]?refresh[\'"]?\s+content=[\'"]?[0-9]+;\s*url=.+[\'"]?>' # This is used to detect pages that are in fact forwards.
OUTPUT_FILE_NAME = 'sitemap.html'
TOP_LEVEL_LOCAL_DIRECTORY = '/home/w/wwj/www-repo'
TRANSLATION_REGEXP = '\.(?P<langcode>[a-z]{2}|[a-z]{2}-[a-z]{2})\.[^.]+$'
VALID_ENCODINGS = [ 'utf-8', 'iso-8859-2', 'big5', 'euc-kr', 'euc-jp', 'gb2312', 'iso8859-7' ] # in lowercase

# global variables
directories_ignored_in_double_index_file_checks_regexp_list = None
directories_to_print_regardless_of_emptiness_regexp_list = None
directories_to_skip_regexp_list = None
files_to_skip_regexp_list = None
output_file = None
regexps_to_remove_from_titles_list = None
replacement_titles_regexp_dict = None

# functions
def are_directory_and_subdirectories_empty( relative_path_to_directory ):
	directory_contents = get_directory_contents( relative_path_to_directory )
	files_names = directory_contents['files']
	subdirectories_names = directory_contents['subdirectories']
	
	if len( files_names ) != 0:
		return False
	elif len( subdirectories_names ) != 0:
		for subdirectory_name in subdirectories_names:
			if not are_directory_and_subdirectories_empty( os.path.join( relative_path_to_directory, subdirectory_name ) ):
				return False
	return True

def determine_file_encoding( filename ):
	file_contents = read_file( filename )
	match = re.search( '<meta\s*' + CHARSET_REGEXP_HTTP_EQUIV_PART + '\s*' + CHARSET_REGEXP_CONTENT_PART, file_contents, re.IGNORECASE )
	match2 = re.search( '<meta\s*' + CHARSET_REGEXP_CONTENT_PART + '\s*' + CHARSET_REGEXP_HTTP_EQUIV_PART, file_contents, re.IGNORECASE )
	if match:
		encoding = match.group( 'encoding' )
		if encoding.lower() in VALID_ENCODINGS:
			return encoding
	elif match2:
		encoding = match2.group( 'encoding' )
		if encoding.lower() in VALID_ENCODINGS:
			return encoding
	else:
		chardet_result = chardet.detect( file_contents )
		if chardet_result[ 'confidence' ] > 0.5:
			return chardet_result[ 'encoding' ]
	return None
	
def get_directory_contents( relative_path_to_directory ):
	list_of_files = []
	list_of_subdirectories = []

	for element_name in os.listdir( os.path.join( TOP_LEVEL_LOCAL_DIRECTORY, relative_path_to_directory ) ):
		relative_path_to_element = os.path.join( relative_path_to_directory, element_name )
		absolute_path_to_element = os.path.join( TOP_LEVEL_LOCAL_DIRECTORY, relative_path_to_element )

		if os.path.isdir( absolute_path_to_element ) and not search_string_using_regexp_list( relative_path_to_element, directories_to_skip_regexp_list ):
			list_of_subdirectories.append( element_name )
		elif re.search( FILENAMES_TO_LIST_REGEXP, element_name ) and not search_string_using_regexp_list( relative_path_to_element, files_to_skip_regexp_list ) and not is_file_a_translation( element_name ) and not is_file_a_redirect( relative_path_to_element ):
			list_of_files.append( element_name )
			
	return { 'files': list_of_files, 'subdirectories': list_of_subdirectories }
	
def get_index_filename( relative_path_to_directory ):
	# We only want either directoryname.html or index.html files. If both are present, don't use either, and output an error, so it can be resolved.
	directory_name = get_name_from_path( relative_path_to_directory )
	
	files_called_index = [ 'index.html', 'index.htm' ]
	files_called_directoryname = [ directory_name + '.html', directory_name + '.htm' ]
	files_in_directory = get_directory_contents( relative_path_to_directory )['files']
	
	file_called_index_filename = None
	file_called_directoryname_filename = None
	
	for filename in files_called_index:
		if filename in files_in_directory:
			file_called_index_filename = filename
			
	for filename in files_called_directoryname:
		if filename in files_in_directory:
			file_called_directoryname_filename = filename
			
	if file_called_index_filename and file_called_directoryname_filename:
		if not search_string_using_regexp_list( relative_path_to_directory, directories_ignored_in_double_index_file_checks_regexp_list ): # Only complain about duplicate index files if it isn't a deliberate instance of such.
			print 'Error: Directory ' + relative_path_to_directory + ' has both an index file called "' + file_called_index_filename +  '" and a directoryname file called "' + file_called_directoryname_filename + '". Neither will be used as main page.'
	elif file_called_index_filename:
		return file_called_index_filename
	elif file_called_directoryname_filename:
		return file_called_directoryname_filename
	return None

def get_name_from_path( path ):
	rightmost_slash_pos = path.rfind( '/' )
	if rightmost_slash_pos != -1:
		return path[ rightmost_slash_pos + 1 : ]
	return path
	
def get_replacement_titles_regexp_dict():
	nonsplitted_list = read_file( 'replacement_titles' ).splitlines()
	splitted_dict = {}
	
	# the variables below are used in looping
	regexp = None
	replacement_title = None
	
	for element in nonsplitted_list:
		if element != '':
			if regexp and replacement_title: # if we've already stored a title and a regexp, this is an invalid entry and all lines until '' should be ignored
				pass
			elif regexp: # if only have the regexp, this is the replacement title
				replacement_title = element
				splitted_dict[regexp] = replacement_title
			else:
				regexp = element
		else: # Empty item encountered. Reset.
			regexp = None
			replacement_title = None
			
	return splitted_dict
	
def get_separate_lists_of_files_and_subdirectories( directory_contents ):
	files_names = []
	subdirectories_names = []
	
	for element in directory_contents:
		if directory_contents[ element ] == None:
			files_names.append( element )
		else:
			subdirectories_names.append( element )
	
	return { 'files': files_names, 'subdirectories': subdirectories_names }
	
def get_titles_for_files( relative_path_to_directory, files_names ):
	files_titles = {}
	
	for filename in files_names:
		title = get_webpage_title_from_file( os.path.join( relative_path_to_directory, filename ) )
		if title:
			files_titles[ filename ] = title
		
	return files_titles
	
def get_webpage_title_from_file( relative_path_to_file ):
	# Before we will try to determine the actual title, check if it has to be overwritten.
	match = search_string_using_regexp_list( relative_path_to_file, replacement_titles_regexp_dict )
	if match:
		return replacement_titles_regexp_dict[match.re.pattern]
		
	# If it hasn't, do the things below.
	absolute_path_to_file = os.path.join( TOP_LEVEL_LOCAL_DIRECTORY, relative_path_to_file )

	the_file = open( absolute_path_to_file, 'r' )
	file_contents = the_file.read()
	the_file.close()
	
	title_tag_start = file_contents.lower().find( '<title>' )
	title_tag_end = file_contents.lower().find( '</title>' )

	if title_tag_start != -1 and title_tag_end != -1:
		title = file_contents[ ( title_tag_start + 7 ) : title_tag_end ].strip()
		if len( title ) != 0:
			for regexp in regexps_to_remove_from_titles_list:
				match = re.search( regexp, title )
				if match:
					title = title[ : match.start() ] + title[ match.end() : ]
			encoding = determine_file_encoding( absolute_path_to_file )
			if encoding:
				title = title.decode( encoding, 'replace' )
			else:
				title = title.decode( 'utf-8', 'replace' )
			return title
	return None
	
def is_file_a_redirect( relative_path_to_file ):
	file_contents = read_file( os.path.join( TOP_LEVEL_LOCAL_DIRECTORY, relative_path_to_file ) )

	if re.search( FORWARD_REGEXP, file_contents ):
		return True
		
	return False
	
def is_file_a_translation( filename ):
	if re.search( TRANSLATION_REGEXP, filename ):
		return True
	return False
	
def join_url_paths( *list_of_paths ):
	final_path = ''

	for path in list_of_paths:
		if len( path ) != 0:
			if final_path == '' or final_path[-1] == '/':
				final_path += path
			else:
				final_path += '/' + path
		
	return final_path
	
def print_list_of_links_to_subdirectories( relative_path_to_directory, subdirectories_names ):
	write( '<div>[top-level directories:' )
	for subdirectory in sorted( subdirectories_names, key = str.lower ):
		if not are_directory_and_subdirectories_empty( os.path.join( relative_path_to_directory, subdirectory ) ):
			write( ' <a href="#directory-' + os.path.join( relative_path_to_directory, subdirectory ).replace( '/', '-' ) + '">' + subdirectory + '</a>' )
	write( ']</div>\n\n' )
	
def print_map_of_directory( relative_path_to_directory, depth_level ):
	directory_name = get_name_from_path( relative_path_to_directory )
	
	# get lists of directory contents
	directory_contents = get_directory_contents( relative_path_to_directory )
	files_names = directory_contents['files']
	subdirectories_names = directory_contents['subdirectories']
	
	if not are_directory_and_subdirectories_empty( relative_path_to_directory ) or search_string_using_regexp_list( relative_path_to_directory, directories_to_print_regardless_of_emptiness_regexp_list ): # print directories only if they have anything in them
		# get titles to print as labels
		files_titles = get_titles_for_files( relative_path_to_directory, files_names )
		
		# only print a <hr /> above top-level subdirectories
		if depth_level == 1:
			write( '\n<hr />\n' )
	
		write( '\n<div' )
		if relative_path_to_directory != '':
			write( ' id="directory-' + relative_path_to_directory.replace( '/', '-' ) + '"' )
		write( ' class="sitemap-directory sitemap-directory-depth-' + str( depth_level ) + '">' )

		# print a header (but only if it's not the top level directory)
		if depth_level != 0:
			index_file = get_index_filename( relative_path_to_directory ) if DIRECTORIES_LINK_TO_THEIR_INDEX_FILES else None
			
			write( '\n<div class="sitemap-header"><a href="/' + relative_path_to_directory + '/' )
			if index_file:
				write( index_file )
			write( '">' + relative_path_to_directory )
			if index_file and ( index_file in files_titles ):
				write( ' - ' + files_titles[ index_file ] )
			write( '</a></div>\n' )
			
			if index_file: # don't list the index file in the filelist now.
				files_names.remove( index_file )
			
		if depth_level == 0: # print "#links" to subdirectories if it's the top level directory
			print_list_of_links_to_subdirectories( relative_path_to_directory, subdirectories_names )

		# print a list of files
		if len( files_names ) != 0:
			write( '<ul>\n' )
			for filename in sorted( files_names, key = str.lower ):
				if filename in files_titles:
					title = files_titles[ filename ]
				else:
					title = None
				write( '  <li><a href="/' + join_url_paths( relative_path_to_directory, filename ) + '">' + filename + ( ( ' - ' + title ) if title else '' ) + '</a></li>\n' )
			write( '</ul>\n' )

		# print subdirectories as blocks
		if len( subdirectories_names ) != 0:
			for subdir_name in sorted( subdirectories_names, key = str.lower ):
				print_map_of_directory( os.path.join( relative_path_to_directory, subdir_name ), depth_level + 1 )
		
		# print another list of links to top level dirs
		if depth_level == 0:
			write( '\n<hr />\n' )
			print_list_of_links_to_subdirectories( relative_path_to_directory, subdirectories_names )
			
		write( '</div>\n' )
		
def read_file( filename ):
	fd = open( filename, 'r' )
	file_contents = fd.read()
	fd.close()
	
	return file_contents
	
def replace_space_with_whitespace_in_regexp_list( regexp_list ):
	new_regexp_list = []
	
	for regexp in regexp_list:
		new_regexp_list.append( regexp.replace( ' ', '\s+' ) )
	
	return new_regexp_list
		
def search_string_using_regexp_list( string, regexp_list, search_mode = 'first match only' ):
	if search_mode == 'list of matches': # returns empty list if no matches
		list_of_matches = []
		for regexp in regexp_list:
			match = re.search( regexp, string )
			if match:
				list_of_matches.append( match )
		return list_of_matches
	else:
		for regexp in regexp_list: # returns None if no matches
			match = re.search( regexp, string )
			if match:
				return match
		return None
	
def write( message ):
	output_file.write( message.encode( 'utf-8' ) )

# main program here
output_file = open( OUTPUT_FILE_NAME, 'w' )

directories_ignored_in_double_index_file_checks_regexp_list = read_file( 'directories_ignored_in_double_index_file_checks' ).splitlines()
directories_to_print_regardless_of_emptiness_regexp_list = read_file( 'directories_to_print_regardless_of_emptiness' ).splitlines()
directories_to_skip_regexp_list = read_file( 'directories_to_skip' ).splitlines()
files_to_skip_regexp_list = read_file( 'files_to_skip' ).splitlines()
regexps_to_remove_from_titles_list = replace_space_with_whitespace_in_regexp_list( read_file( 'regexps_removed_from_titles' ).splitlines() )
replacement_titles_regexp_dict = get_replacement_titles_regexp_dict()

write( read_file( 'output.head' ) )
print_map_of_directory( '', 0 )
write( read_file( 'output.tail' ) )

output_file.close()

