
RegisterResourceGenerationFunction("IOTMEightDaysAweekPillKeeperGenerateResource");
void IOTMEightDaysAweekPillKeeperGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (!$item[Eight Days a Week Pill Keeper].have()) return;
	
	
	boolean first_one_is_free = !get_property_boolean("_freePillKeeperUsed");
	if (first_one_is_free || availableSpleen() >= 3)
	{
		string [int] description;
        description.listAppend("<strong>Surprise Me</strong>: force semi-rare next turn.");
        description.listAppend("<strong>Sneakisol</strong>: Next adventure will be a non-combat.");
		description.listAppend("<strong>Explodinall</strong>: yellow ray monster, next fight you win.");
        
        string [int] marginals;
		marginals.listAppend("<strong>Extendicillin</strong>: double next potion's effect length.");
        marginals.listAppend("<strong>Rainbowolin</strong>: +4 all res buff. (30 turns)");
        marginals.listAppend("<strong>Hulkien</strong>: +100% all stats buff. (30 turns).");
        marginals.listAppend("<strong>Fidoxene</strong>: +familiar weight buff, up to 20lb base. (30 turns)");
        description.listAppend("Marginal:|*" + marginals.listJoinComponents("|*"));
        //description.listAppend("<strong>Telecybin</strong>: teleportitis."); //technically optimal if you want to unlock the DoD
        //generateEquipmentLink($item[eight days a week pill keeper])
        string short_desc = "";
		if (first_one_is_free)
        {
        	description.listAppend("First one's free.");
         	short_desc = "free";
        }
        else
        {
        	description.listAppend("Costs three spleen.");
         	short_desc = "3spn";
        }
         
        resource_entries.listAppend(ChecklistEntryMake("__item eight days a week pill keeper", "main.php?eowkeeper=1", ChecklistSubentryMake("Pill keeper", "", description), 4).ChecklistEntrySetShortDescription(short_desc));   
	}
}
