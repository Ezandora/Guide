RegisterResourceGenerationFunction("IOTMGingerbreadCityGenerateResource");
void IOTMGingerbreadCityGenerateResource(ChecklistEntry [int] resource_entries)
{
    if ($skill[Ceci N'Est Pas Un Chapeau].have_skill() && !get_property_boolean("_ceciHatUsed") && my_basestat($stat[moxie]) >= 150 && __misc_state["in run"])
    {
        //Umm... I guess?
        //It doesn't seem amazing in aftercore, so we're not displaying it? Is that the right decision?
        //Almost all of its enchantments are better on other hats. And you can't choose which one you get, so it'd just be annoying the user.
        resource_entries.listAppend(ChecklistEntryMake("__skill Ceci N'Est Pas Un Chapeau", "skillz.php", ChecklistSubentryMake("Ceci N'Est Pas Un Chapeau", "", "Random enchantment hat, 300MP."), 10));
    }
    
    if ($skill[Gingerbread Mob Hit].skill_is_usable() && mafiaIsPastRevision(17566))
    {
        if (!get_property_boolean("_gingerbreadMobHitUsed"))
        {
            string [int] description;
            description.listAppend("Combat skill, win a fight without taking a turn.");
            //FIXME replace with a better image
            resource_entries.listAppend(ChecklistEntryMake("__familiar Penguin Goodfella", "", ChecklistSubentryMake("Gingerbread mob hit", "", description), 0).ChecklistEntryTagEntry("free instakill"));
            
        }
    }
    
    //http://kol.coldfront.net/thekolwiki/index.php/A_GingerGuide_to_Gingerbread_City
    
    //Things to acquire/unlock:
    //Studying in the library, which lets you acquire the seven-day sugar raygun.
    //Unlocking various areas.
    //Chocolate puppy.
    //Moneybag
    //gingerbread pistol
    //chocolate pocketwatch
    //Two skills...?
    //Laying track (does this reset on ascension...?) for a briefcase with lots of sprinkles...?
    //Studying train schedules for ???
    //Gingerbread Best outfit components.
    //Um... candy crowbar -> breaking in? Do you ever do this in run? No, I think?
    //Counterfeit city to sell.
    //Gingerbread cigarette to sell.
    //Chocolate sculpture to sell.
    //Gingerbread gavel
    //More...?
    if ($locations[Gingerbread Industrial Zone,Gingerbread Train Station,Gingerbread Sewers,Gingerbread Upscale Retail District] contains __last_adventure_location)
    {
        //Show details:
        /*
        Unlocks:
            gingerAdvanceClockUnlocked
            gingerRetailUnlocked 
            gingerSewersUnlocked 
            gingerExtraAdventures - +10 adventures in area
        
        gingerSubwayLineUnlocked
        
        _gingerBiggerAlligators - a born liverpooler
        _gingerbreadMobHitUsed - used once/day free kill
        gingerNegativesDropped
        gingerTrainScheduleStudies - times studied the schedule
        gingerDigCount - times went digging at the train station
        gingerLawChoice - times studied law
        gingerMuscleChoice - times laid track
        */
        //There's no per-turn tracker for this area.
    }
}
