# -*- coding: utf-8 -*-
#
# LINC - LINC Is Not Checklink
# Copyright © 2011 Wacław Jacek
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

# defines

BASE_DIRECTORY = '/home/w/wwj/www-repo/'
REMOTE_BASE_DIRECTORY = 'http://www.gnu.org/'

ADDITIONAL_HTTP_HEADERS = 'User-Agent: LINC/alpha\r\nAccept: text/html, text/plain, audio/mod, image/*, application/msword, application/pdf, application/postscript, text/sgml, video/mpeg, */*;q=0.01\r\n' # end every header with "\r\n"
DELAY_BETWEEN_CHECKS = 1 # In seconds. Set to 0 to disable delay between checks of different links.
DELAY_BETWEEN_RETRIES = 10 # In seconds. Used when a link fails before re-checking it. Set to 0 to disable delays.
FORWARDS_TO_FOLLOW = 5 # How many forwards should be followed.
NUMBER_OF_ATTEMPTS = 3 # Number of times to check a link for error. If an attempt is successful, the link is no longer checked during that program run.
REPORT_FILE_NAME = 'reports-temp/broken_links' # Path to the file to which the errors will be reported.
SEPARATE_TRANSLATION_REPORTS = True # If you set this to True, reports for translations will be saved into "REPORT_FILE_NAME.lang" instead of in the main report file.
SKIP_TRANSLATION_FILES = False # If you set this to True, files with translations will be skipped.
SOCKET_TIMEOUT = 20 # After what time to give up with trying to retrieve a website.

# regexp-related defines

EXCLUDED_DIRECTORIES_REGEXP = '^(japan|wwwes|wwwin|education/fr|software/[^/]+)$' # Matching directories will not be entered to check their files or subdirectories.
FILENAMES_TO_CHECK_REGEXP = '\.html$' # Only matching files will be checked.
FTP_LINK_REGEXP = 'ftp://(?P<hostname>[^/:]+)(:(?P<port>[0-9]+))?'
HTTP_ERROR_HEADER = '^HTTP/1\.1 (?P<http_error_code>403|404) ' # What to treat as a HTTP error header.
HTTP_FORWARD_HEADER = '^HTTP/1\.1 (301 Moved Permanently|302 Found)$'
HTTP_LINK_REGEXP = 'http://(?P<hostname>[^/:]+)(:(?P<port>[0-9]+))?(?P<resource>/[^#]*)?'
HTTP_NEW_LOCATION_HEADER = '^Location: (?P<new_location>.+)$'
LINK_REGEXP = '<a( .+?)? href="(?P<link>[^mailto:].+?)"( .+?)?>'
TRANSLATION_REGEXP = '\.(?P<langcode>[a-z]{2}|[a-z]{2}-[a-z]{2})\.[^.]+$'

# libraries

import os
import re
import socket
import sys
import time

# global variables

files_to_check = []

# functions
	
def format_error( filename, line_number, link, error_message ):
	return str( filename ) + ':' + str( line_number ) + ': ' + str( link ).replace( ' ', '%20' ) + ' ' + str( error_message ) + '\n'
	
def get_ftp_link_error( link ):
	connection_data = re.search( FTP_LINK_REGEXP, link )
	if connection_data:
		hostname = connection_data.group( 'hostname' )
		port = connection_data.group( 'port' )
		
		if port == None:
			port = 21
			
		socketfd = socket_create()
		if socketfd == None: # if a socket couldn't be created, just ignore this link this time.
			return None
			
		if socket_connect( socketfd, hostname, port ) == False:
			socketfd.close()
			return 'couldn\'t connect to host'
			
		socketfd.close()
	return None

def get_http_link_error( link, forwarded_from = None ): # forwarded_from is either None or a list
	if forwarded_from == None:
		forwarded_from = []

	connection_data = re.search( HTTP_LINK_REGEXP, link )
	if connection_data:
		hostname = connection_data.group( 'hostname' )
		port = connection_data.group( 'port' )
		resource = connection_data.group( 'resource' )
		
		if port == None:
			port = 80
			
		socketfd = socket_create()
		if socketfd == None: # if a socket couldn't be created, just ignore this link this time.
			return None
		
		if socket_connect( socketfd, hostname, port ) == False:
			socketfd.close()
			return 'couldn\'t connect to host'

		if resource == None:
			resource = '/'

		socketfd.send( 'GET ' + resource + ' HTTP/1.1\r\nHost: ' + hostname + '\r\n' + ADDITIONAL_HTTP_HEADERS + '\r\n' )
		
		webpage = socket_read( socketfd )
		if webpage == None:
			socketfd.close()
			return 'couldn\'t read from socket'
		
		socketfd.close()
		
		end_of_headers_pos = webpage.find( '\r\n\r\n' )
		if end_of_headers_pos == -1:
			return 'couldn\'t find end of headers (possibly no content in file)'
			
		header_lines = webpage[ : end_of_headers_pos ]
		header_lines = header_lines.split( '\r\n' )
		
		# search for errors
		match = regexp_search_list( HTTP_ERROR_HEADER, header_lines )
		if match:
			http_error_code = match.group( 'http_error_code' )
			return 'http error ' + http_error_code + ' returned by server'
			
		# look for forwards
		match = regexp_search_list( HTTP_FORWARD_HEADER, header_lines )
		if match:
			if len( forwarded_from ) < FORWARDS_TO_FOLLOW: # if we haven't been forwarded too many times yet...
				match = regexp_search_list( HTTP_NEW_LOCATION_HEADER, header_lines )
				if match:
					forwarded_from.append( link )
					new_location = match.group( 'new_location' )
					if new_location in forwarded_from:
						return 'forward loop!'
					else:
						return get_http_link_error( new_location, forwarded_from )
			else: # we've been forwarded too many times, sorry.
				return 'too many forwards (over ' + str( len( forwarded_from ) ) + ')'

	return None
	
def is_match_inside_comment_block( regexp_match ):
	haystack = regexp_match.string
	match_pos = regexp_match.start()
	comment_block_start = haystack.rfind( '<!--', 0, match_pos )
	comment_block_end = haystack.rfind( '-->', 0, match_pos )
	if comment_block_start > comment_block_end:
		return True
	return False

def regexp_search_list( regexp, the_list ):
	for list_element in the_list:
		match = re.search( regexp, list_element )
		if match:
			return match
	return None

def search_directory_for_files( base_directory, directory ):
	for element_name in os.listdir( os.path.join( base_directory, directory ) ):
		relative_path_to_element = os.path.join( directory, element_name )
		full_path_to_element = os.path.join( base_directory, relative_path_to_element )
		if os.path.isdir( full_path_to_element ):
			if re.search( EXCLUDED_DIRECTORIES_REGEXP, relative_path_to_element ):
				continue
				
			search_directory_for_files( base_directory, relative_path_to_element )
		else:
			if not re.search( FILENAMES_TO_CHECK_REGEXP, element_name ):
				continue
		
			if ( SKIP_TRANSLATION_FILES == True ) and re.search( TRANSLATION_REGEXP, element_name ):
				continue
			
			files_to_check.append( relative_path_to_element )
				
def socket_connect( socketfd, hostname, port ):
	try:
		socketfd.connect( ( hostname, int( port ) ) )
	except socket.error, message:
		return False
	return True

def socket_create():
	try:
		socketfd = socket.socket( socket.AF_INET, socket.SOCK_STREAM )
		socketfd.settimeout( SOCKET_TIMEOUT )
	except socket.error, message:
		return None
	return socketfd
	
def socket_read( socketfd ):
	output = ''
	try:
		output = socketfd.recv( 2048 )
	except socket.error, message:
		return None
	return output

### OK, main program below.
	
base_directory = BASE_DIRECTORY
remote_base_directory = REMOTE_BASE_DIRECTORY
if remote_base_directory[-1] != '/':
	remote_base_directory += '/'
	
remote_site_root = remote_base_directory[ : ( remote_base_directory.find( '/', ( remote_base_directory.find( '://' ) + 3 ) ) + 1 ) ]

# `cd` to this path
if not os.path.isdir( base_directory ):
	print 'Entered base directory isn\'t a directory (or doesn\'t exist at all).'
	sys.exit( 1 )

# list files
print 'Recursively listing all files in the selected directory...'
search_directory_for_files( base_directory, '' )

# find links
links_to_check = []
print 'Listing files done. Looking for links...'
for file_to_check in files_to_check:
	path_to_file = os.path.join( base_directory, file_to_check )
	fd = open( path_to_file, 'r' )
	file_contents = fd.read()
	fd.close()

	for match in re.finditer( LINK_REGEXP, file_contents ):
		link = match.group( 'link' )
		
		line_number = -1
		split_file_contents = file_contents.split( '\n' )
		for checked_line_number, line in enumerate( split_file_contents ):
			checked_line_number += 1 # so that line numbers don't start from 0
			if line.find( link ) != -1:
				line_number = checked_line_number
				break
		
		link_container = { 'filename': file_to_check, 'line_number': line_number, 'link': link, 'is_link_inside_comment_block': is_match_inside_comment_block( match ) }
		links_to_check.append( link_container )

# check links
print 'Alright, I\'ve got all the links. Let\'s check them now!'

# open report files for writing
report_file = open( REPORT_FILE_NAME, 'w' )
translation_report_files = {}

number_of_links_to_check = str( len( links_to_check ) )
already_checked_links = []
for i, link_container in enumerate( links_to_check ):
	if i % 10 == 0:
		print '\rChecking link ' + str( i + 1 ) + ' of ' + number_of_links_to_check + '...',
		sys.stdout.flush()

	filename = link_container['filename']
	line_number = link_container['line_number']
	link = link_container['link']
	is_link_inside_comment_block = link_container['is_link_inside_comment_block']

	link_type = None

	if link[:6] == 'ftp://':
		link_type = 'ftp'
	elif link[:7] == 'http://':
		link_type = 'http'
	elif link[:8] == 'https://':
		link_type = 'https'
	else:
		if link[0] == '#':
			continue
		elif link[0] == '/':
			link_type = 'http'
			link = remote_site_root + link[1:]
		else:
			link_type = 'http'
			
			last_slash_pos = filename.rfind( '/' )
			subdirectory = ''
			if last_slash_pos != -1:
				subdirectory = filename[ : last_slash_pos ] + '/'
				
			link = remote_base_directory + subdirectory + link
			
	link_already_checked = False
	link_id_if_already_checked = -1
	for i, already_checked_link in enumerate( already_checked_links ):
		if link == already_checked_link['link']:
			link_already_checked = True
			link_id_if_already_checked = i
			break
			
	if link_already_checked:
		link_error = already_checked_links[link_id_if_already_checked]['error']
	else:
		link_error = None
		for i in range( NUMBER_OF_ATTEMPTS ):
			if link_type == 'ftp':
				link_error = get_ftp_link_error( link )
				if link_error == None:
					break
			elif link_type == 'http':
				link_error = get_http_link_error( link )
				if link_error == None:
					break
			else:
				break # ignore the link, since its protocol is unsupported
			
			if DELAY_BETWEEN_RETRIES != 0:
				time.sleep( DELAY_BETWEEN_RETRIES )
				
		already_checked_links.append( { 'link': link, 'error': link_error } )
		
	if link_error != None:
		if is_link_inside_comment_block:
			link_error += ' (link commented out)'
	
		if not SKIP_TRANSLATION_FILES:
			match = re.search( TRANSLATION_REGEXP, filename )
			if match and SEPARATE_TRANSLATION_REPORTS:
				langcode = match.group( 'langcode' )
				if langcode not in translation_report_files:
					translation_report_files[langcode] = open( REPORT_FILE_NAME + '-' + langcode, 'w' )
				translation_report_files[langcode].write( format_error( filename, line_number, link, link_error ) )
			else:
				report_file.write( format_error( filename, line_number, link, link_error ) )
		else:
			report_file.write( format_error( filename, line_number, link, link_error ) )
	
	if DELAY_BETWEEN_CHECKS != 0:
		time.sleep( DELAY_BETWEEN_CHECKS )
		
for langcode in translation_report_files:
	translation_report_files[langcode].close()
report_file.close()

print '\nDone! :-)'

