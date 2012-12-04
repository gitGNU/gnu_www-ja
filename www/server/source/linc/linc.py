# -*- coding: utf-8 -*-
#
# LINC - LINC Is Not Checklink
# Copyright © 2011-2012 Wacław Jacek
# Copyright © 2012 Free Software Foundation, Inc.
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

BASE_DIRECTORY = '/home/g/gnun/checkouts/www/'
REMOTE_BASE_DIRECTORY = 'http://www.gnu.org/'

# End every header with "\r\n"
# We say we are like Lynx because some ignorant sites like Sourceforge don't
# know what LINC/alpha is and still discriminate on User-Agent with the default
# behavior being inappropriate for us.
ADDITIONAL_HTTP_HEADERS = 'User-Agent: Lynx/2.8.6rel.5\r\n\
Accept: text/html, text/plain, audio/mod, image/*, application/msword, \
application/pdf, application/postscript, text/sgml, video/mpeg, */*;q=0.01\r\n'

# In seconds. Set negative to disable delay between checks of different links.
DELAY_BETWEEN_CHECKS = 1

# In seconds. Used when a link fails before re-checking it.
# Set negative to disable delays.
DELAY_BETWEEN_RETRIES = 10

FORWARDS_TO_FOLLOW = 5 # How many forwards should be followed.

# Number of times to check a link for error. If an attempt is successful,
# the link is no longer checked during that program run.
NUMBER_OF_ATTEMPTS = 3

# Path to the file to which the errors will be reported.
# Note: this is typically a temporary directory because
# linc run takes many hours (almost a day), and the old results
# wouldn't be available during that period if new files went
# directly to the destination directory.
REPORT_FILE_PREFIX = 'reports-temp'

# File to which the errors will be reported.
REPORT_FILE_NAME = 'broken_links'

# File to which commented out links will be reported.
COMMENTED_FILE_NAME = 'commented_out'

# If you set this to True, files with translations will be skipped.
SKIP_TRANSLATION_FILES = False

# After what time to give up with trying to retrieve a website.
SOCKET_TIMEOUT = 20

# regexp-related defines

# Matching directories will not be entered to check their
# files or subdirectories.
EXCLUDED_DIRECTORIES_REGEXP = '^(japan|wwwes|wwwin|education/fr|\
education/draft|press|server/staging|software/[^/]+)$|(^|/)po$'
EXCLUDED_FILENAMES_REGEXP = \
  '^server/standards/boilerplate\.html|server/.*whatsnew\.html$'

FILENAMES_TO_CHECK_REGEXP = '\.html$' # Only matching files will be checked.

FTP_LINK_REGEXP = 'ftp://(?P<hostname>[^/:]+)(:(?P<port>[0-9]+))?'

# What to treat as a HTTP error header.
HTTP_ERROR_HEADER = '^HTTP/1\.1 (?P<http_error_code>403|404) '
HTTP_FORWARD_HEADER = '^HTTP/1\.1 (301 Moved Permanently|302 Found)$'
HTTP_LINK_REGEXP = \
  'http://(?P<hostname>[^/:]+)(:(?P<port>[0-9]+))?(?P<resource>/[^#]*)?'
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
	return str( filename ) + ':' + str( line_number ) + ': ' \
	       + str( link ).replace( ' ', '%20' ) + ' ' \
	       + str( error_message ) + '\n'
	
def get_ftp_link_error( link ):
	connection_data = re.search( FTP_LINK_REGEXP, link )
	if connection_data:
		hostname = connection_data.group( 'hostname' )
		port = connection_data.group( 'port' )
		
		if port == None:
			port = 21
			
		socketfd = socket_create()
		# if a socket couldn't be created,
		# just ignore this link this time.
		if socketfd == None:
			return None
			
		if socket_connect( socketfd, hostname, port ) == False:
			socketfd.close()
			return 'couldn\'t connect to host'
			
		socketfd.close()
	return None

# forwarded_from is either None or a list
def get_http_link_error( link, forwarded_from = None ):
	if forwarded_from == None:
		forwarded_from = []

	connection_data = re.search( HTTP_LINK_REGEXP, link )
	if not connection_data:
		return None
	hostname = connection_data.group( 'hostname' )
	port = connection_data.group( 'port' )
	resource = connection_data.group( 'resource' )
	
	if port == None:
		port = 80
		
	socketfd = socket_create()
	# if a socket couldn't be created,
	# just ignore this link this time.
	if socketfd == None:
		return None
	
	if socket_connect( socketfd, hostname, port ) == False:
		socketfd.close()
		return 'couldn\'t connect to host'

	if resource == None:
		resource = '/'

	socketfd.send( 'GET ' + resource + ' HTTP/1.1\r\nHost: ' \
	              + hostname + '\r\n' + ADDITIONAL_HTTP_HEADERS + '\r\n' )
	
	webpage = socket_read( socketfd )
	if webpage == None:
		socketfd.close()
		return 'couldn\'t read from socket'
	
	socketfd.close()
	
	end_of_headers_pos = webpage.find( '\r\n\r\n' )
	if end_of_headers_pos == -1:
		return 'couldn\'t find end of ' \
                       + 'headers (possibly no content in file)'
		
	header_lines = webpage[ : end_of_headers_pos ]
	header_lines = header_lines.split( '\r\n' )
	
	# search for errors
	match = regexp_search_list( HTTP_ERROR_HEADER, header_lines )
	if match:
		http_error_code = match.group( 'http_error_code' )
		return 'http error ' + http_error_code + ' returned by server'
		
	# look for forwards
	match = regexp_search_list( HTTP_FORWARD_HEADER, header_lines )
	if not match:
		return None
	# if we haven't been forwarded too many times yet...
	if len( forwarded_from ) >= FORWARDS_TO_FOLLOW:
		# we've been forwarded too many times, sorry.
		return 'too many forwards (over ' \
			+ str( len( forwarded_from ) ) + ')'
	match = regexp_search_list(HTTP_NEW_LOCATION_HEADER, header_lines)
	if match:
		forwarded_from.append(link)
		new_location = match.group('new_location')
		if new_location in forwarded_from:
			return 'forward loop!'
		return get_http_link_error(new_location, forwarded_from)
	return None
	
def is_match_inside_comment( regexp_match ):
	haystack = regexp_match.string
	match_pos = regexp_match.start()
	comment_block_start = haystack.rfind('<!--', 0, match_pos)
	comment_block_end = haystack.rfind('-->', 0, match_pos)
	if comment_block_start > comment_block_end:
		return True
	return False

def regexp_search_list(regexp, the_list):
	for list_element in the_list:
		match = re.search(regexp, list_element)
		if match:
			return match
	return None

def search_directory_for_files(base_directory, directory):
	for element_name in os.listdir(os.path.join(base_directory, directory)):
		relative_path_to_element = os.path.join(directory, element_name)
		full_path_to_element = os.path.join(base_directory, \
						    relative_path_to_element)
		if os.path.isdir(full_path_to_element):
			if re.search(EXCLUDED_DIRECTORIES_REGEXP, \
				     relative_path_to_element):
				continue
				
			search_directory_for_files(base_directory, \
						   relative_path_to_element)
		else: # it's a file
			if not re.search(FILENAMES_TO_CHECK_REGEXP, \
					 element_name):
				continue
		
			if (SKIP_TRANSLATION_FILES == True) \
			     and re.search(TRANSLATION_REGEXP, element_name):
				continue

			if re.search(EXCLUDED_FILENAMES_REGEXP, \
				      relative_path_to_element):
				continue
			
			files_to_check.append(relative_path_to_element)
				
def socket_connect(socketfd, hostname, port):
	try:
		socketfd.connect((hostname, int(port)))
	except socket.error, message:
		return False
	return True

def socket_create():
	try:
		socketfd = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		socketfd.settimeout(SOCKET_TIMEOUT)
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

def clear_file( name ):
	fd = open( name, 'w' )
	fd.close()

### OK, main program below.
	
if REPORT_FILE_PREFIX[-1] != '/':
	REPORT_FILE_PREFIX += '/'

REPORT_FILE_NAME = REPORT_FILE_PREFIX + REPORT_FILE_NAME
COMMENTED_FILE_NAME = REPORT_FILE_PREFIX + COMMENTED_FILE_NAME

base_directory = BASE_DIRECTORY
remote_base_directory = REMOTE_BASE_DIRECTORY
if remote_base_directory[-1] != '/':
	remote_base_directory += '/'

pos = remote_base_directory.find( '://' ) + 3
pos = remote_base_directory.find( '/', pos) + 1
remote_site_root = remote_base_directory[ : pos ]

# `cd` to this path
if not os.path.isdir( base_directory ):
	print 'Base directory', \
	      "`" + base_directory + "'", 'not found.'
	sys.exit( 1 )

print 'Recursively listing all files in the selected directory...'
search_directory_for_files( base_directory, '')

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
		for checked_line_number, line \
		    in enumerate( split_file_contents ):
			checked_line_number += 1 # so that line numbers
						 # don't start from 0
			if line.find( link ) != -1:
				line_number = checked_line_number
				break
		
		link_container = { 'filename': file_to_check, \
		                   'line_number': line_number, \
				   'link': link, \
				   'is_inside_comment': \
				       is_match_inside_comment( match ) }
		links_to_check.append( link_container )

print 'Alright, I\'ve got all the links. Let\'s check them now!'

report_file = REPORT_FILE_NAME
clear_file( report_file )
commented_file = COMMENTED_FILE_NAME
clear_file( commented_file )
translation_report_files = {}

number_of_links_to_check = str( len( links_to_check ) )
already_checked_links = []
for i, link_container in enumerate( links_to_check ):
	if i % 10 == 0:
		print '\rChecking link ' + str( i + 1 ) + ' of ' \
		      + number_of_links_to_check + '...',
		sys.stdout.flush()

	filename = link_container['filename']
	line_number = link_container['line_number']
	link = link_container['link']
	is_inside_comment = link_container['is_inside_comment']

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
			subdir = ''
			pos = filename.rfind( '/' )
			if pos != -1:
				subdir = filename[: pos] + '/'
			link = remote_base_directory + subdir + link
			
	link_already_checked = False
	link_id = -1
	for i, already_checked_link in enumerate( already_checked_links ):
		if link == already_checked_link['link']:
			link_already_checked = True
			link_id = i
			break
			
	if link_already_checked:
		link_error = already_checked_links[link_id]['error']
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
				break # ignore the link,
				      # since its protocol is unsupported
			
			if DELAY_BETWEEN_RETRIES > 0:
				time.sleep( DELAY_BETWEEN_RETRIES )
				
		already_checked_links.append( { 'link': link, \
						'error': link_error } )

	# Report working links inside comments so that webmasters
	# could uncomment them.
	if link_error == None and is_inside_comment:
		link_error = 'no error detected'
		
	if link_error != None:
		if is_inside_comment:
			link_error += ' (link commented out)'
			file_to_write = commented_file
			postfix = '/c'
		else:
			file_to_write = report_file
			postfix = '/0'

		match = re.search( TRANSLATION_REGEXP, filename )
		if match:
			langcode = match.group( 'langcode' )
			file_idx = langcode + postfix
			if file_idx not in translation_report_files:
				translation_report_files[file_idx] = \
				  file_to_write + '-' + langcode
				clear_file(translation_report_files[file_idx])
			file_to_write = translation_report_files[file_idx]
		fd = open(file_to_write, 'a')
		fd.write(format_error(filename, line_number, \
					       link, link_error))
		fd.close()
	
	if DELAY_BETWEEN_CHECKS > 0:
		time.sleep( DELAY_BETWEEN_CHECKS )

print '\nDone! :-)'
