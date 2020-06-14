
//moonTuned
RegisterResourceGenerationFunction("IOTMRuneSpoonGenerateResource");
void IOTMRuneSpoonGenerateResource(ChecklistEntry [int] resource_entries)
{
	item spoon = lookupItem("hewn moon-rune spoon");
	if (!spoon.have() && spoon.closet_amount() == 0) return;
	
	if (!get_property_boolean("moonTuned"))
	{
		stat [string] stat_for_sign = 
        {
        	"Mongoose":$stat[Muscle],
            "Wallaby":$stat[Mysticality],
            "Vole":$stat[Moxie],
            
            "Platypus":$stat[Muscle],
            "Opossum":$stat[Mysticality],
            "Marmot":$stat[Moxie],
            
            "Wombat":$stat[Muscle],
            "Blender":$stat[Mysticality],
            "Packrat":$stat[Moxie],
        };
		string [string] signs = 
        {
            "Mongoose":"+20% physical damage, knoll access, and free smithing",
            "Wallaby":"+20% spell damage, knoll access, and free smithing",
            "Vole":"+20% init, knoll access, and free smithing",
            
            "Platypus":"+5 familiar weight and canadia access",
            "Opossum":"+5 adventures/day from food and canadia access",
        	"Marmot":"+1 extra clover/day and canadia access",
            
            "Wombat":"+20% meat and gnome access",
            "Blender":"+5 adventures/day from drinks and gnome access",
            "Packrat":"+10% item and gnome access",
            
        };
        boolean [string] signs_to_output_as_ideas = $strings[Marmot,Platypus,Opossum,Blender,Packrat];
        
        if (!__misc_state["in run"])
        	signs_to_output_as_ideas = $strings[Platypus,Opossum,Wombat,Blender,Packrat];
        boolean our_sign_is_currently_good_for_stats = stat_for_sign[my_sign()] == my_primestat();
		string [int] description;
        description.listAppend("Use the hewn moon-rune spoon. Lets you switch to any other moon sign.");
        if ($strings[Mongoose,Wallaby,Vole] contains my_sign())
        {
        	string [int] todo;
        	if (!__misc_state["desert beach available"])
        		todo.listAppend("assemble a bitchin' meatcar");
            if (!have_outfit_components("Bugbear Costume"))
                todo.listAppend("buy a bugbear costume");
            if (todo.count() > 0)
            	description.listAppend("May want to " + todo.listJoinComponents(", ", "and") + " before switching signs.");
        }
        string [int] options;
        
        foreach sign, desc in signs
        {
        	if (my_sign() == sign) continue;
            if (!signs_to_output_as_ideas[sign]) continue;
            if (sign == "Platypus" && __misc_state["familiars temporarily blocked"]) continue;
            if (sign == "Opossum" && (!__misc_state["can eat just about anything"] || my_path_id() == PATH_SLOW_AND_STEADY)) continue;
            if (sign == "Blender" && (!__misc_state["can drink just about anything"] || my_path_id() == PATH_SLOW_AND_STEADY)) continue;
        	boolean this_sign_is_good_for_mainstat_gain = stat_for_sign[sign] == my_primestat();
            string line = "<strong>" + sign + "</strong>: " + desc + ".";
            if (!this_sign_is_good_for_mainstat_gain && __misc_state["need to level"] && __misc_state["in run"])
            	line += " <strong>Won't</strong> give mainstat gains.";
            else if (this_sign_is_good_for_mainstat_gain && __misc_state["need to level"] && __misc_state["in run"])
            	line += " <strong>Will</strong> give mainstat gains."; 
        	options.listAppend(line);
        }
        
        description.listAppend("Currently " + my_sign() + ": " + signs[my_sign()] + ".");
        if (options.count() > 0)
	        description.listAppend("Ideas:|*" + options.listJoinComponents("<hr>"));
        
        string url = "inv_use.php?whichitem=10254&pwd=" + my_hash();
        if (!spoon.have() && spoon.closet_amount() > 0)
        	url = "closet.php?which=2";
		resource_entries.listAppend(ChecklistEntryMake("__item " + spoon, url, ChecklistSubentryMake("Moon sign tunable", "", description), 10));
	}
}
