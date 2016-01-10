//This file isn't used in guide at all, currently, but I'd thought I'd release it anyways.
//Classifies locations on whether they are adventure.php. Useful for scripts that need that information. Relevant for arrowing monsters, KOLHS, wandering monsters, semi-rare, etc.

import "relay/Guide/Support/Math.ash";

static
{
    int [location] __adventure_php_locations;
    void initialiseAdventurePHPLocations()
    {
        //Two methods:
        //Look up every snarfblat, and assign ones that have locations. (this is faster)
        //Load adventures.txt, find every adventure= entry, save those. (slower, but more accurate if they ever go past 1000 snarfblat)
        //Using the first method, because our parsing of adventures.txt isn't perfect, and it'll take a few years before we go over snarfblat=1000
        if (true)
        {
            //0.985093583 total, 0.663535898 net, 1000 invocations
            for i from 1 to 1000 //FIXME update this in a few years, we're nearing 500 or so right now
            {
                location l = i.to_location();
                if (l != $location[none])
                    __adventure_php_locations[l] = i;
            }
        }
        else
        {
            //2.571006588 total, 0.791600414 net, 1000 invocations
            //Read from adventures.txt:
            //This doesn't accurately read the file. No idea how to use file_to_map here.
            string [string,string] adventures_txt;
            file_to_map("data/adventures.txt", adventures_txt);
            //print_html("adventures_txt = " + adventures_txt.to_json());
            foreach key in adventures_txt
            {
                foreach key2 in adventures_txt[key]
                {
                    if (key2.contains_text("adventure="))
                    {
                        int snarfblat = key2.replace_string("adventure=", "").to_int_silent();
                        
                        location l = snarfblat.to_location();
                        if (l != $location[none])
                            __adventure_php_locations[l] = snarfblat;
                    }
                    //print_html("found (" + key + ")(" + key2 + ") \"" + adventures_txt[key][key2] + "\"");
                }
            }
        }
    }
    initialiseAdventurePHPLocations();
}

boolean locationVisitsAdventurePHP(location l)
{
    if (__adventure_php_locations contains l)
        return true;
    return false;
}

boolean locationAllowsWanderingMonsters(location l)
{
    if (l == $location[the shore\, inc.])
        return false;
    if (l == lookupLocation("The X-32-F Combat Training Snowman"))
        return false;
    return l.locationVisitsAdventurePHP();
}

int snarfblatForLocation(location l)
{
    if (__adventure_php_locations contains l)
        return __adventure_php_locations[l];
    return -1;
}