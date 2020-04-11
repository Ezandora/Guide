Guide
=====

How do I use it?
----------------
First, install it by running this command in KoLmafia's graphical CLI:

<pre>
svn checkout https://github.com/cdrock/TourGuide/branches/Release/
</pre>

Once it's installed, look in the relay browser. In the upper-right, there will be a "-run script-" menu:

![Instructions](https://raw.github.com/Ezandora/Guide/master/Images/Instructions.png)

Select Guide. Guide will install itself into the window, and will automatically update as you go along.

To update the script itself, run this command in the graphical CLI:

<pre>
svn update
</pre>

What does it do?
----------------
TourGuide is a relay script which will give advice on playing the web game [Kingdom of Loathing](http://www.kingdomofloathing.com) within [KoLmafia, a third-party tool](http://kolmafia.sourceforge.net). It details how to complete quests you're on, and what resources you have available.

During an ascension, it will inform you what you need to know to complete your ascension as quickly as possible.

The script runs side-by-side with KOL. Leave the window open, and it'll update as you go along.

Quest advice:

![Quest Example 1](https://raw.github.com/Ezandora/Guide/master/Images/Quest%20Example%201.png)
![Quest Example 2](https://raw.github.com/Ezandora/Guide/master/Images/Quest%20Example%202.png)

Reminders:

![Reminders](https://raw.github.com/Ezandora/Guide/master/Images/Reminders.png)
![Reminders 2](https://raw.github.com/Ezandora/Guide/master/Images/Reminders 2.png)
![Reminders 3](https://raw.github.com/Ezandora/Guide/master/Images/Reminders 3.png)

The script will inform you of many resources you have - free runaways, hipster fights, semi-rares, etc. - and ideas on what to use them on.

Screenshots:

[![Window picture](https://raw.github.com/Ezandora/Guide/master/Images/Window%20picture%20Small.png)](https://raw.github.com/Ezandora/Guide/master/Images/Window%20picture.png)
[![Aftercore](https://raw.github.com/Ezandora/Guide/master/Images/Aftercore%20Small.png)](https://raw.github.com/Ezandora/Guide/master/Images/Aftercore.png)
[![No IOTM character](https://raw.github.com/Ezandora/Guide/master/Images/No%20IOTM%20character%20Small.png)](https://raw.github.com/Ezandora/Guide/master/Images/No%20IOTM%20character.png)
[![BIG Day 2 end](https://raw.github.com/Ezandora/Guide/master/Images/BIG%20Day%202%20End%20Small.png)](https://raw.github.com/Ezandora/Guide/master/Images/BIG%20Day%202%20End.png)

Quests supported: All council quests, azazel, pretentious artist, untinker, legendary beat, most of the sea, unlocking the manor, the nemesis quest, pirate quest, repairing the shield generator in outer space, white citadel, the old level 9 quest, jung man's psychoses jars, and the wizard of ego.

Development guidelines
---------------------
The release above is a compiled version of the development version, which can be found by checking out https://github.com/cdrock/TourGuide/trunk/Source/ instead. If you wish to edit the script easily, start there.
The release is compiled via Compile ASH script.rb, which collects many scripts into one for ease of release.
Currently, the only guidelines are avoid visit_url(), as well as any connection to KOL's servers. This is meant to be a local application.

This script, as well as its support scripts, are in the public domain.

Contact me in-game: cdrock (#2912644)
Or in discord: cdrock7#1898
