Guide.ash
=========

What does it do?
----------------
Guide.ash is a relay script which will give advice on playing the web game [Kingdom of Loathing](http://www.kingdomofloathing.com) within [KoLmafia, a third-party tool](http://kolmafia.sourceforge.net).
During an ascension, it will tell you what you need to know to complete your ascension as quickly as possible.
The script runs side-by-side with KOL. Leave the window open, and it'll update as you go along.

Example UI:

[![Window picture](https://raw.github.com/Ezandora/Guide/master/Images/Window%20picture%20Small.png)](https://raw.github.com/Ezandora/Guide/master/Images/Window%20picture.png)


Many quests are supported:

![Quest Example 1](https://raw.github.com/Ezandora/Guide/master/Images/Quest%20Example%201.png)
![Quest Example 2](https://raw.github.com/Ezandora/Guide/master/Images/Quest%20Example%202.png)

Reminders are given for many complex tasks:
![Reminders](https://raw.github.com/Ezandora/Guide/master/Images/Reminders.png)

The script will inform you of many resources you have - free runaways, hipster fights, semi-rares, etc. - and ideas on what to use them on.
There is preliminary support for the florist friar and what to pull.

It also works in aftercore:

[![Aftercore](https://raw.github.com/Ezandora/Guide/master/Images/Aftercore%20Small.png)](https://raw.github.com/Ezandora/Guide/master/Images/Aftercore.png)

In-run screenshots:

[![No IOTM character](https://raw.github.com/Ezandora/Guide/master/Images/No%20IOTM%20character%20Small.png)](https://raw.github.com/Ezandora/Guide/master/Images/No%20IOTM%20character.png)
[![BIG Day 2 end](https://raw.github.com/Ezandora/Guide/master/Images/BIG%20Day%202%20End%20Small.png)](https://raw.github.com/Ezandora/Guide/master/Images/BIG%20Day%202%20End.png)

Quests supported: All council quests, azazel, pretentious artist, untinker, legendary beat, most of the sea, unlocking the manor, the nemesis quest, pirate quest, repairing the shield generator in outer space, white citadel, the old level 9 quest, and the wizard of ego.

How do I use it?
----------------
First, install it by running this command in KoLmafia's graphical CLI:

<pre>
svn checkout https://github.com/Ezandora/Guide/branches/Release/
</pre>

Once it's installed, look in the relay browser. In the upper-right, there will be a "-run script-" menu:

![Instructions](https://raw.github.com/Ezandora/Guide/master/Images/Instructions.png)

Select Guide. There will be a link to open it in a new window - click it.
Then, leave the guide window open as you adventure. It'll update automatically.

To update the script itself, run this command in the graphical CLI:

<pre>
svn update
</pre>

Development guidelines
---------------------
The release above is a compiled version of the development version, which can be found by checking out https://github.com/Ezandora/Guide/trunk/Source/ instead. If you wish to edit the script easily, start there.
The release is compiled via Compile ASH script.rb, which collects the seventy or so scripts into one for ease of release.
Currently, the only guidelines are avoid visit_url(), as well as any connection to KOL's servers. This is meant to be a local application.

This script, as well as its support scripts, are in the public domain.

Contact me in-game: Ezandora (#1557284)
