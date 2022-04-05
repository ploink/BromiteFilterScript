# Bromite Filterscript

This is a simple bash script to download adblock filter lists and create a custom filters.dat for Bromite webbrowser.
For more information, please read [Bromite Custom Ad Block filters](https://www.bromite.org/custom-filters).

# Installation
* You need to download only 2 files:
```bash
curl -OL 'https://raw.githubusercontent.com/ploink/BromiteFilterScript/master/makefilters.sh'
curl -OL 'https://raw.githubusercontent.com/ploink/BromiteFilterScript/master/filters.conf.dist'
chmod +x makefilters.sh
```
Or checkout from git:
```git clone "https://github.com/ploink/BromiteFilterScript.git"
```
* When run for the first time, it creates filters.conf from the dist file
* Edit filters.conf and comment out any filter lists and/or add other lists as desired.
* Run makefilters.sh. It will download the ruleset_converter if not already present.
* Place the generated filters.dat somewhere on you webserver and configure Bromite to download it.
* Enjoy
* You may want to create a cron job to automate filter updates 
