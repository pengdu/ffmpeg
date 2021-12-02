<h1>Adding a proper 24-clock timestamp to videos</h2>

The <a href="https://www.apkmirror.com/apk/samsung-electronics-co-ltd/samsung-camera/">Samsung camera</a> app, <a href="https://www.apkmirror.com/apk/mark-harman/open-camera/">open-camera</a> by Mark Harman, <br/>
and various camera-devices prefer the video-naming of <code>VID_yyyymmdd_hhMMss</code>, <br/>

using <a href="https://ffmpeg.zeranoe.com/builds/">FFMPEG</a>'s <a href="https://ffmpeg.org/ffmpeg-filters.html#drawtext-1">drawtext filter</a> with <code>timecode</code>
<code>text</code> arguments to write the timestamp on the video.

The magic happens when the <code>timecode</code> is not formatted to the default <code>00:00:00:00</code>, <br/>
but to a specific starting-time (yes it is possible, <strong>and NOT documented at all as it should!</strong>).

the formatting I'm doing in a little NodeJS script, <br/>
just for avoiding any BASH, CMD string parsing (which is living-hell), <br/>
in-favor of the JavaScript leisurely RegExp. :]

<hr/>

<pre>
VID_20180618_002026.mp4 is:

year:  2018
month:   06
day:     18
hour:    00  (12PM/midnight in 24-hour clock)
minutes: 20
seconds: 26

</pre>

now- the year, month and day I actually use in the <code>timecode</code>, since it is not designed to this matter.
but I can format it as an additional string, placed near the <code>timecode</code> using the <code>text</code> parameter of the <code>drawtext</code>-filter, <br/>
sadly it does means that when the clock changes to a new day after <code>23:59:59</code>, it still looks like the previous day :[

for now, either go with it, and add a remark to yourself that this is the next day, <br/>
or simply try to break the video into before and after 12PM, renaming the parts manually yourself, <br/>
using the proper naming convention.

For example: a 20 minute video <code>VID_20180618_235000.mp4</code> can be break into:<br/>
a 9 minute, 59 seconds video <code>VID_20180618_235000.mp4</code> (up until 23:59:59) and <br/>
<code>VID_2018061<strong>9</strong>_000000.mp4</code> (or explicitly <code>VID_2018061<strong>9</strong>_00000<strong>1</strong>.mp4</code> for the sake of readability).

<hr/>

The NodeJS script also adds a Hebrew day-of-the-week (English short/full alternative exist too), <br/>
you may extend the script to include a verbosed month too, and any other text for that matter, <br/>
but it takes too much space and it isn't really that useful.

Instead of ISO or UTC format I'm (consistently) using a more-common date format (for native Hebrew readers), <br/>
where the day is first to the left followd by month and full 4 digit year (<code>ddmmyyy</code>). <br/>
again, this can be easily changed,<br/>
plus I'm using a <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date">JavaScript Date</a> object to parse the date anyway, so you can use the native methods to get ISO or UTC formats, and leaving just the date. <br/>

The <code>drawtext</code>'s <code>timecode</code> parameter its own time format you can't change.

<hr/>

Since you need to sync the frame-rate to match the actual-clock <em>Second</em>, <br/>
which needed to be injected to another <code>drawtext</code>'s parameter as well (<code>timecode_rate</code>), <br/>
I'm using <code>FFPROBE</code> to grab some information before the actual run of <code>FFMPEG</code>.

<hr/>

<h2>How to run?</h2>

For example, this: 
<h3><code>ffmpeg_timestamp.cmd "C:\Users\Elad\Desktop\VID_20180618_002026.mp4"</code></h3>

which (finally) will get a FFMPEG command similar to this (adding some whitespaces for readability)
<pre>
"D:\Software\FFMPEG\ffmpeg.exe"  -y -hide_banner -strict experimental 
-i "C:\Users\Elad\Desktop\VID_20180618_002026.mp4" -preset veryfast -codec:a copy 
-vf "fifo,setpts=PTS-STARTPTS,fps=25,
     drawtext=:fontfile=\'courbd.ttf\':fontcolor=yellow
     :alpha=0.6:fontsize=13:y=(text_h-line_h+3)
     :timecode_rate=30
     :timecode=\'00\:20\:26\.000\'
     :text=\'18-06-2018 ינש םוי \'" 
-pix_fmt "yuv420p"
</pre>

<hr/>

Font used is either <code>cour.ttf</code> or <code>courbd.ttf</code> (Courier New/Bold),<br/>
from the same folder. its path is converted to Unix-like-slash which works better with FFMPEGs "internals".


 "C:\Users\Elad\Desktop\_res\cam\VID_20180618_002026_timestamp.mp4"
Input #0, mov,mp4,m4a,3gp,3g2,mj2, from 'C:\Users\Elad\Desktop\_res\cam\VID_20180618_002026.mp4

the NodeJS writes a part of the <code>drawtext</code>-filter arguments to the STDOUT, <br/>
which the <code>ffmpeg_timestamp.cmd</code> collects, and integrates into the FFMPEG command-like.

timecode=\\\'" + h + "\\\:" + min + "\\\:" + s + "\\\:" + "00" + "\\\'"
 +":"
 +"text

drag and drop any file over 'ffmpeg_timestamp.cmd'

it will generate a new video file with an additional left-bottom-overlay of the true timestamp.

assuming the video name is    .

samsung/opencamera apps usually use this format,
it says "when the video was started recording".

using this information I'm using FFMPEG w/ drawtext filter to add a useful overlay so when browsing the video you could know when the events-shown in the video happended, "calander like".

note that if the day-date will stay the same, the time will be updated. so 11:59 + 2 minutes will not change Sunday to Monday... (for example)