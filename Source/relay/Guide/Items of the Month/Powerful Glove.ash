
import "relay/Guide/Items of the Month/Meteor Lore.ash";

RegisterResourceGenerationFunction("IOTMPowerfulGloveGenerateResource");
void IOTMPowerfulGloveGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (!$item[powerful glove].have()) return;
	
	int battery_left = clampi(100 - get_property_int("_powerfulGloveBatteryPowerUsed"), 0, 100);
	
	if (battery_left >= 5)
	{
		//invisible avatar - -10% combat rate
        //shrink enemy - should we even bother to mention this? reduces a single foe's HP/attack/def by 50%, I am not sure this is useful anywhere except maaaaaybe the war boss and duriel?
        //triple size - +200% stats for twenty adventures
        
        string [int] description;
        
        if (battery_left >= 10)
        {
            //replace enemy - macrometeorite reroll
            string [int] useful_places = generateUsefulPlacesToRerollMonsters();
        	description.listAppend("<strong>Replace enemy</strong>:|Reroll a monster in combat, -10 energy:|*-" + useful_places.listJoinComponents("|*-"));
        }
        
        description.listAppend("<strong>Invisible avatar</strong>: -10% combat rate buff. (10 adv, -5 energy)");
        description.listAppend("<strong>Triple size</strong>: +200% all stats buff. (20 adv, -5 energy)");
        
        string url = "skillz.php";
        if (!$item[powerful glove].equipped())
        {
        	url = generateEquipmentLink($item[powerful glove]);
            description.listAppend("Equip first to use.");
        }
        resource_entries.listAppend(ChecklistEntryMake("__item powerful glove", url, ChecklistSubentryMake(battery_left + " Powerful Glove energy", "", description), 2));
	}
}
