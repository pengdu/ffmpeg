"use strict";


const FS                = require("fs")
     ,PATH              = require("path")
     ,resolve           = function(path){ //normalize to Unix-slash (will work on Windows too).
                            path = path.replace(/\"/g,"");
                            path = path.replace(/\\+/g,"/");
                            path = PATH.resolve(path); 
                            path = path.replace(/\\+/g,"/"); 
                            path = path.replace(/\/\/+/g,"/"); 
                            return path;
                          }
     ,ARGS              = process.argv.filter(function(s){return false === /node\.exe/i.test(s) && false === /index\.js/i.test(s);})
     ,FILE_IN           = resolve(ARGS[0])
     ,FILE_IN_PARTS     = PATH.parse(FILE_IN)
     ,FILE_OUT          = resolve(FILE_IN_PARTS.dir + "/" + FILE_IN_PARTS.name + "_timestamp" + FILE_IN_PARTS.ext)
     ,DAYS              = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
     ,DAYS_SHORT        = ["Sun",    "Mon",    "Tue",     "Wed",       "Thu",      "Fri",    "Sat"]
     ,DAYS_HEBREW       = ["יום ראשון", "יום שני", "יום שלישי", "יום רביעי", "יום חמישי", "יום שישי", "יום שבת"]
     ,TEMPLATE          = "timecode=\\\'##HOUR##\\\:##MINUTE##\\\:##SECOND##\\\:00\\\':text=\\\'##DAY##-##MONTH##-##YEAR## ##DAY_OF_THE_WEEK## \\\'"

     ;


var year,month,day
   ,hour,minute,second
   ,date = new Date()
   ;

FILE_IN_PARTS.name.replace(/VID_(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})/i, function(){
         //arguments[0] --- whole match part (for example 'VID_20180617_212020')
  year   = arguments[1];
  month  = arguments[2];
  day    = arguments[3];
  hour   = arguments[4];
  minute = arguments[5];
  second = arguments[6];
         //arguments[7] --- 0
         //arguments[8] --- whole match part (for example 'VID_20180617_212020')
});


date.setFullYear(year);
date.setMonth(month-1);
date.setDate(day);
date.setHours(hour);
date.setMinutes(minute);
date.setSeconds(second);


console.log(
  TEMPLATE.replace(/##YEAR##/,            year)
          .replace(/##MONTH##/,           month)
          .replace(/##DAY##/,             day)
          .replace(/##DAY_OF_THE_WEEK##/, DAYS_HEBREW[date.getDay()].split("").reverse().join("") )     //the split-reverse-join is instead of using FFMPEG's drawtext's native 'text_shaping=1' options which doesn't work most of the times.
          .replace(/##HOUR##/,            hour)
          .replace(/##MINUTE##/,          minute)
          .replace(/##SECOND##/,          second)
);
