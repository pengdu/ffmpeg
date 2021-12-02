<h1><img src="resources/icon.png"/> AtomicParsley</h1>

Modified Win32 (x86) version of AtomicParsley, <br/>
with proper windows support (and manifest/version info/icon).

Based on jonhedgerows' build of 0.9.6-hg109.9183fff907bf with Unicode/UTF-16 support. Static-linked. 

<hr/>

<pre>
AtomicParlsey sets metadata into MPEG-4 files and derivatives supporting 3 tag
 schemes: iTunes-style, 3GPP assets and ISO defined copyright notifications.

AtomicParlsey quick help for setting iTunes-style metadata into MPEG-4 files.

General usage examples:
  AtomicParsley /path/to.mp4 -T 1
  AtomicParsley /path/to.mp4 -t +
  AtomicParsley /path/to.mp4 --artist "Me" --artwork /path/to/art.jpg
  Atomicparsley /path/to.mp4 --albumArtist "You" --podcastFlag true
  Atomicparsley /path/to.mp4 --stik "TV Show" --advisory explicit

Getting information about the file and tags:
  -T  --test        Test file for mpeg4-ishness and print atom tree
  -t  --textdata    Prints tags embedded within the file
  -E  --extractPix  Extracts pix to the same folder as the mpeg-4 file

Setting iTunes-style metadata tags
  --artist       (string)     Set the artist tag
  --title        (string)     Set the title tag
  --album        (string)     Set the album tag
  --genre        (string)     Genre tag (see --longhelp for more info)
  --tracknum     (num)[/tot]  Track number (or track number/total tracks)
  --disk         (num)[/tot]  Disk number (or disk number/total disks)
  --comment      (string)     Set the comment tag
  --year         (num|UTC)    Year tag (see --longhelp for "Release Date")
  --lyrics       (string)     Set lyrics (not subject to 256 byte limit)
  --lyricsFile   (/path)      Set lyrics to the content of a file
  --composer     (string)     Set the composer tag
  --copyright    (string)     Set the copyright tag
  --grouping     (string)     Set the grouping tag
  --artwork      (/path)      Set a piece of artwork (jpeg or png only)
  --bpm          (number)     Set the tempo/bpm
  --albumArtist  (string)     Set the album artist tag
  --compilation  (boolean)    Set the compilation flag (true or false)
  --hdvideo      (boolean)    Set the hdvideo flag (true or false)
  --advisory     (string*)    Content advisory (*values: 'clean', 'explicit')
  --stik         (string*)    Sets the iTunes "stik" atom (see --longhelp)
  --description  (string)     Set the description tag
  --longdesc     (string)     Set the long description tag
  --storedesc    (string)     Set the store description tag
  --TVNetwork    (string)     Set the TV Network name
  --TVShowName   (string)     Set the TV Show name
  --TVEpisode    (string)     Set the TV episode/production code
  --TVSeasonNum  (number)     Set the TV Season number
  --TVEpisodeNum (number)     Set the TV Episode number
  --podcastFlag  (boolean)    Set the podcast flag (true or false)
  --category     (string)     Sets the podcast category
  --keyword      (string)     Sets the podcast keyword
  --podcastURL   (URL)        Set the podcast feed URL
  --podcastGUID  (URL)        Set the episode's URL tag
  --purchaseDate (UTC)        Set time of purchase
  --encodingTool (string)     Set the name of the encoder
  --encodedBy    (string)     Set the name of the Person/company who encoded the file
  --apID         (string)     Set the Account Name
  --cnID         (number)     Set the iTunes Catalog ID (see --longhelp)
  --geID         (number)     Set the iTunes Genre ID (see --longhelp)
  --xID          (string)     Set the vendor-supplied iTunes xID (see --longhelp)
  --gapless      (boolean)    Set the gapless playback flag
  --contentRating (string*)   Set tv/mpaa rating (see -rDNS-help)

Deleting tags
  Set the value to "":        --artist "" --stik "" --bpm ""
  To delete (all) artwork:    --artwork REMOVE_ALL
  manually removal:           --manualAtomRemove "moov.udta.meta.ilst.ATOM"

More detailed iTunes help is available with AtomicParsley --longhelp
Setting reverse DNS forms for iTunes files: see --reverseDNS-help
Setting 3gp assets into 3GPP and derivative files: see --3gp-help
Setting copyright notices for all files: see --ISO-help
For file-level options and padding info: see --file-help
Setting custom private tag extensions: see --uuid-help
Setting ID3 tags onto mpeg-4 files: see --ID3-help
</pre>

<hr/>

<pre>
Version 0.9.6
- CMake Build scripts.
- Option to output MP4 atoms as XML.
- Added support for 1080p iTunes atoms (--hdvideo option also takes a number)
- Added --flavor option for setting flvr atom.
- Allow sort order fields to be set in the format of --sortOrder name=value 
- Added missing sort albumn option
- Added option for setting plID atom
</pre>
