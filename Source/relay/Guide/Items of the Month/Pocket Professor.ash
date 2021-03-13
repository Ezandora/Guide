
RegisterGenerationFunction("IOTMPocketProfessorGenerate");
void IOTMPocketProfessorGenerate(ChecklistCollection checklists)
{
	if (!$familiar[pocket professor].familiar_is_usable()) return;
	/*
	Three lectures:
	-velocity: devels monster, gives stats. should we even mention it...?
	-mass: increases item drops?
	-relativity: chained combat, can burn delay in areas with >= 2 delay or more
	
	"%fn, deliver your thesis!" is available when the pocket professor has >= 400 experience (20lb). Removes 200 experience, gives 2-11 adventures depending on monster HP.
	
	The wiki's explanation of the memory chip seems... complex? Like, it seems to imply that it isn't just a flat +2 lectures, instead doing Strange Things that somehow involve memory of when you used the memory chip? I suppose I should ask erosionseeker, the editor.
     */
     
    //_pocketProfessorLectures
    
    //X lectures, description
    //Thesis delivery?
    //Handle (astral pet sweater on professor) -> (memory chip)
    
    int pocket_professor_lectures_property_value = get_property_int("_pocketProfessorLectures");
    int familiar_weight_for_next_lecture = pocket_professor_lectures_property_value * pocket_professor_lectures_property_value + 1;
    if ($item[Pocket Professor memory chip].have())
    	familiar_weight_for_next_lecture = MAX(1, (pocket_professor_lectures_property_value - 2) * (pocket_professor_lectures_property_value - 2) + 1); //is this right?
    
    //familiar_equipped_equipment(my_familiar()).numeric_modifier("familiar weight")
    
    //How to handle this calculation?
    //numeric_modifier("familiar weight"); gives the familiar weight - base weight
    //(also the feast)
    //$item[hypodermic needle].numeric_modifier("familiar weight") is 5.0. does it affect numeric_modifier("familiar weight")
    //int familiar_weight_from_familiar_equipment = $slot[familiar].equipped_item().numeric_modifier("familiar weight");
    
    //effective_familiar_weight
    int estimated_professor_weight = -1;
    if (my_familiar() == $familiar[pocket professor])
    {
    	estimated_professor_weight = $familiar[pocket professor].effective_familiar_weight() + numeric_modifier("familiar weight");
        if ($item[Pocket Professor memory chip].have())
        {
        	item current_familiar_equipped_equipment = $familiar[pocket professor].familiar_equipped_equipment();
            /*if (current_familiar_equipped_equipment != $item[Pocket Professor memory chip])
            {
            	estimated_professor_weight -= current_familiar_equipped_equipment.numeric_modifier("familiar weight"); 
            }*/
        }
    }
    else
    {
    	estimated_professor_weight = $familiar[pocket professor].effective_familiar_weight() + numeric_modifier("familiar weight");
        item current_familiar_equipped_equipment = my_familiar().familiar_equipped_equipment();
        if (current_familiar_equipped_equipment == my_familiar().familiar_equipment()) //Test if its bonus is limited to this familiar. Note: is this always true? bugbear?
        {
        	estimated_professor_weight -= current_familiar_equipped_equipment.numeric_modifier("familiar weight"); 
        }
        //we can't have the familiar weight if we're chipping
        else if ($familiar[pocket professor].familiar_equipped_equipment() == $item[Pocket Professor memory chip])
        {
        	estimated_professor_weight -= current_familiar_equipped_equipment.numeric_modifier("familiar weight");
        }
        if (false)
        {
        	//this was going to be code for like, let's say you have the astral pet sweater in inventory, but your current familiar didn't have it equipped
            //add that to the estimate
            //but, that would be confusing because it isn't what you have right now, at this moment, if you switch over
            //so no
            int current_familiar_equipped_equipment_familiar_weight_increase = current_familiar_equipped_equipment.numeric_modifier("familiar weight");
            if (false)
            {
            	boolean [item] specialised_equipment;
            	foreach f in $familiars[]
                {
                	specialised_equipment[f.familiar_equipment()] = true;
                }
                foreach it in $items[]
                {
                    if (it.to_slot() != $slot[familiar]) continue;
                    if (specialised_equipment[it]) continue;
                    if (it.numeric_modifier("familiar weight") == 0) continue;
                    print_html(it + ": " + it.numeric_modifier("familiar weight")); 
                }
            }
        }
    }
    
    int lectures_estimated_weight_can_support = floor(sqrt(estimated_professor_weight - 1)) + 1;
    int base_lectures_estimated_weight_can_support = lectures_estimated_weight_can_support;
    
    if ($familiar[pocket professor].familiar_equipped_equipment() == $item[Pocket Professor memory chip])
    	lectures_estimated_weight_can_support += 2;
    
    int next_lecture_weight = -1;
    int weight_to_next_lecture = -1;
    string lecture_title = "";
    string shortdesc = "";
	string [int] description;
	boolean can_lecture_now = false;
    if (lectures_estimated_weight_can_support > pocket_professor_lectures_property_value)
    {
    	int lectures_left = lectures_estimated_weight_can_support - pocket_professor_lectures_property_value;
        shortdesc = lectures_left;
        if (my_familiar() != $familiar[pocket professor])
        	lecture_title += "~";
        lecture_title += pluralise(lectures_left, "Pocket Professor lecture", "Pocket Professor lectures");
        can_lecture_now = true;
        next_lecture_weight = base_lectures_estimated_weight_can_support * base_lectures_estimated_weight_can_support + 1;
        weight_to_next_lecture = next_lecture_weight - estimated_professor_weight;
    }
    else
    {
    	//FIXME handle memory chip here
        weight_to_next_lecture = familiar_weight_for_next_lecture - estimated_professor_weight;
        lecture_title = "+" + weight_to_next_lecture + "lb to next Pocket Professor Lecture";
        description.listAppend(familiar_weight_for_next_lecture + "lb total.");
    }
    string monster_detail = ""; //"|*They did the mash.";
    
    if ($item[Kramco Sausage-o-Matic&trade;].have())
    	monster_detail += "|*Combines well with Kramco.";
    description.listAppend("<strong>Relativity</strong>: Creates a chained combat; useful for copying monsters or burning delay with free monsters." + monster_detail);
    description.listAppend("<strong>Mass</strong>: Triple items dropped from monster.");
    
    string last_monster_velocity_info = "";
    monster last_monster = last_monster();
    if (last_monster != $monster[none])
    {
    	float v = clampi(0.1 * last_monster.base_attack + 0.33 * estimated_professor_weight, 0, 150);
        last_monster_velocity_info = "|*Maybe ~" + v.round() + " " + my_primestat().to_lower_case() + " substats.";
    }
    description.listAppend("<strong>Velocity</strong>: Delevels + mainstats from weight/monster attack." + last_monster_velocity_info);
    
    if (can_lecture_now)
    	description.listAppend("+" + weight_to_next_lecture + "lb (" + next_lecture_weight + "lb total) for more lectures.");
    else
    	description.listAppend("Increase familiar weight for more lectures.");
    //If we don't have enough weight, display how much weight the professor needs until next lecture.
    
	string url = "";
	if (my_familiar() != $familiar[pocket professor])
		url = "familiar.php";
	
	if ($item[Pocket Professor memory chip].have() && $item[Pocket Professor memory chip].can_equip() && $familiar[pocket professor].familiar_equipped_equipment() != $item[Pocket Professor memory chip])
	{
		description.listAppend(HTMLGenerateSpanFont("Equip the Pocket Professor memory chip.", "red"));
	}
	checklists.add(C_RESOURCES, ChecklistEntryMake(511, "__familiar Pocket Professor", url, ChecklistSubentryMake(lecture_title, "", description), -1).ChecklistEntryTag("Pocket Professor").ChecklistEntrySetShortDescription(shortdesc));
	
	if (!get_property_boolean("_thesisDelivered") && $familiar[Pocket Professor].experience >= 400)
	{
		string [int] description;
        string adventure_detail;
        if (last_monster != $monster[none])
        {
        	//from wiki:
        	//min(2*floor(monster HP^0.25),11)
            float v = clampi(floor(powf(last_monster.base_attack, 0.25)), 2, 11);
            adventure_detail = "|*Maybe ~" + v.round() + " adventures.";
        }
        description.listAppend("Gives extra adventures from monster attack, and reduces the professor's experience by 200. (-6lb)" + adventure_detail);
        checklists.add(C_RESOURCES, ChecklistEntryMake(512, "__familiar Pocket Professor", url, ChecklistSubentryMake("Thesis delivery", "", description), -1).ChecklistEntryTag("Pocket Professor").ChecklistEntrySetShortDescription("thesis"));
	}
}
