	# 		   PlanetRSS, Version 1.3	
	# 		Copyright © 2011 Shailesh Ghadge

	#This program is free software: you can redistribute it and/or modify
 	#it under the terms of the GNU General Public License as published by
    	#the Free Software Foundation, either version 3 of the License, or
  	#(at your option) any later version.
    	#
    	#This program is distributed in the hope that it will be useful,
    	#but WITHOUT ANY WARRANTY; without even the implied warranty of
    	#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    	#GNU General Public License for more details.
    	#
    	#You should have received a copy of the GNU General Public License
    	#along with this program.  If not, see <http://www.gnu.org/licenses/>.
		
	#Email: shailesh@gnu.org 	#Version Date: 27 Apr 2011
	#
	#Functionality: Compare with previously retrieved feeds(if any) and then if required,
	#		Fetch & save 'n' feeds from planet.gnu.org using RSS feed link http://planet.gnu.org/rss20.xml in html format
	#	        Each feed is truncated to 'm' characters.
	#		User control over:- 
	#			1.retaining/removal of html tags
	#			2.number of Feeds & Feed length
	#			3.output path
	#			4.forced write
	
	
	#--------------------------------------------
	use XML::RSS::Parser::Lite;
	#Provides simple pure perl RSS parsing
        	
	use LWP::Simple;
	#Provides get(url) function
        
	use Getopt::Long;
	#Provides arguement handling 
	#---------------------------------------------  
	my $FeedLines = 3; 	# 'n' feeds
	my $FeedLength = 200;	# 'm' characters 
		
	my $PGfeeds = get("http://planet.gnu.org/rss20.xml");
	#Fetch RSS feeds as xml
	
	#Options for Sanitization (value 1 implies tag will not be stripped, any other value implies tag will be stripped)
	my $a = 1; my $b = 0;  my $code = 0; my $div = 0; my $em = 0; my $h = 0;  my $hr = 0; my $i = 0; my $img = 0; my $p = 0; my $pre = 0; my $strong = 0;  
	my $table = 0; my $textarea = 0; my $tt = 0; my $ul = 0;
	
	#Options
	my $help; my $version; my $PGpath = "planetfeeds.html"; my $f;

	#Set values as per agruements
	GetOptions("a=i" => \$a, "b=i" => \$b,  "code=i" => \$code, "div=i" => \$div, "em=i" => \$em,  "h=i" => \$h, "hr=i" => \$hr, "i=i" => \$i,"img=i" => \$img, 
		   "p=i" => \$p, "pre=i" => \$pre, "strong=i" => \$strong,  "table=i" => \$table, "textarea=i" => \$textarea, "tt=i" => \$tt, "ul=i" => \$ul, 
		   "FeedLines=i" => \$FeedLines, "FeedLength=i" => \$FeedLength, "help" => \$help, "version" => \$version, "path=s"   => \$PGpath,
		   "f" => \$f);	
		
	#------------------------------Help-------------------------------
	if($help)
	{
		print "

Usage: perl planetrss.pl [-options]
------------------------------------------------------------------------------
Defaults: 
	Number of Feeds= 3, 
	Length of Feed = 200,
	except 'a' tag, all above tags are removed.

Feed control options:
	-FeedLines=n		'n' is the number of Feeds
	-FeedLength=m		'm' is the length of Feed

Force Write:
	-f			Overwrites existing outputfile (even if the latest feed from RSS & First feed of Previous outputfile is same)

Help:
	-help

Output Path:
	-path=\"/path\"		Set the output path, 
				eg: -path=\"/www/planetfeeds.html\"
				    -path=\"../www/\"
				    -path=\"../www\"

Tag preserve options:
	-a=1		a href tag will not be removed
	-b=1		b tag will not be removed
	-code=1		code tag will not be removed
	-div=1		div tag will not be removed
	-em=1		em tag will not be removed
	-h=1		h tag will not be removed
	-hr=1		hr tag will not be removed
	-i=1		tag will not be removed
	-img=1		img tag will not be removed
	-p=1		p tag will not be removed
	-pre=1		pre tag will not be removed
	-strong=1	strong tag will not be removed
	-table=1	table,tr,th tags will not be removed
	-textarea=1	textarea tag will not be removed
	-tt=1		tt tag will not be removed
	-ul=1		ul li tags will not be removed

Tag removal options:
	Syntax same as in 'tag perserve'.
	Set value to 0 or any number other than 1.

Version Info:
	-version
------------------------------------------------------------------------------
Some Examples:
	perl planetrss.pl -f -FeedLines=7 -FeedLength=500 -path=\"../www/planetfeeds.html\"
	perl planetrss.pl -version
	perl planetrss.pl -help
	perl planetrss.pl -i=1 -hr=1 -a=0
	
\n";
		exit;
	}
	#-------------------------------End Help-----------------------------

	#-------------------------------Version------------------------------
	if($version)
	{
		print "
------------------------------------------------------------------
		   PlanetRSS, Version 1.3	
		Copyright © 2011 Shailesh Ghadge
	License: GPLv3		Contact: shailesh\@gnu.org
	Version: 1.3		Version released on: 27 April 2011
------------------------------------------------------------------\n";
		exit;
	}
	#------------------------------End Version--------------------------


        my $PGparser = new XML::RSS::Parser::Lite;
	#Create new RSS parser
	
	$PGparser->parse($PGfeeds);
	#To Parse the supplied xml

	#-----------------------------Path Check----------------------------
	if(-d $PGpath)
	{
		if(substr($PGpath,length($PGpath)-1) eq "/")
		{
			$PGpath=$PGpath."planetfeeds.html";
		}
		else
		{
			$PGpath=$PGpath."\/planetfeeds.html";
		}
	}
	#-------------------------------------------------------------------
	my $Write2File = 1; #Default: We write to PlanetFeeds.html;
	#--------------------------------Check------------------------------
	if(!$f)		# If force write flag is set, then no need to check
	{		
		my $CompareFeeds = 1;
		#open (CurPGhtml, 'planetfeeds.html') || $CompareFeeds--;
		open (CurPGhtml, $PGpath) || $CompareFeeds--;
		if($CompareFeeds == 1)
		{
			my @Cur_Content = <CurPGhtml>;
			my $Cur_Title = $Cur_Content[0];
			$Cur_Title=~ s/<(.*?)>//gi;	$Cur_Title=~ s/&lt;a(.*?)&gt;//gi; 	$Cur_Title=~ s/&lt;\/a&gt;//gi;
			$Cur_Title=~ s/&lt;p&gt;//gi;	$Cur_Title=~ s/&lt;\/p&gt;//gi;		$Cur_Title=~ s/&lt;li&gt;//gi;
			$Cur_Title=~ s/&lt;ul&gt;//gi;	$Cur_Title=~ s/&lt;br \/&gt;//gi;	$Cur_Title =~ s/\s\s+/ /g;
			$Cur_Title=substr($Cur_Title,0,index($Cur_Title,':'));
			#Now we have Current Title

			my $New_Checker = $PGparser->get(0);
			my $New_Title = $New_Checker->get('title');
			$New_Title = substr($New_Title,index($New_Title,':')+2);
			#Now we have New Title		

			if($Cur_Title eq $New_Title)
			{ 
				$Write2File=0; 
			}
			#Decide whether to continue & write PGhtml
		}
		close(CurPGhtml);
	}
	#-------------------------End of Check-----------------------------

        #print "content-type: text/html \n";
	# Use above if you get errors regarding headers        

	#---------------------To Create/Overwrite PlanetFeeds.html-----------
	if($Write2File==1)
	{
		my $PGhead= "<!-- Autogenerated File by planetrss.pl http://web.cvs.savannah.gnu.org/viewvc/www/server/source/planetrss/?root=www -->";
		#open (PGhtml, '>planetfeeds.html');
		open (PGhtml, '>'.$PGpath);
		print PGhtml $PGhead;
		#Print Feeds data in the format of- "Title - Description... <a href='URL'>more</a>"
		for (my $i = 0; $i < $FeedLines; $i++) 
		{		
			my $PGfeed = $PGparser->get($i);
			my $PGurl = $PGfeed->get('url');
			my $PGtitle = $PGfeed->get('title');
			my $PGdesc = $PGfeed->get('description');

			$PGtitle = substr($PGtitle,index($PGtitle,':')+2); #Remove Blog name			

			#constraint: atleast 12 characters space for displaying description 
			if(length($PGfeed->get('title')) >= ($FeedLength-23)) 
			{
				print PGhtml "<p><a href='".$PGurl."'>".substr($PGtitle, 0, $FeedLength) ."</a></p>\n";
			}
			else
			{		
				#Sanitize Description			
				#$PGdesc=~ s/<(.*?)>//gi;	
				$PGdesc=~ s/&lt;br \/&gt;//gi;		$PGdesc =~ s/\s\s+/ /g;#remove whitespace
				if($a!=1)
				{				
					$PGdesc=~ s/&lt;a(.*?)&gt;//gi; 	$PGdesc=~ s/&lt;\/a&gt;//gi;
				}
				if($b!=1)
				{
					$PGdesc=~ s/&lt;b&gt;//gi;	$PGdesc=~ s/&lt;\/b&gt;//gi;
				}
				if($code!=1)
				{
					$PGdesc=~ s/&lt;code&gt;//gi;	$PGdesc=~ s/&lt;\/code&gt;//gi;
				}
				if($div!=1)
				{
					$PGdesc=~ s/&lt;div(.*?)&gt;//gi;	$PGdesc=~ s/&lt;\/div&gt;//gi; 
				}				
				if($em!=1)
				{
					$PGdesc=~ s/&lt;em&gt;//gi;	$PGdesc=~ s/&lt;\/em&gt;//gi;
				}	
				if($i!=1)
				{
					$PGdesc=~ s/&lt;i&gt;//gi;	$PGdesc=~ s/&lt;\/i&gt;//gi;
				}
							
				if($img!=1)
				{
					$PGdesc=~ s/&lt;img(.*?)&gt;//gi;	$PGdesc=~ s/&lt;\/img&gt;//gi;
				}
				if($h!=1)
				{
					$PGdesc=~ s/&lt;h(.*?)&gt;//gi;	$PGdesc=~ s/&lt;\/h(.*?)&gt;//gi;
				}
				
				if($hr!=1)
				{
					$PGdesc=~ s/&lt;hr&gt;//gi;	$PGdesc=~ s/&lt;\/hr&gt;//gi;
				}				
				if($p!=1)
				{				
					$PGdesc=~ s/&lt;p&gt;//gi;	$PGdesc=~ s/&lt;\/p&gt;//gi;
				}
				if($pre!=1)
				{
					$PGdesc=~ s/&lt;pre&gt;//gi;	$PGdesc=~ s/&lt;\/pre&gt;//gi;
				}
				if($strong!=1)
				{
					$PGdesc=~ s/&lt;strong&gt;//gi;	$PGdesc=~ s/&lt;\/strong&gt;//gi;
				}
				if($table!=1)
				{				
					$PGdesc=~ s/&lt;table(.*?)&gt;//gi; 	$PGdesc=~ s/&lt;\/table&gt;//gi;
					$PGdesc=~ s/&lt;tr(.*?)&gt;//gi; 	$PGdesc=~ s/&lt;\/tr&gt;//gi;
					$PGdesc=~ s/&lt;th(.*?)&gt;//gi; 	$PGdesc=~ s/&lt;\/th&gt;//gi;
				}
				if($textarea!=1)
				{				
					$PGdesc=~ s/&lt;textarea(.*?)&gt;//gi; 	$PGdesc=~ s/&lt;\/textarea&gt;//gi;
					$PGdesc=~ s/<textarea(.*?)>//gi; 	$PGdesc=~ s/<\/textarea>//gi;
				}
				if($tt!=1)
				{
					$PGdesc=~ s/&lt;tt&gt;//gi;	$PGdesc=~ s/&lt;\/tt&gt;//gi;
				}				
				if($ul!=1)
				{				
					$PGdesc=~ s/&lt;ul(.*?)&gt;//gi; 	$PGdesc=~ s/&lt;\/ul&gt;//gi;
					$PGdesc=~ s/&lt;li(.*?)&gt;//gi; 	$PGdesc=~ s/&lt;\/li&gt;//gi;
				}
				$PGdesc=~ s/&lt;/</gi; 	$PGdesc=~ s/&gt;/>/gi;	$PGdesc=~ s/&amp;lt;/</gi; 	$PGdesc=~ s/&amp;gt;/>/gi;
				$PGdesc=~ s/&quot;/"/gi;
				#------End of Sanitization
			
				#Predict & resolve 'a' tag breaking
				if($a==1) # If a tags are included
				{
					$PGdesc_front = substr($PGdesc, 0,($FeedLength-(10+length($PGtitle))));
					$PGdesc_rear = substr($PGdesc, ($FeedLength-(10+length($PGtitle))));
					if(substr($PGdesc_front,($FeedLength-(10+length($PGtitle))-1)) eq "<") #Fix for line cut at '<'
					{
						$PGdesc_front = substr($PGdesc, 0,($FeedLength-(10+length($PGtitle)))+1);
						$PGdesc_rear = substr($PGdesc, ($FeedLength-(10+length($PGtitle)))+1);
					}					
					 
					while ($PGdesc_front =~ /<a/gi) { $start_a++ }
					while ($PGdesc_front =~ /<\/a>/gi) { $end_a++ }
					
					if($start_a != $end_a)
					{
						$PGdesc_front = $PGdesc_front.substr($PGdesc_rear,0,index($PGdesc_rear,'</a>')+4);
					}
					$PGdesc=$PGdesc_front;					
					
				}
				else # If a tags are removed
				{
					#Truncate Description
					$PGdesc = substr($PGdesc, 0,($FeedLength-(10+length($PGtitle)))); #10 characters removed for ': ' and '... more'
				}

				#Output					
				print PGhtml "<p><a href='".$PGurl."'>".$PGtitle ."</a>: ".$PGdesc. "... <a href='".$PGurl."'>more</a></p>\n";
			}
		}
		close(PGhtml); 
	}
	#------------------------------End of To Create/Overwrite PlanetFeeds.html-------------------------
	

