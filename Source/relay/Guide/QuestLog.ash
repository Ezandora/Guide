//Support for manually parsing the quest log:

record QLEntryStep
{
    string [int] possible_string_matches;
    boolean check_in_completed_log; //nemesis quest is strange - it goes into the "completed" log even though we're still in progress
};

QLEntryStep QLEntryStepMake(string [int] matches, boolean check_in_completed_log)
{
    QLEntryStep result;
    result.possible_string_matches = matches;
    result.check_in_completed_log = check_in_completed_log;
    return result;
}

QLEntryStep QLEntryStepMake(string [int] matches)
{
    return QLEntryStepMake(matches, false);
}

QLEntryStep QLEntryStepMake(string match, boolean check_in_completed_log)
{
    string [int] matches;
    matches.listAppend(match);
    return QLEntryStepMake(matches, check_in_completed_log);
}

QLEntryStep QLEntryStepMake(string match)
{
    return QLEntryStepMake(match, false);
}

boolean QLEntryStepMatchesLog(QLEntryStep step, string in_progress_log)
{
    foreach key in step.possible_string_matches
    {
        string possible_match = step.possible_string_matches[key];
        if (in_progress_log.contains_text(possible_match))
            return true;
    }
    return false;
}

void listAppend(QLEntryStep [int] list, QLEntryStep entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}


record QuestLogEntry
{
    string exists_in_log_match_string;
    
	string property_name;
	QLEntryStep [int] steps;
    QLEntryStep completed_step;
};

int QuestLogEntryCurrentStep(QuestLogEntry entry)
{
    string completed_log = get_property("__relay_guide_last_quest_log_2");
    if (entry.completed_step.possible_string_matches.count() > 0)
    {
        if (QLEntryStepMatchesLog(entry.completed_step, completed_log))
            return INT32_MAX;
    }
    else
    {
        if (completed_log.contains_text(entry.exists_in_log_match_string))
            return INT32_MAX;
    }
        
    string in_progress_log = get_property("__relay_guide_last_quest_log_1");
    boolean quest_in_progress_log = in_progress_log.contains_text(entry.exists_in_log_match_string);
    
    int highest_step = 0;
    //Parse:
    foreach key in entry.steps
    {
        QLEntryStep step = entry.steps[key];
        boolean step_matches = false;
        if (step.check_in_completed_log)
            step_matches = step.QLEntryStepMatchesLog(completed_log);
        else if (quest_in_progress_log)
            step_matches = step.QLEntryStepMatchesLog(in_progress_log);
        if (step_matches)
        {
            highest_step = key + 1;
            break;
        }
    }
    return highest_step;
}

record QuestLog
{
    QuestLogEntry [string] tracked_entries;
};


QuestLog __quest_log;
boolean __quest_log_initialized = false;


void QuestLogPrivateInit()
{
	if (__quest_log_initialized)
		return;
	__quest_log_initialized = true;
	
    if (true)
    {
        //a dark and dank and sinister quest:
        QuestLogEntry entry;
        entry.property_name = "questG05Dark";
        entry.exists_in_log_match_string = "A Dark and Dank and Sinister Quest";
        entry.steps.listAppend(QLEntryStepMake("Finally it's time to meet this Nemesis you've been hearing so much about! The guy at your guild has marked your map with the location of a cave in the Big Mountains, where your Nemesis is supposedly hiding."));
        entry.steps.listAppend(QLEntryStepMake("Having opened the first door in your Nemesis' cave, you are now faced with a second one. Go figure"));
        entry.steps.listAppend(QLEntryStepMake("Having opened the second door in your Nemesis' cave, you are now"));
        entry.steps.listAppend(QLEntryStepMake("Woo! You're past the doors and it's time to stab some bastards"));
        entry.steps.listAppend(QLEntryStepMake("The door to your Nemesis' inner sanctum didn't seem to care for the password you tried earlier"));
        entry.steps.listAppend(QLEntryStepMake("Hear how the background music got all exciting? It's because you opened the door to your Nemesis' inner sanctum"));
        //entry.steps.listAppend(QLEntryStepMake("Your Nemesis has scuttled away in defeat, leaving you with a sweet Epic Hat and a feeling of smug superiority"));
        
        
        __quest_log.tracked_entries[entry.property_name] = entry;
    }
    if (true)
    {
        //Nemesis quest:
        
        QuestLogEntry entry;
        entry.property_name = "questG04Nemesis";
        entry.exists_in_log_match_string = "Me and My Nemesis";
        
        entry.steps.listAppend(QLEntryStepMake("One of your guild leaders has tasked you to recover a mysterious and unnamed artifact stolen by your Nemesis. Your first step is to smith an Epic Weapon"));
        entry.steps.listAppend(QLEntryStepMake("To unlock the full power of the Legendary Epic Weapon, you must defeat Beelzebozo, the Clown Prince of Darkness,"));
        entry.steps.listAppend(QLEntryStepMake("You've finally killed the clownlord Beelzebozo"));
        entry.steps.listAppend(QLEntryStepMake("You've successfully defeated Beelzebozo and claimed the last piece of the Legendary Epic Weapon"));
        entry.steps.listAppend(QLEntryStepMake("discovered where your Nemesis is hiding. It took long enough, jeez! Anyway, turns out it's a Dark and"));
        entry.steps.listAppend(QLEntryStepMake("You have successfully shown your Nemesis what for, and claimed an ancient hat of power. It's pretty sweet"));
        entry.steps.listAppend(QLEntryStepMake("You showed the Epic Hat to the class leader back at your guild, but they didn't seem much impressed. I guess all this Nemesis nonsense isn't quite finished yet, but at least with your Nemesis in hiding again you won't have to worry about it for a while.", true));
        entry.steps.listAppend(QLEntryStepMake("It appears as though some nefarious ne'er-do-well has put a contract on your head"));
        entry.steps.listAppend(QLEntryStepMake("You handily dispatched some thugs who were trying to collect on your bounty, but something tells you they won't be the last ones to try"));
        entry.steps.listAppend(QLEntryStepMake("Whoever put this hit out on you (like you haven't guessed already) has sent Mob Penguins to do their dirty work. Do you know any polar bears you could hire as bodyguards"));
        entry.steps.listAppend(QLEntryStepMake("So much for those mob penguins that were after your head! If whoever put this hit out on you wants you killed (which, presumably, they do) they'll have to find some much more competent thugs"));
        entry.steps.listAppend(QLEntryStepMake("have been confirmed: your Nemesis has put the order out for you to be hunted down and killed, and now they're sending their own guys instead of contracting out"));
        entry.steps.listAppend(QLEntryStepMake("Bam! So much for your Nemesis' assassins! If that's the best they've got, you have nothing at all to worry about"));
        entry.steps.listAppend(QLEntryStepMake("You had a run-in with some crazy mercenary or assassin or... thing that your Nemesis sent to do you in once and for all. A run-in followed by a run-out, evidently, "));
        entry.steps.listAppend(QLEntryStepMake("Now that you've dealt with your Nemesis' assassins and found a map to the secret tropical island volcano lair, it's time to take the fight to your foe. Booyah"));
        entry.steps.listAppend(QLEntryStepMake("You've arrived at the secret tropical island volcano lair, and it's time to finally put a stop to this Nemesis nonsense once and for all. As soon as you can find where they're hiding. Maybe you can find someone to ask"));
        
        if (true)
        {
            string [int] custom_step_strings;
            custom_step_strings.listAppend("Well, you defeated Gorgolok, but he got away. Again. Funny how he keeps escaping from you when he can't really run with those flippers");
            custom_step_strings.listAppend("Well, you defeated Stella, but she got away. Again. Is ninja training part of the standard poacher skill-set");
            custom_step_strings.listAppend("Well, you defeated the Spaghetti Elemental, but it got away. Again. Never have you met such an elusive noodle");
            custom_step_strings.listAppend("Well, you defeated Lumpy, but it got away. Again. Curse his viscous nature");
            custom_step_strings.listAppend("but he got away. Again. Who would've thought it was so difficult to kill a non-corporeal personification of a particular style of music");
            custom_step_strings.listAppend("Well, you defeated Lopez, but he got away. Again. Man, that guy is as hard to kill");
            entry.steps.listAppend(QLEntryStepMake(custom_step_strings));
        }
        entry.steps.listAppend(QLEntryStepMake("Congratulations on solving the lava maze, which is probably the biggest pain-in-the-ass puzzle in the entire game! Hooray! (Unless you cheated, in which case"));
        entry.steps.listAppend(QLEntryStepMake("have some sort of crazy powerful and hideous final form? I was, but then I wrote all of this,"));
        
        if (true)
        {
            string [int] custom_step_strings;
            custom_step_strings.listAppend("the Infernal Seal Gorgolok has fallen beneath your mighty assault. Never again will the");
            custom_step_strings.listAppend("Stella the Turtle Poacher has fallen beneath your mighty assault. Never again will the helpless ");
            custom_step_strings.listAppend(" evil Spaghetti Elemental has fallen beneath your mighty assault. Never again will the ");
            custom_step_strings.listAppend("Sinister Sauceblob has fallen beneath your mighty assault. Now the people of the Kingdom");
            custom_step_strings.listAppend("Spirit of New Wave has fallen beneath your mighty assault. Now the disco-loving people");
            custom_step_strings.listAppend("Somerset Lopez has fallen beneath your mighty assault. Now the eons-long ");
            entry.completed_step = QLEntryStepMake(custom_step_strings);
        }
        
        __quest_log.tracked_entries[entry.property_name] = entry;
    }
    
    if (true)
    {
        //hey hey
        QuestLogEntry entry;
        entry.property_name = "questS02Monkees";
        entry.exists_in_log_match_string = "Hey, Hey, They're Sea Monkees";
        entry.steps.listAppend(QLEntryStepMake("You rescued a strange, monkey-like creature from a Neptune Flytrap."));
        entry.steps.listAppend(QLEntryStepMake("Little Brother, the Sea Monkee, has asked you to find his older brother"));
        entry.steps.listAppend(QLEntryStepMake("You've rescued Little Brother's big brother, Big Brother. You should go talk to him"));
        entry.steps.listAppend(QLEntryStepMake("You've rescued Big Brother, who has agreed to sell you some stuff as a"));
        entry.steps.listAppend(QLEntryStepMake("Little Brother has asked you to rescue his grandpa. He says that Grandpa has been "));
        entry.steps.listAppend(QLEntryStepMake("You've rescued Grandpa, and he's got lots and lots of stories to tell"));
        //emptiness
        
        __quest_log.tracked_entries[entry.property_name] = entry;
    }
}

boolean QuestLogTracksProperty(string property_name)
{
	QuestLogPrivateInit();
    
    if (__quest_log.tracked_entries contains property_name)
        return true;
	return false;
}

string QuestLogLookupProperty(string property_name)
{
	QuestLogPrivateInit();
    
    if (!(__quest_log.tracked_entries contains property_name))
        return "";
    
	
	int step = __quest_log.tracked_entries[property_name].QuestLogEntryCurrentStep();
    
    if (step <= 0)
        return "unstarted";
    if (step == 1)
        return "started";
    if (step == INT32_MAX)
        return "finished";
    
    return "step" + (step - 1);
}

string [int] QuestLogTrackingProperties()
{
    string [int] result;
	QuestLogPrivateInit();
    foreach s in __quest_log.tracked_entries
    {
        result.listAppend(s);
    }
    return result;
}