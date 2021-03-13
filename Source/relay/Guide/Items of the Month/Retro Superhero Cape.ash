
RegisterGenerationFunction("IOTMRetroSuperheroCapeGenerate");
void IOTMRetroSuperheroCapeGenerate(ChecklistCollection checklists)
{
	item cape = lookupItem("unwrapped knock-off retro superhero cape");
	if (!cape.have()) return;
	
	
	/*
	√List the current name because that is a nightmare to deal with when in the inventory.
	-suggestion in L7 code
     */
     
    string superhero_major = get_property("retroCapeSuperhero"); //Valid values: "vampire", "heck", or "robot"
    string superhero_minor = get_property("retroCapeWashingInstructions"); //Valid values: "hold", "thrill", "kiss", or "kill"
    string image_name = "__item unwrapped knock-off retro superhero cape";
    string url = "inventory.php?action=hmtmkmkm";
    
    string title = "Superhero Cape";
    string [int] description;
    
    
    string [string][string] various_cape_effects =
    {
    	"vampire":{"hold":"+3 all res.",
        	"thrill":"+3 muscle stats/fight.",
        	"kiss":"20% HP drain combat skill, once/fight. (Smooch of the Daywalker)",
        	"kill":"Anti-undead combat skill, removes extra Cyrpt evil. (Slay the Dead)"},
         
    	"heck":{"hold":"Three-round stun at fight start.",
        	"thrill":"+3 myst stats/fight.",
        	"kiss":"Yellow-Ray combat skill. (Unleash the Devil's Kiss)",
        	"kill":"Doubles your spell damage as spooky."},
         
    	"robot":{"hold":"20% monster attack reduction combat skill, once/fight. (Deploy Robo-Handcuffs)",
        	"thrill":"+3 moxie stats/fight.",
        	"kiss":"Sleaze damage combat skill, reusable. (Blow a Robo-Kiss)",
        	"kill":"Critical hit combat skill, gun-only, once/fight. (Precision Shot)"},
         
    };
    string [string] intrinsic_cape_effect =
    {
    	"vampire":"+30% muscle, +50 HP",
    	"heck":"+30% myst, +50 MP",
    	"robot":"+30% moxie, +25 HP/MP",
    };
    
    
    string [string] full_superhero_names =
    {
    	"vampire":"Vampire Slicer",
    	"heck":"Heck General",
    	"robot":"Robot Police",
    };
    
    
    string cape_name = "Contessa"; //the true patron cape of all speed ascenders. mine is dragon!
    if (superhero_major == "vampire")
    	cape_name = "Vampire Slicer trench cape";
    else if (superhero_major == "heck")
    	cape_name = "Heck General cloak";
    else if (superhero_major == "robot")
    	cape_name = "Robot Police cape";
    else
    	cape_name = "unwrapped knock-off retro superhero cape";
     
    title = cape_name + " (Superhero Cape)";
    
    //FIXME image? it would require direct URL
     
    string current_effect_description = various_cape_effects[superhero_major][superhero_minor];
    
    if (current_effect_description != "")
    {
    	description.listAppend("Now: " + current_effect_description);
    }
    
    
    if (cape.equipped_amount() == 0)
    {
    	//Weirdly, ftext uses actual item name, not display name.
    	//url = "inventory.php?which=2&ftext=" + cape_name.replace_string(" ", "+");
     	url = "inventory.php?which=2&ftext=unwrapped+knock-off+retro+superhero+cape";
    }
    
    if ($effect[everything looks yellow].have_effect() == 0 && !(superhero_major == "heck" && superhero_minor == "kiss"))
    {
    	description.listAppend("Could switch over to Heck General/Kiss for a yellow-ray.");
    }
    
    if (superhero_major == "vampire" && superhero_minor == "kill")
    {
    	string [int] tasks;
        if (!cape.equipped())
        {
        	tasks.listAppend("equip the cape");
        }
        if ($slot[weapon].equipped_item().item_type() != "sword")
        {
        	tasks.listAppend("equip a sword in your mainhand");
        }
        if ($effect[Iron Palms].have_effect() != 0)
        {
        	tasks.listAppend("cast iron palm technique");
        }
        if (tasks.count() > 0)
        	description.listAppend("To use the skill, " + HTMLGenerateSpanFont(tasks.listJoinComponents(", ", "and"), "red") + ".");
    }
    
    //description.listAppend("Currently named \"" + cape_name + "\" in inventory."); //too wordy, moved to title
    
    buffer cape_effects_buf;
    
    boolean first = true;
    foreach iterating_cape_major in $strings[vampire,heck,robot]
    {
    	if (first)
        	first = false;
        else
        	cape_effects_buf.append("<hr>");
    	cape_effects_buf.append("<strong style=\"font-size:1.5em;\">");
        cape_effects_buf.append(full_superhero_names[iterating_cape_major].capitaliseFirstLetter());
        cape_effects_buf.append("</strong>");
        if (iterating_cape_major == superhero_major)
        	cape_effects_buf.append(" (current)");
        cape_effects_buf.append("<div class=\"r_indention\">");
        cape_effects_buf.append(intrinsic_cape_effect[iterating_cape_major]);
        cape_effects_buf.append(".");
        cape_effects_buf.append("<hr></div>");
        
        
    	//foreach iterating_cape_minor in various_cape_effects[iterating_cape_major]
     
     	string [int][int] subtable;
        foreach iterating_cape_minor in $strings[hold,thrill,kiss,kill]
        {
        	string effect_description = various_cape_effects[iterating_cape_major][iterating_cape_minor];
            
            string [int] subtable_line;
            subtable_line.listAppend("<strong>" + iterating_cape_minor.capitaliseFirstLetter() + "</strong>");
            string secondary_line = effect_description + ".";
            if (iterating_cape_major == superhero_major && iterating_cape_minor == superhero_minor)
                secondary_line += " (current)";
            subtable_line.listAppend(secondary_line);
            subtable.listAppend(subtable_line);
            /*continue;
            
            cape_effects_buf.append("<div class=\"r_indention\">");
            cape_effects_buf.append("<strong>");
            cape_effects_buf.append(iterating_cape_minor.capitaliseFirstLetter());
            cape_effects_buf.append(" Me</strong>: ");
            
        	cape_effects_buf.append(effect_description);
            if (iterating_cape_major == superhero_major && iterating_cape_minor == superhero_minor)
                cape_effects_buf.append(" (current)");
            
            
            cape_effects_buf.append("</div>");*/
        }
        
        cape_effects_buf.append("<div class=\"r_indention\">");
        cape_effects_buf.append(HTMLGenerateSimpleTableLines(subtable));
        cape_effects_buf.append("</div>");
    }
    
    description.listAppend(HTMLGenerateTooltip("Mouse over for full cape effects.", cape_effects_buf.to_string()));
    
    
    
    
    checklists.add(C_RESOURCES, ChecklistEntryMake(572, image_name, url, ChecklistSubentryMake(title, "", description), 1)).ChecklistEntrySetCategory("equipment").ChecklistEntrySetAbridgedHeader("Superhero cape");
    
}
