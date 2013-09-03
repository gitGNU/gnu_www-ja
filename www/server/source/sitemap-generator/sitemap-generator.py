# -*- coding: utf-8 -*-
#
# Sitemap generator
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

import os
import re
import sys
import datetime

LANGCODE_REGEXP = '(?P<langcode>[a-z]{2}|[a-z]{2}-[a-z]{2})'
CHARSET_REGEXP_CONTENT_PART = 'content=\s*(?P<cquote>[\'"])text/html;\s*' \
                                + 'charset\s*=\s*(?P<encoding>.*?)(?P=cquote)'
CHARSET_REGEXP_HTTP_EQUIV_PART =  \
 'http-equiv\s*=\s*(?P<equote>[\'"]?)content-type(?P=equote)'
HEADER_REGEXP = \
  '<!--#include\s+virtual=(["\'])/server/(html5-)?header(\.' \
    + LANGCODE_REGEXP + ')?\.html\\1\s+-->'

LINK_TO_INDEX_FILES = True
FILENAMES_TO_LIST_REGEXP = '\.html$'
# This is used to detect pages that are in fact forwards.
FORWARD_REGEXP = '<meta\s+http-equiv=([\'"]?)refresh\\1\s+' \
                   + 'content=([\'"]?)[0-9]+;\s*url=.+\\2>'
OUTPUT_FILE_NAME = 'sitemap.html'
# The expression for names of localized sitemap versions.
SITEMAP_REGEXP = 'sitemap\.' + LANGCODE_REGEXP + '\.html'
TOP_DIRECTORY = ''
SITEMAP_DIR = 'server'
TRANSLATION_REGEXP = '\.(?P<langcode>[a-z]{2}|[a-z]{2}-[a-z]{2})' \
		     + FILENAMES_TO_LIST_REGEXP
VALID_ENCODINGS = [ 'utf-8', 'iso-8859-1', 'iso8859-2', 'iso-8859-2', 'big5',
		    'euc-kr', 'euc-jp', 'gb2312', 'iso-8859-7', 'iso8859-7',
		    'iso-8859-8', 'windows-1251', 'windows-1252'] # in lowercase
GNUN_SPLIT = '<span class="gnun-split"></span>\n'
SITE_LINGUAS = \
[ 'af', 'ar', 'az', 'bg', 'bn', 'bs', 'ca', 'cs', 'da', 'de', 'el', 'en', 'eo',
  'es', 'fa', 'fi', 'fr', 'gl', 'he', 'hr', 'hu', 'id', 'it', 'ja', 'kn', 'ko',
  'mk', 'ml', 'nb', 'nl', 'nn', 'pl', 'pt', 'pt-br', 'ro', 'ru', 'sh', 'sk', 'sl',
  'sq', 'sr', 'sv', 'sw', 'ta', 'th', 'tl', 'tr', 'uk', 'uz', 'vi', 'zh-cn',
  'zh-tw' ]
sitemap_linguas = []
no_index_checks = None
print_always = None
excluded_dirs = None
excluded_files = None
output_text = ''
translist = ''
translation_linguas = []
title_tails = None
replacement_titles = None
translations = {}
index_filenames = {}

def is_directory_empty(path):
	directory_contents = get_directory_contents(path)
	files = directory_contents['files']
	subdirs = directory_contents['subdirectories']
	
	if len(files) != 0:
		return False
	if len(subdirs) != 0:
		for subdir in subdirs:
			if not is_directory_empty(os.path.join(path, subdir)):
				return False
	return True

def determine_file_encoding(text, path):
	# Headers are known to specify utf-8.
	if re.search(HEADER_REGEXP, text):
		return 'utf-8'
	match = re.search('<meta\s*' + CHARSET_REGEXP_HTTP_EQUIV_PART \
                            + '\s*' + CHARSET_REGEXP_CONTENT_PART, \
                          text.lower())
	if not match:
		match = re.search('<meta\s*' + CHARSET_REGEXP_CONTENT_PART \
                             + '\s*' + CHARSET_REGEXP_HTTP_EQUIV_PART, \
                           text.lower())
	if match:
		encoding = match.group('encoding').lower()
		if encoding == 'iso-8859-8i':
			encoding = 'iso-8859-8'
		if encoding in VALID_ENCODINGS:
			return encoding
	print path + ': no encoding specified.'
	# A non-ASCII file who declares no encoding has no right to exist.
	return 'utf-8'

def get_sitemap_linguas():
	linguas = []
	for f in os.listdir(os.path.join(TOP_DIRECTORY, SITEMAP_DIR)):
		match = re.search(SITEMAP_REGEXP, f)
		if match and not (match.group('langcode') in linguas):
			linguas.append(match.group('langcode'))
	line = 'Found sitemap translations:'
	for l in sorted(linguas):
		line = line + ' ' + l
	print line
	return linguas
			

def get_directory_contents(directory):
	files = []
	subdirs = []

	for element_name in os.listdir(os.path.join(TOP_DIRECTORY, directory)):
		relative_path = os.path.join(directory, element_name)

		if os.path.isdir(os.path.join(TOP_DIRECTORY, relative_path)) \
                   and not match_against_list(relative_path, excluded_dirs):
			subdirs.append( element_name )
		elif re.search(FILENAMES_TO_LIST_REGEXP, element_name) \
                     and not match_against_list(relative_path, excluded_files) \
                     and not is_file_a_redirect(relative_path):
			files.append( element_name )
			
	return {'files': files, 'subdirectories': subdirs}
	
def get_index_filename(directory):
	if directory in index_filenames:
		return index_filenames[directory]
	# We only want either directoryname.html or index.html files.
	# If both are present, don't use either, and output an error,
	# so it can be resolved.
	directory_name = get_name_from_path( directory )
	
	files_called_index = ['index.html', 'index.htm']
	files_called_directoryname = [directory_name + '.html', \
                                      directory_name + '.htm']
	files_in_directory = get_directory_contents(directory)['files']
	
	index_file = None
	dir_file = None
	
	for filename in files_called_index:
		if filename in files_in_directory:
			index_file = filename
			
	for filename in files_called_directoryname:
		if filename in files_in_directory:
			dir_file = filename
			
	if index_file and dir_file:
		# Only complain about duplicate index files
		# if it isn't a deliberate instance of such.
		if not match_against_list(directory, no_index_checks):
			print 'Error: Directory ' + directory \
				+ ' has both an index file called "' \
				+ index_file \
				+ '" and a directoryname file called "' \
				+ dir_file \
				+ '". Neither will be used as main page.'
	elif index_file:
		return index_file
	elif dir_file:
		return dir_file
	return None

def get_name_from_path(path):
	rightmost_slash_pos = path.rfind('/')
	if rightmost_slash_pos != -1:
		return path[ rightmost_slash_pos + 1 : ]
	return path
	
def load_replacement_titles():
	nonsplitted_list = read_file('replacement_titles').splitlines()
	splitted_dict = {}
	
	# the variables below are used in looping
	regexp = None
	replacement_title = None
	
	for element in nonsplitted_list:
		if element != '':
			# If we've already stored a title and a regexp,
			# this is an invalid entry and all lines
			# until '' should be ignored.
			if regexp and replacement_title:
				pass
			# If only have the regexp, this is
			# the replacement title.
			if regexp:
				replacement_title = element
				splitted_dict[regexp] = replacement_title
			else:
				regexp = element
		else: # Empty item encountered. Reset.
			regexp = None
			replacement_title = None
			
	return splitted_dict
	
# Return the contents of first tag found in text, encoded in utf-8.
def extract_tag(text, tag):
	regexp ='<' + tag + '(\s[^>]*)?>(?P<title>.*?)</' + tag + '>'
	match = re.search(regexp, text, re.DOTALL)
	if not match:
		return None
	title = match.group('title').strip()
	if len(title) == 0:
		return title
	return title

# Try to find different tags in the text.
def extract_tags(text, tags):
	for tag in tags:
		title = extract_tag(text, tag)
		if title:
			break
		title = extract_tag(text, tag.upper())
		if title:
			break
	return title

def get_title(path):
	# Before we will try to determine the actual title,
	# check if it has to be overwritten.
	match = match_against_list(path, replacement_titles)
	if match:
		return replacement_titles[match.re.pattern]
	text = read_file(os.path.join(TOP_DIRECTORY, path))
	title = extract_tags(text, ['h1', 'h2', 'h3'])
	encoding = determine_file_encoding(text, path)
	if title:
		title = re.sub('<CODE>', '<code>', title)
		title = re.sub('</CODE>', '</code>', title)
		title = re.sub('<center>', '', title)
		title = re.sub('</center>', '', title)
		title = re.sub('<CENTER>', '', title)
		title = re.sub('</CENTER>', '', title)
		return title.decode(encoding, 'replace')
	# No <h?> tags found: use <title>, which needs trimming.
	title = extract_tags(text, ['title'])
	if not title:
		return None
	for regexp in title_tails:
		match = re.search(regexp, title)
		if match:
			title = title[ : match.start() ] \
					+ title[ match.end() : ]
	return title.decode(encoding, 'replace')

def get_titles_for_files( directory, files ):
	titles = {}
	
	for filename in files:
		title = get_title(os.path.join(directory, filename))
		if title:
			titles[filename] = title
		
	return titles
	

def is_file_a_redirect(path):
	text = read_file(os.path.join(TOP_DIRECTORY, path))

	if re.search(FORWARD_REGEXP, text, re.IGNORECASE):
		return True
		
	return False
	
def is_file_a_translation(filename):
	if re.search(TRANSLATION_REGEXP, filename):
		return True
	return False
	
def join_url_paths(*list_of_paths):
	final_path = ''

	for path in list_of_paths:
		if len( path ) != 0:
			if final_path == '' or final_path[-1] == '/':
				final_path += path
			else:
				final_path += '/' + path
		
	return final_path
	
def print_links_to_subdirs(directory, subdirs):
	write('\n<div>\n<p>[top-level directories:')
	for subdir in sorted(subdirs, key = str.lower):
		if not is_directory_empty(os.path.join(directory, subdir)):
			full_dir = os.path.join(directory, subdir)
			write('\n  <a href="#directory-' \
			      + full_dir.replace('/', '-') + '">' \
			      + subdir + '</a>')
	write( ']</p>\n</div>\n\n' )

def escape_po_string(string):
	ret = string
	# Remove local links that may conflict (different files may
	# have identically named links).
	ret = re.sub('<a\s+[^>]*href=(["\'])#[^>]*\\1[^>]*>(.*?)</a>', '', ret)
	ret = re.sub('"', '\\\\"', ret)
	ret = re.sub('\n', ' \\\\' + 'n' + '"\n"', ret)
	return ret

def po_entry(msgid, msgstr):
	return '\nmsgid "' + escape_po_string(msgid) + '"\n' \
		+ 'msgstr "' + escape_po_string(msgstr) + '"\n'

def output_translations(prefix):
	for lang in sitemap_linguas:
		fd = open(prefix + '.' + lang + '.po', 'a')
		for msgid in translations:
			string = ''
			trans = translations[msgid]
			if trans == None:
				string = po_entry(msgid, msgid)
			elif lang in trans:
				string = po_entry(msgid, trans[lang])
			if string != '':
				fd.write(string.encode('utf-8'))
		fd.close()

def append_sitemap_pos(msgid, msgstr = None):
	trans = {}
	if msgstr == None:
		translations[msgid] = None
		return
	if msgid in translations:
		if translations[msgid] == None:
			return
		trans = translations[msgid]
	for lang in sitemap_linguas:
		if lang in msgstr:
			trans[lang] = msgstr[lang]
	translations[msgid] = trans
	
def append_title_to_pos(filename, title, titles):
	msgstr = {}
	for lang in sitemap_linguas:
		name = re.sub('(' + FILENAMES_TO_LIST_REGEXP + ')', \
			      '.' + lang +'\\1', filename)
		if name in titles:
			msgstr[lang] = titles[name]
	append_sitemap_pos(title, msgstr)

def init_sitemap_pos():
	for lang in sitemap_linguas:
		fd = open(OUTPUT_FILE_NAME + '.' + lang + '.po', 'w')
		d = datetime.datetime.now()
		fd.write(\
'''# Automatically generated by sitemap-generator.py
msgid ""
msgstr ""
"Project-Id-Version: sitemap.html\\n"
"POT-Creation-Date: ''' + d.strftime('%Y-%m-%d %H:%M%z') + '''\\n"
"PO-Revision-Date: ''' + d.strftime('%Y-%m-%d %H:%M%z') + '''\\n"
"Last-Translator: sitemap-generator <gnun@gnu.org>\\n"
"Language-Team: ''' + lang + ''' <web-translators@gnu.org>\\n"
"Language: ''' + lang + '''\\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8bit\\n"
''') 
		fd.close()
	append_sitemap_pos('<span class="topmost-title">')
	append_sitemap_pos('</span>')
	append_sitemap_pos('<span>')
	append_sitemap_pos('</a>')
	append_sitemap_pos('span.topmost-title, #content a.topmost-title '\
                           + '{ font-size: 1.3em; font-weight: bold } ' \
                           + '#content dt a { font-weight: normal } ' \
                           + '#content dt { margin: 0.1em } ' \
                           + '#content dd { margin-bottom: 0.2em }')

# Remove or replace tags that can't appear in <a> elements.
def filter_for_link (title):
	name = re.sub('<[Aa]\s[^>]*>', '', title)
	name = re.sub('</[Aa](\s[^>]*)?>', '', name)
	name = re.sub('<[Uu](\s[^>]*)?>', '<b>', name)
	name = re.sub('</[Uu](\s[^>]*)?>', '</b>', name)
	return name

# Check how outdated the translation is; return the respective tag name.
def get_outdated_tag (directory, base, lang):
	po = join_url_paths(directory, 'po')
	po = join_url_paths(po, base + '.' + lang +'.po')
	po = join_url_paths(TOP_DIRECTORY, po)
	if not os.path.exists(po):
		return 'del'
	path = join_url_paths(directory, base + '.' + lang + '.html')
	html = open(join_url_paths(TOP_DIRECTORY, path))
	try:
		for line in html:
			if line.find('<!--#set var="OUTDATED_SINCE"') >= 0:
				html.close()
				return 'em'
		html.close()
	finally:
		html.close()
	return ''

def append_translist (directory, files, base, titles):
	global translist
	global translation_linguas
	item = ''
	langs = ''
	for lang in SITE_LINGUAS:
		trans = base + '.' + lang + '.html'
		if not trans in files:
			continue
		if not lang in translation_linguas:
			translation_linguas.append(lang)
		emph_open = ''
		emph_close = ''
		emph = get_outdated_tag (directory, base, lang)
		if emph != '':
			emph_open = '<' + emph + '>'
			emph_close = '</' + emph + '>'
		path = join_url_paths(directory, trans)
		name = path
		if trans in titles:
			name = filter_for_link (titles[trans])
		if len(langs):
			langs = langs + '|'
		langs = langs + lang
		item = item + '<!--#if expr="$qs = /,' + lang \
		  + ',/" -->\n' + emph_open + '[' + lang + '] <a ' \
		  + 'hreflang="' + lang + '" lang="' + lang + '" xml:lang="' \
		  + lang + '" href="/' + path + '">\n' + name + '</a>' \
		  + emph_close + '<br /><!--#endif -->'
	if len(langs) == 0:
		return
	translist = translist + '<!--#if expr="$qs = /,(' \
		+ langs + '),/" -->'
	path = join_url_paths(directory, base) + '.html'
	translist = translist + '<dt><a href="/' + path + '">' \
		+ path + '</a></dt>\n'
	title = path
	if base + '.html' in titles:
		title = titles[base + '.html']
	trans = base + '.en.html'
	path = join_url_paths(directory, trans)
	translist = translist + '<dd><span class="original">[en] ' \
		+ '<a href="/' + path + '" hreflang="en" ' \
		+ 'lang="en" xml:lang="en">\n' + filter_for_link (title) \
		+ '</a></span><br />'
	translist = translist + item + '</dd>\n\n<!--#endif -->'

def print_map(directory, depth_level):
	directory_name = get_name_from_path(directory)
	
	# get lists of directory contents
	directory_contents = get_directory_contents(directory)
	files = directory_contents['files']
	subdirs = directory_contents['subdirectories']
	
	if not is_directory_empty(directory) \
	   or match_against_list(directory, print_always):
		titles = get_titles_for_files(directory, files)
		
		# Print a <hr /> above top-level subdirectories
		title_class = ''
		title_head = ''
		title_tail = '\n'
		if depth_level == 1:
			write('\n<hr />\n')
			title_class = ' class="topmost-title"'
			title_head = '<span' + title_class + '>' + GNUN_SPLIT
			title_tail = GNUN_SPLIT + '</span>\n'
	
		if directory != '':
			write('\n<div id="directory-' + directory.replace('/', '-') \
			      + '">')
		# Print a header unless it's not the top level directory.
		if depth_level != 0:
			index_file = get_index_filename(directory) \
					if LINK_TO_INDEX_FILES else None
			msgid = '<a' + title_class + ' href="/' \
				+ directory + '/'
			
			if index_file:
				msgid = msgid + index_file
			msgid = msgid + '">' + directory + '</a>'
			write('\n<dl><dt>' + msgid + '</dt>\n    <dd>')
			append_sitemap_pos(msgid)
			if index_file:
				if index_file in titles:
					write(title_head \
					      + titles[index_file] + title_tail)
					append_title_to_pos(index_file,
							    titles[index_file],
							    titles)
				base = index_file[ : index_file.rfind('.') ]
				append_translist (directory, files, base, titles)
			# Don't list the index file in the filelist now.
				files.remove(index_file)
		# Print "#links" to subdirectories
		# if it's the top level directory.
		if depth_level == 0:
			print_links_to_subdirs(directory, subdirs)

		# print a list of files
		if len(files) != 0:
			items = ''
			for filename in sorted(files, key = str.lower):
				if is_file_a_translation(filename):
					continue
				if filename in titles:
					title = titles[filename]
				else:
					title = ''
				msgid = '<a href="/' \
				      + join_url_paths(directory, filename) \
				      + '">' + filename + '</a>'
				base = filename[ : filename.rfind('.') ]
				items = items + '  <dt>' + msgid + '</dt>\n  <dd>' \
				      + title + '</dd>\n'
				append_sitemap_pos(msgid)
				if title != '':
					append_title_to_pos(filename, title, titles)
				append_translist (directory, files, base, titles)

			# Empty definition lists are not allowed.
			if items != '':
				write('<dl>\n' + items + '</dl>\n')

		# Print subdirectories as blocks.
		if len(subdirs) != 0:
			for subdir in sorted(subdirs, key = str.lower):
				print_map(os.path.join(directory, subdir), \
					  depth_level + 1)
		
		# Print another list of links to top level dirs.
		if depth_level == 0:
			write( '\n<hr />\n' )
			print_links_to_subdirs(directory, subdirs)
		else:
		 	write('</dd></dl>\n')
		if directory != '':
			write( '</div>\n' )
		
def read_file(filename):
	fd = open(filename, 'r')
	file_contents = fd.read()
	fd.close()
	
	return file_contents

def load_index_filenames(filename):
	filenames = {}
	fd = open(filename, 'r')
	lines = fd.read().splitlines()
	fd.close()
	for line in lines:
		line = re.sub('^\s*', '', line)
		line = re.sub('\s*$', '', line)
		if line[0] == '#':
			continue
		pos = line.rfind('/')
		if pos < 1:
			continue
		name = line[pos + 1: ]	
		directory = line[: pos]
		filenames[directory] = name
	return filenames
	
def escape_spaces(regexp_list):
	new_regexp_list = []
	
	for regexp in regexp_list:
		new_regexp_list.append(regexp.replace(' ', '\s+' ))
	
	return new_regexp_list
		
def match_against_list(string, regexp_list):
	for regexp in regexp_list:
		match = re.search(regexp, string)
		if match:
			return match
	return None
	
def write(message):
	global output_text
	output_text = output_text + message

if len(sys.argv) > 1:
	TOP_DIRECTORY = sys.argv[1]
else: 
	prog_dir = sys.argv[0]
	pos = prog_dir.rfind('/')
	prog_dir = prog_dir[ : pos] if (pos != -1) else './'
	# This script's place is /server/source/sitemap-generator/
	TOP_DIRECTORY = os.path.abspath(os.path.join(prog_dir, '../../..'))

no_index_checks = \
  read_file('directories_ignored_in_double_index_file_checks').splitlines()
print_always = \
  read_file('directories_to_print_regardless_of_emptiness').splitlines()
excluded_dirs = read_file('directories_to_skip').splitlines()
excluded_files = read_file('files_to_skip').splitlines()
index_filenames = load_index_filenames('index_files')
title_tails = \
  escape_spaces(read_file('regexps_removed_from_titles').splitlines())
replacement_titles = load_replacement_titles()
sitemap_linguas = get_sitemap_linguas()
init_sitemap_pos()

write(read_file('output.head'))
write('''



<!--

     This file is automatically generated by ''' + sys.argv[0] + '''.

     The generator is also in charge of partially updating
     the existing translations of this file.  This is why you
     should neither edit this file manually, nor commit it alone
     without merging the updates to the translations.

 -->



''')
print_map('', 0)
write(read_file('output.tail'))

output_file = open(OUTPUT_FILE_NAME, 'w')
output_file.write(output_text.encode('utf-8'))
output_file.close()

output_translations(OUTPUT_FILE_NAME)

if len(translist):
	linguas = ''
	for l in translation_linguas:
		linguas = linguas + '|' + l
	translist = '<!--#if expr="$qs = /,(' \
		+ linguas[1:] + '),/" -->\n<dl>' \
		+ translist + '</dl><!--#endif -->\n'

output_file = open(OUTPUT_FILE_NAME + '.translist', 'w')
output_file.write(translist.encode('utf-8'))
output_file.close()
