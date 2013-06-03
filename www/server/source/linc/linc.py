#! /usr/bin/python
# -*- coding: utf-8 -*-
#
# LINC - LINC Is Not Checklink
# Copyright © 2011-2012 Wacław Jacek
# Copyright © 2013 Free Software Foundation, Inc.
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

LINC_VERSION = 'LINC 0.13'
USAGE = \
'''Usage: %prog [options] [BASE_DIRECTORY]
Check links in HTML files from BASE_DIRECTORY.'''
COPYRIGHT= \
'''Copyright (C) 2011-2012 Waclaw Jacek
Copyright (C) 2013 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Waclaw Jacek.'''

BASE_DIRECTORY = ''
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
REPORT_FILE_PREFIX = './'

# File to which the errors will be reported.
REPORT_FILE_NAME = 'broken_links'

# File to which commented out links will be reported.
COMMENTED_FILE_NAME = 'commented_out'

# If you set this to True, files with translations will be skipped.
SKIP_TRANSLATION_FILES = False

# After what time to give up with trying to retrieve a website.
SOCKET_TIMEOUT = 20

# Don't download the files, assume no error.
LOCAL = False

CACHE = None

# Matching directories will not be entered to check their
# files or subdirectories.
EXCLUDED_DIRECTORIES_REGEXP = '^(japan|wwwin|education/fr|\
education/draft|press|screenshots|server/staging|software/[^/]+)$|(^|/)po$'
EXCLUDED_FILENAMES_REGEXP = \
  '^(server/(standards/boilerplate\.html' + \
  '|source/linc/linc-report\.html' + \
  '|.*whatsnew(\.[a-z]{2}(-[a-z]{2})?)?\.html)|volunteers/volunteers\.html)$'

FILENAMES_TO_CHECK_REGEXP = '\.html$' # Only matching files will be checked.
SYMLINKS_FILENAME = '.symlinks'

FTP_LINK_REGEXP = 'ftp://(?P<hostname>[^/:]+)(:(?P<port>[0-9]+))?'

# What to treat as a HTTP error header.
HTTP_ERROR_HEADER = '(^|\r\n)HTTP/1\.1 (?P<http_error_code>403|404) '
HTTP_FORWARD_HEADER = \
  '(^|\r\n)HTTP/1\.1 (301 Moved Permanently|302 Found)(\r\n|$)'
HTTP_LINK_REGEXP = \
  'http://(?P<hostname>[^/:]+)(:(?P<port>[0-9]+))?(?P<resource>/[^#]*)?'
HTTP_NEW_LOCATION_HEADER = '(^|\r\n)Location: (?P<new_location>.+)(\r\n|$)'
LINK_BEGIN = '(?i)(<a\s[^<]*)'
# We want to parse links like href="URL" as well as href='URL';
# I failed to compose a single regexp for that -- ineiev.
LINK_REGEXP = \
[ '(?is)^<a(\s.+?)?\shref="(?P<link>[^"]+)"(\s.+?)?>',
  "(?is)^<a(\s.+?)?\shref='(?P<link>[^']+)'(\s.+?)?>"]
TRANSLATION_REGEXP = '\.(?P<langcode>[a-z]{2}|[a-z]{2}-[a-z]{2})\.[^.]+$'
SYMLINK_REGEXP='^\s*(?P<to>[^\s]*)\s+(?P<from>[^\s]*).*$'
# Don't report against commented out link to README.translations.html
LINK_TO_SKIP = '/server/standards/README.translations.html'

VERBOSE = 0
WICKED = 0

import os
import re
import socket
import sys
import time
from optparse import OptionParser

symlinks = {}
remote_site_root = None
remote_base_directory = None

def report(level, msg):
	if VERBOSE > level:
		print msg

def format_error(symlink, filename, line_number, link, error_message):
	if symlink != None:
		filename += ' <- ' + symlink
	return filename + ':' + line_number + ': ' \
	       + link.replace(' ', '%20') + ' ' + error_message + '\n'

def get_ftp_link_error(link):
	connection_data = re.search(FTP_LINK_REGEXP, link)
	if not connection_data:
		return None
	hostname = connection_data.group('hostname')
	port = connection_data.group('port')

	if port == None:
		port = 21

	socketfd = socket_create()
	# if a socket couldn't be created,
	# just ignore this link this time.
	if socketfd == None:
		return None

	if socket_connect(socketfd, hostname, port) == False:
		socketfd.close()
		return 'couldn\'t connect to host'

	socketfd.close()
	return None

# forwarded_from is either None or a list
def get_http_link_error(link, forwarded_from = None):
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

	end_of_headers = webpage.find('\r\n\r\n')
	if end_of_headers == -1:
		report(1, 'No end of headers found on webpage (link ' \
			 + link + ')')
		report(1, '- - - - -')
		report(1, webpage)
		report(1, '- - - - -')
		return 'couldn\'t find end of ' \
                       + 'headers (possibly no content in file)'

	header = webpage[:end_of_headers]
	# search for errors
	match = re.search(HTTP_ERROR_HEADER, header)
	if match:
		http_error_code = match.group('http_error_code')
		return 'http error ' + http_error_code + ' returned by server'

	# look for forwards
	match = re.search(HTTP_FORWARD_HEADER, header)
	if not match:
		return None
	# if we haven't been forwarded too many times yet...
	if len(forwarded_from) >= FORWARDS_TO_FOLLOW:
		# we've been forwarded too many times, sorry.
		return 'too many forwards (over ' \
			+ str(FORWARDS_TO_FOLLOW) + ')'
	match = re.search(HTTP_NEW_LOCATION_HEADER, header)
	if not match:
		return None
	forwarded_from.append(link)
	new_location = match.group('new_location')
	if new_location in forwarded_from:
		return 'forward loop!'
	return get_http_link_error(new_location, forwarded_from)

def is_inside_comment(head):
	start = head.rfind('<!--')
	if start <= head.rfind('-->'):
		return 'no'
	n = len('<!--') + start
	if len(head) <= n:
		return 'yes'
	if head[n] != '#':
		return 'yes'
	return 'ssi'

# Current symlinks processing doesn't take into account parallel
# links to the translations; instead, the translators should maintain
# URLs in sync with the originals.
def load_symlinks(root, directory, path):
	report(1, 'Found symlinks file `' + path + "'.")
	try:
		f = open(os.path.join(root, path), 'r')
	except IOError:
		report(-3, "Failed to read symlinks file `" + path + "'.")
		return
	lines = f.read().splitlines()
	f.close()
	if not directory in symlinks:
		symlinks[directory] = {}
	for i, l in enumerate(lines):
		# Skip empty lines and comments.
		if re.search('^\s*(#|$)', l):
			continue
		match = re.search(SYMLINK_REGEXP, l)
		if not match:
			report(-3, path + ":" + str(i + 1) \
				+ ": Couldn't parse symlink `" + l + "'.")
			continue
		source = match.group('from')
		dest = match.group('to')
		report(2, path + ":" + str(i + 1) + ": Symlink `" \
			+ dest + "' <- `" + source + "' found.")
		symlinks[directory][source] = dest

def classify_link(filename, link, symlink = None):
	link_type = 'http'
	# When we process a symlinked file, we use the directory
	# from which it is linked rather than the actual location
	# of the file.
	dir_name = symlink if (symlink != None) else filename
	if re.search('^(mailto:|irc://|https://)', link):
		link_type = 'unsupported'
	elif link.find('http://') == 0:
		link_type = 'http'
	elif link.find('ftp://') == 0:
		link_type = 'ftp'
	elif link[0] == '/':
		link = remote_site_root + link[1:]
	else:
		subdir = ''
		pos = dir_name.rfind('/')
		if pos != -1:
			subdir = dir_name[: pos] + '/'
		link = remote_base_directory + subdir + link
	return [link_type, link]

def scan_file(root, file_to_check, symlink = None):
	path = os.path.join(root, file_to_check)
	fd = open(path, 'r')
	text = fd.read()
	fd.close()

	lines = 1
	head = ''
	for chunk in re.split(LINK_BEGIN, text):
		line_no = lines 
		if chunk == None:
			continue
		commented = is_inside_comment(head)
		lines += chunk.count('\n')
		head += chunk
		match = None
		for regexp in LINK_REGEXP:
			match = re.search(regexp, chunk)
			if match != None:
				break
		if not match:
			continue
		[link_type, url] = classify_link(file_to_check, \
						  match.group('link'), symlink)
		if link_type == 'unsupported':
			continue
		links_to_check.append({'symlink': symlink, 'URL': url,
				       'filename': file_to_check,
				       'line_number': str(line_no),
				       'link': match.group('link'),
				       'is_inside_comment': commented})
		if not url in urls_to_check:
			urls_to_check[url] = \
					 {'link': match.group('link'),
					  'is_inside_comment': commented,
				  	  'type': link_type}

def scan_directory(root, directory):
	for element_name in os.listdir(os.path.join(root, directory)):
		relative_path = os.path.join(directory, element_name)
		full_path = os.path.join(root, relative_path)
		if os.path.isdir(full_path):
			if not re.search(EXCLUDED_DIRECTORIES_REGEXP, \
				     relative_path):
				scan_directory(root, relative_path)
			continue
		if SYMLINKS_FILENAME == element_name:
			load_symlinks(root, directory, relative_path)
			continue
		if not re.search(FILENAMES_TO_CHECK_REGEXP, element_name):
			continue
		if re.search(EXCLUDED_FILENAMES_REGEXP, relative_path):
			continue
		scan_file(root, relative_path)

def get_symlink_target(root, directory, destination, depth = 0):
	if depth > 17:
		report(-2, 'Too deep symlink.')
		if WICKED > 1:
			print 'Aborting due to a deep symlink.'
			exit(1)
		return None
	# Skip external links.
	# TODO: check it as a link.
	if re.search('^(ftp|http(s?))://', destination):
		report(2, 'External symlink found.')
		return None

	report(2, 'Getting target of `' + directory + "'/`" \
			+ destination + "', depth=" + str(depth))
	path = os.path.join(directory, destination)
	if path[0] == '/':
		path = path[1:]
	pos = path.rfind('/')
	if pos == -1:
		dest = path
		new_dir = ""
	else:
		dest = path[pos + 1:]
		new_dir = path[:pos]
	while re.search('[^/]*/../', new_dir):
		new_dir = re.sub('[^/]*/../', '', new_dir)
	if os.path.exists(os.path.join(root, path)):
		if os.path.isdir(os.path.join(root, path)):
			report(2, 'Symlinked directory `' + path + "' found.")
			if re.search(EXCLUDED_DIRECTORIES_REGEXP, new_dir):
				report(2, 'Symlinked directory excluded.')
				return None
			return get_symlink_target(root, new_dir,
				 'index.html', depth + 1)
		report(2, 'Symlinked file found.')
		if re.search(EXCLUDED_FILENAMES_REGEXP, path):
			report(2, 'Symlinked file excluded.')
			return None
		return path
	report(2, 'No `' + path + "' file exists.")
	report(2, 'Searching for symlinks in `' + path + "'")
	if new_dir in symlinks:
		report(2, 'Searching for symlink `' + dest + "'")
		if dest in symlinks[new_dir]:
			report(2, 'Symlink found: `' \
				+ symlinks[new_dir][dest] + "'")
			return get_symlink_target(root, new_dir,
						  symlinks[new_dir][dest],
						  depth + 1)
	report(-2, 'Blind symlink found.')
	if WICKED > 1:
		print 'Aborting due to a blind symlink.'
		exit(1)
	return None

def process_symlinks(root):
	for directory in symlinks:
		for source in symlinks[directory]:
			if not re.search(FILENAMES_TO_CHECK_REGEXP, source):
				continue
			dest = symlinks[directory][source]
			report(2, 'Trying `' + directory + "'/`" \
				+ source + "' -> `" + dest + "'..")
			destination = get_symlink_target(root, directory, dest)
			if destination == None:
				continue
			scan_file(root, destination, os.path.join(directory, source))

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

def clear_file(name):
	fd = open(name, 'w')
	fd.close()

def show_usage(option, opt, value, parser):
	parser.print_help()
	exit(0)

def show_version(option, opt, value, parser):
	print LINC_VERSION
	print COPYRIGHT
	exit(0)

def load_cache(cache):
	if cache == None:
		report(2, "No cache file is loaded.")
		return {}
	try:
		f = open(cache, 'r')
	except IOError:
		report(-3, "Failed to read cache file `" + cache + "'.")
		return {}
	report(2, "Loading cache file `" + cache +"'.")
	text = f.read()
	f.close();
	retval = {}
	for link in text.splitlines():
		retval[link] = None
	report(2, "Loaded links: " + str(len(retval)))
	return retval

def save_cache(cache, checked_links):
	if cache == None:
		report(2, "No cache file is saved.")
		return
	try:
		f = open(cache, 'w')
	except IOError:
		report(-3, "Failed to write cache file `" + cache + "'.")
		return
	report(2, "Saving cache file `" + cache +"'.")
	for link in checked_links:
		# Links containing a newline are not cached
		# because newline is used in cache as the separator.
		if checked_links[link] == None and link.find('\n') == -1:
			f.write(link + '\n')
	f.close()

parser = OptionParser(usage = USAGE, add_help_option = False)

parser.add_option('-a', '--attempts', dest = 'attempts', type = 'int',
		  metavar = 'N',
                  help = 'maximum number of attempts [' \
			 + str(NUMBER_OF_ATTEMPTS) + ']')
parser.add_option('-c', '--check-delay', dest = 'check_delay',
		  type = 'float', metavar = 'DELAY',
                  help = 'delay between checks in seconds [' \
			+ str(DELAY_BETWEEN_CHECKS) + ']')
parser.add_option('-C', '--cache', dest = 'cache', metavar = 'FILE',
		  help = 'use cache FILE')
parser.add_option('-f', '--forwards', dest = 'forwards', type = 'int',
		  metavar = 'N',
                  help = 'maximum number of forwards to follow [' \
			 + str(FORWARDS_TO_FOLLOW) + ']')
parser.add_option('-g', '--good', dest = 'good', action = 'count',
		  help = "be more good")
parser.add_option('-l', '--local', dest = 'local', action = 'store_true',
		  default = False,
		  help = "don't download files, assume no error")
parser.add_option('-o', '--output', dest = 'dir_name', metavar = 'DIRECTORY',
		  help = 'write reports to DIRECTORY [' \
			 + REPORT_FILE_PREFIX + ']')
parser.add_option('-q', '--quiet', dest = 'quiet',
		  action = 'count', help = "be more quiet")
parser.add_option('-r', '--retry-delay', dest = 'retry_delay', type = 'float',
		  metavar = 'DELAY',
                  help = 'delay between retries in seconds [' \
			 + str(DELAY_BETWEEN_RETRIES) + ']')
parser.add_option('-s', '--skip-translations', dest = 'skip_translations',
		  action = 'store_true',
		  help = "skip files whose name has any language suffix")
parser.add_option('-t', '--socket-timeout', dest = 'timeout', type = 'float',
                  help = 'socket timeout [' + str(SOCKET_TIMEOUT) + ']')
parser.add_option('-u', '--url', dest = 'url', metavar = 'URL',
                  help = 'base URL of the website [' \
			 + REMOTE_BASE_DIRECTORY + ']')
parser.add_option('-x', '--exclude', dest = 'exclude', metavar = 'REGEXP',
                  help = 'skip files whose names match REGEXP [' \
			 + EXCLUDED_FILENAMES_REGEXP + ']')
parser.add_option('-X', '--exclude-dir', dest = 'exclude_dir',
		  metavar = 'REGEXP',
                  help = 'skip directories whose names match REGEXP [' \
			 + EXCLUDED_DIRECTORIES_REGEXP + ']')
parser.add_option('-v', '--verbose', dest = 'verbose', action = 'count',
		  help = "be more verbose")
parser.add_option('-w', '--wicked', dest = 'wicked', action = 'count',
		  help = "be more wicked")
parser.add_option('-h', '-?', '--help', action = 'callback',
		  callback = show_usage, help = 'display this help and exit')
parser.add_option('-V', '--version', action = 'callback',
		  callback = show_version,
                  help = 'output version information and exit')

(options, args) = parser.parse_args()

if len(args) > 1:
	print 'Incorrect number of arguments (' \
		+ str(len(args)) + '; should be 1 or less)' >> stderr
	exit(1)

if len(args) != 0:
	BASE_DIRECTORY = args[0]
else:
	prog_dir = sys.argv[0]
	pos = prog_dir.rfind('/')
	prog_dir = prog_dir[ : pos] if (pos != -1) else './'
	# This script's place is /server/source/linc
	BASE_DIRECTORY = os.path.abspath(os.path.join(prog_dir, '../../..'))

if options.quiet != None:
	VERBOSE -= options.quiet
if options.verbose != None:
	VERBOSE += options.verbose
if options.good != None:
	WICKED -= options.good
if options.wicked != None:
	WICKED += options.wicked
if options.attempts != None:
	NUMBER_OF_ATTEMPTS = options.attempts
if options.check_delay != None:
	DELAY_BETWEEN_CHECKS = options.check_delay
if options.forwards != None:
	FORWARDS_TO_FOLLOW = options.forwards
if options.dir_name != None:
	REPORT_FILE_PREFIX = options.dir_name
if options.retry_delay != None:
	DELAY_BETWEEN_RETRIES = options.retry_delay
if options.skip_translations != None:
	SKIP_TRANSLATION_FILES = options.skip_translations
if options.timeout != None:
	SOCKET_TIMEOUT = options.timeout
if options.url != None:
	REMOTE_BASE_DIRECTORY = options.url
if options.exclude != None:
	EXCLUDED_FILENAMES_REGEXP = options.exclude
if options.exclude_dir != None:
	EXCLUDED_DIRECTORIES_REGEXP = options.exclude_dir
if options.local != None:
	LOCAL = options.local
CACHE = options.cache

base_directory = BASE_DIRECTORY
remote_base_directory = REMOTE_BASE_DIRECTORY
if remote_base_directory[-1] != '/':
	remote_base_directory += '/'

pos = remote_base_directory.find( '://' ) + 3
pos = remote_base_directory.find( '/', pos) + 1
remote_site_root = remote_base_directory[ : pos ]

if REPORT_FILE_PREFIX[-1] != '/':
	REPORT_FILE_PREFIX += '/'

REPORT_FILE_NAME = REPORT_FILE_PREFIX + REPORT_FILE_NAME
COMMENTED_FILE_NAME = REPORT_FILE_PREFIX + COMMENTED_FILE_NAME

report(0, "Base directory:       `" + BASE_DIRECTORY + "'")
report(0, "Cache file:           " + \
	("`" + CACHE + "'" if CACHE else "(None)"))
report(0, "Number of attempts:    " + str(NUMBER_OF_ATTEMPTS))
report(0, "Delay between checks:  " + str(DELAY_BETWEEN_CHECKS))
report(0, "Delay between retries: " + str(DELAY_BETWEEN_RETRIES))
report(0, "Socket timeout:        " + str(SOCKET_TIMEOUT))
report(0, "Forwards to follow:    " + str(FORWARDS_TO_FOLLOW))
report(0, "Skip translations:     " + str(SKIP_TRANSLATION_FILES))
report(0, "Report to directory:  `" + REPORT_FILE_PREFIX + "'")
report(0, "Base URL:             `" + REMOTE_BASE_DIRECTORY + "'")
report(0, "Excluded files:       `" + EXCLUDED_FILENAMES_REGEXP + "'")
report(0, "Excluded directories: `" + EXCLUDED_DIRECTORIES_REGEXP + "'")
report(0, "Run locally:           " + str(LOCAL))
report(0, "Verbosity:             " + str(VERBOSE))
report(0, "Wickedness:            " + str(WICKED))

if not os.path.isdir(base_directory):
	report(-3, "Base directory `" + base_directory + "' not found.")
	exit(1)

report(-1, 'Recursively listing all files in the selected directory...')
links_to_check = []
urls_to_check = {}
scan_directory(base_directory, '')
report(-1, 'Processing symlinks...')
process_symlinks(base_directory)
checked_urls = load_cache(CACHE)
unique_links = str(len(urls_to_check))
cached_links = 0
for link in checked_urls:
	if link in urls_to_check:
		del urls_to_check[link]
		cached_links += 1
report(-1, 'Checking links...')
for j in range(NUMBER_OF_ATTEMPTS):
    report(-2, 'Pass ' + str(j + 1) + ' of ' + str(NUMBER_OF_ATTEMPTS) + ':')
    next_urls_to_check = urls_to_check.copy()
    number_of_links_to_check = str(len(urls_to_check))
    for i, url in enumerate(urls_to_check):
	link_container = urls_to_check[url]
	if (i % 10 == 0 and VERBOSE > -2):
		print '\rChecking link ' + str(i + 1) + ' of ' \
		      + number_of_links_to_check + '...',
		sys.stdout.flush()

	link = link_container['link']
	# BTW, shouldn't we check whether the named fragment
	# is present on the page?
	if link_container['is_inside_comment'] == 'ssi' or link[0] == '#':
		continue
	link_error = None
	if url in checked_urls:
		link_error = checked_urls[url]
		if link_error == None:
			del next_urls_to_check[url]
			continue
	link_type = link_container['type']
	if LOCAL:
		link_error = None
	elif link_type == 'ftp':
		link_error = get_ftp_link_error(url)
	elif link_type == 'http':
		link_error = get_http_link_error(url)
	else:
    		report(1, 'Unexpected link type `' + link_type + "' found.")
    		if WICKED > 0:
			print 'Aborting due to an unexpected link type.'
			exit(1)
		continue
	checked_urls[url] = link_error
	if link_error == None:
		del next_urls_to_check[url]
	if DELAY_BETWEEN_CHECKS > 0:
		time.sleep(DELAY_BETWEEN_CHECKS)
    urls_to_check = next_urls_to_check

    save_cache(CACHE, checked_urls)
    broken_so_far = 0
    for i, link in enumerate(checked_urls):
	err = checked_urls[link]
	if err != None:
		broken_so_far = broken_so_far + 1
	if (VERBOSE > 1 and err != None) or VERBOSE > 2:
		print 'link ' + str(i) + ': ' + link \
			+ ': ' + (err if err else '(no error)')
    report(-2, '\n' + str(len(links_to_check)) + ' links, ' \
	      + unique_links + ' unique, ' \
	      + str(cached_links) + ' cached, ' \
	      + str(broken_so_far) + ' seem broken')
    if broken_so_far == 0:
	report(-2, 'No more broken links; skipping the rest passes (if any)')
	break
    if j < NUMBER_OF_ATTEMPTS - 1 and DELAY_BETWEEN_RETRIES > 0:
	time.sleep(DELAY_BETWEEN_RETRIES)

report(-1, 'Writing reports...')

report_file = REPORT_FILE_NAME
commented_file = COMMENTED_FILE_NAME
report_files = []

for i, link_container in enumerate(links_to_check):
	filename = link_container['filename']
	line_number = link_container['line_number']
	url = link_container['URL']
	link = link_container['link']
	commented = link_container['is_inside_comment']
	if commented == 'ssi' or link[0] == '#':
		continue
	if commented == 'yes' and link == LINK_TO_SKIP:
    		report(2, 'Skipping link `' + LINK_TO_SKIP + "'")
		continue

	if link[0] != '/' and not re.search('^[^/]*:', link):
    		report(2, filename + ':' + line_number \
		      + ': link ' + str(i) + ' `' + link + "' is relative")

	if url in checked_urls:
		link_error = checked_urls[url]
	else:
    		report(-3, filename + ':' + line_number \
			 + ': Unchecked link `' + url + "' detected.")
    		if WICKED > 0:
			print 'Aborting due to an unchecked link.'
			exit(1)
		continue
	# Report working links inside comments so that webmasters
	# could uncomment them.
	if link_error == None and commented == 'yes':
		link_error = 'no error detected'
	if link_error == None:
		continue
	file_prefix = report_file
	if commented == 'yes':
		link_error += ' (link commented out)'
		file_prefix = commented_file
	langcode = ''
	match = re.search(TRANSLATION_REGEXP, filename)
	if match:
		langcode = '-' + match.group('langcode')
	file_to_write = file_prefix + langcode
	if file_to_write not in report_files:
		clear_file(file_to_write)
		report_files.append(file_to_write)
	fd = open(file_to_write, 'a')
	fd.write(format_error(link_container['symlink'], filename, \
				line_number, url, link_error))
	fd.close()

report(-1, 'Done!')
