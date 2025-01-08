# LWA
LWA Application code


### For developers

#### Translations

run `npm run translations -- <command> <source language> <key> <...string>`

##### Available commands:
 - `key`: adds a new key to a translation file and translates that same key to all the others:<br>
eg: `npm run translations -- key en leaflet_print Prints some things`

 - `add`: adds a new translation file using a source to translate everything:<br>
   (not implemented)

LIMITATIONS: This does not properly translate HTML, just plain strings