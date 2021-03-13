
RegisterGenerationFunction("IOTMMiniatureCrystalBallGenerate");
void IOTMMiniatureCrystalBallGenerate(ChecklistCollection checklists)
{
	item crystal_ball = lookupItem("miniature crystal ball");
	if (!crystal_ball.have() || __misc_state["familiars temporarily blocked"]) return;
	
	
	
	monster next_monster = get_property_monster("crystalBallMonster");
	location next_location = get_property_location("crystalBallLocation");
	string [int] description;
	
	boolean is_equipped = crystal_ball.equipped();
	if (!is_equipped)
		description.listAppend("Equip to predict the next monster fought in zone.");
    else
    	description.listAppend("Predicts the next monster fought in zone.");
	
	
	string image_name = "__item miniature crystal ball";
	
	string url = "familiar.php";
	
	if (next_monster != $monster[none])
	{
		string line = "Next monster is <strong>" + next_monster + "</strong> in " + next_location + ".";
        string warning;
        if (!is_equipped)
        {
        	warning = HTMLGenerateSpanFont("|Will not appear unless miniature crystal ball is equipped.", "red");
            if (crystal_ball.item_amount() == 0)
            {
            	//Find the familiar:
                //FIXME: only use familiars we have? but static is badhere I think..
                foreach f in $familiars[]
                {
                	if (f.familiar_equipped_equipment() == crystal_ball)
                    {
                    	warning += "|*Currently held by " + f + ".";
                    	break;
                    }
                }
            }
        }
        else
        {
        	url = next_location.getClickableURLForLocation();
        }
		description.listAppend(line);
        description.listAppend(warning);
        
        //Debate here: should the popup be item size?
        //Pros: the smaller size makes it take up less space, and it is a pop up. On retina displays, looks good.
        //Minuses: the "normal" size looks much nicer on non-retina displays, more "recognisable."
        //For now, regular size. This is important info we want to draw attention to.
        string popup_image_name = "__half __monster " + next_monster;
        image_name = "__monster " + next_monster;
        
  
  
  
  		string popup_header = next_monster.capitaliseFirstLetter();
        string popup_description = "Next adventure in " + next_location + ".";
        popup_description += warning;
  		checklists.add(C_TASKS, ChecklistEntryMake(513, popup_image_name, url, ChecklistSubentryMake(popup_header, "", popup_description), -11));
    }
	
	//tried inventory.php?which=2&ftext=miniature+crystal+ball but mafia's tracking with familiar equipment in inventory.php is wonky?
	checklists.add(C_RESOURCES, ChecklistEntryMake(514, image_name, url, ChecklistSubentryMake("Minature crystal ball", "", description), 1));
}
