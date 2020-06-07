boolean [item] __dense_liana_machete_items = $items[antique machete,Machetito,Muculent machete,Papier-m&acirc;ch&eacute;te];

int numberOfDenseLianaFoughtInShrine(location shrine)
{
    //need to check the combat names due to wanderers:
    int dense_liana_defeated = 0;
    string [int] area_combats_seen = shrine.locationSeenCombats();
    foreach key, s in area_combats_seen
    {
        if (s == "dense liana")
            dense_liana_defeated += 1;
    }
    return dense_liana_defeated;
}

void QLevel11HiddenCityInit() {
    QuestState state;
    QuestStateParseMafiaQuestProperty(state, "questL11Worship");
    if (myPathId() == PATH_COMMUNITY_SERVICE) QuestStateParseMafiaQuestPropertyValue(state, "finished");
    state.quest_name = "Hidden City Quest";
    state.image_name = "Hidden City";
    
    state.state_boolean["Hospital finished"] = (get_property_int("hiddenHospitalProgress") >= 8);
    state.state_boolean["Bowling alley finished"] = (get_property_int("hiddenBowlingAlleyProgress") >= 8);
    state.state_boolean["Apartment finished"] = (get_property_int("hiddenApartmentProgress") >= 8);
    state.state_boolean["Office finished"] = (get_property_int("hiddenOfficeProgress") >= 8);
    
    state.state_boolean["need machete for liana"] = true;
    foreach it in __dense_liana_machete_items {
        if (it.available_amount() > 0) {
            state.state_boolean["need machete for liana"] = false;
            break;
        }
    }
    
    if (get_property_int("hiddenBowlingAlleyProgress") >= 1 && get_property_int("hiddenHospitalProgress") >= 1 && get_property_int("hiddenApartmentProgress") >= 1 && get_property_int("hiddenOfficeProgress") >= 1 && $location[a massive Ziggurat].numberOfDenseLianaFoughtInShrine() >= 3 && state.mafia_internal_step >= 4)
        state.state_boolean["need machete for liana"] = false;
    
    if (!__misc_state["can equip just about any weapon"]) {
        state.state_boolean["need machete for liana"] = false;
    }
    
    
    if (state.finished) {
        state.state_boolean["Hospital finished"] = true;
        state.state_boolean["Bowling alley finished"] = true;
        state.state_boolean["Apartment finished"] = true;
        state.state_boolean["Office finished"] = true;
        state.state_boolean["need machete for liana"] = false;
    }
    
    __quest_state["Level 11 Hidden City"] = state;
}


void generateHiddenAreaUnlockForShrine(string [int] description, location shrine) {
    item machete = $item[none];

    foreach macheteItem in __dense_liana_machete_items {
        if (macheteItem.available_amount() > 0) {
            machete = macheteItem;
        }
    }
    
    boolean hasMachete = machete != $item[none];
    boolean hasMacheteEquipped = machete.equipped_amount() > 0;
    int lianaRemaining = MAX(0, 3 - shrine.numberOfDenseLianaFoughtInShrine());
    
    if (shrine != $location[a massive ziggurat]) {
        description.listAppend("Unlock by visiting " + shrine + ".");
    }

    if (lianaRemaining > 0 && shrine.noncombatTurnsAttemptedInLocation() == 0) {
        description.listAppend("Fight " + lianaRemaining + " more liana.");
        
        if (__misc_state["can equip just about any weapon"] && myPathId() != PATH_POCKET_FAMILIARS) {
            if (!hasMachete) {
                description.listAppend("Acquire a machete first.");
            } else if (!hasMacheteEquipped) {
                description.listAppend(HTMLGenerateSpanFont("Equip your " + machete + " first.", "red"));
            }
        }
    }
}

void QLevel11HiddenCityGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11 Hidden City"].in_progress)
        return;
    if (__quest_state["Level 11"].mafia_internal_step <3 ) //strange bug where questL11MacGuffin = started, questL11Manor = step1
        return;
        
    QuestState base_quest_state = __quest_state["Level 11 Hidden City"];
    ChecklistEntry entry;
    entry.url = "place.php?whichplace=hiddencity";
    entry.image_lookup_name = base_quest_state.image_name;
    entry.should_indent_after_first_subentry = true;
    entry.should_highlight = $locations[the hidden temple, the hidden apartment building, the hidden hospital, the hidden office building, the hidden bowling alley, the hidden park, a massive ziggurat,an overgrown shrine (northwest),an overgrown shrine (southwest),an overgrown shrine (northeast),an overgrown shrine (southeast)] contains __last_adventure_location;
    
    if (!__quest_state["Hidden Temple Unlock"].finished)
    {
        return;
    }
    else if (!locationAvailable($location[the hidden park]))
    {
        entry.image_lookup_name = "Hidden Temple";
        entry.url = "place.php?whichplace=woods";
        ChecklistSubentry subentry;
        subentry.header = base_quest_state.quest_name;
        subentry.entries.listAppend("Unlock the hidden city via the hidden temple.");
        if ($item[the Nostril of the Serpent].available_amount() == 0)
            subentry.entries.listAppend("Need nostril of the serpent.");
        if ($item[stone wool].available_amount() > 0 && myPathId() != PATH_G_LOVER)
        {
            if ($effect[Stone-Faced].have_effect() == 0)
                entry.url = "inventory.php?which=3";
            subentry.entries.listAppend(pluralise($item[stone wool]) + " available.");
        }
        if (myPathId() == PATH_G_LOVER)
        {
        	subentry.modifiers.listAppend("-combat");
            if (__iotms_usable[lookupItem("genie bottle")])
            {
            	subentry.entries.listAppend("Genie wish for the \"stone-faced\" effect, then adventure in the temple.");
            }
        }
        entry.subentries.listAppend(subentry);
    }
    else
    {		
        if (true)
        {
            ChecklistSubentry subentry;
            subentry.header = base_quest_state.quest_name;
            entry.subentries.listAppend(subentry);
        }
        //Not sure exactly how these work.
        //8 appears to be finished.
        //1 appears to be "area unlocked"
        boolean hidden_tavern_unlocked = get_property_ascension("hiddenTavernUnlock");
        boolean janitors_relocated_to_park = get_property_ascension("relocatePygmyJanitor");
        boolean have_machete = false;
    
        have_machete = __dense_liana_machete_items.available_amount() > 0;
        int bowling_progress = get_property_int("hiddenBowlingAlleyProgress");
        int hospital_progress = get_property_int("hiddenHospitalProgress");
        int apartment_progress = get_property_int("hiddenApartmentProgress");
        int office_progress = get_property_int("hiddenOfficeProgress");
        
        if (!base_quest_state.state_boolean["need machete for liana"])
            have_machete = true;
        
        boolean at_last_spirit = false;
        
        if (bowling_progress == 8 && hospital_progress == 8 && apartment_progress == 8 && office_progress == 8 || $item[stone triangle].available_amount() == 4)
        {
            at_last_spirit = true;
            ChecklistSubentry subentry;
            subentry.header = "Massive Ziggurat";
            //Instead of checking for four stone triangles, we check for the lack of all four stone spheres. That way it should detect properly after you fight the boss (presumably losing stone triangles), and lost?
        
            int spheres_available = $item[moss-covered stone sphere].available_amount() + $item[dripping stone sphere].available_amount() + $item[crackling stone sphere].available_amount() + $item[scorched stone sphere].available_amount();
        
            if (spheres_available > 0)
            {
                subentry.entries.listAppend("Acquire stone triangles");
            }
            else
            {
                if ($location[a massive ziggurat].numberOfDenseLianaFoughtInShrine() <3 && $location[a massive ziggurat].noncombatTurnsAttemptedInLocation() == 0)
                {
                    generateHiddenAreaUnlockForShrine(subentry.entries,$location[a massive ziggurat]);
                }
                else
                {
                    if (myPathId() == PATH_ACTUALLY_ED_THE_UNDYING)
                    {
                        subentry.entries.listAppend("Talk to the protector spectre.");
                    }
                    else
                    {
                        subentry.modifiers.listAppend("elemental damage");
                        subentry.entries.listAppend("Fight the protector spectre!");
                    }
                }
            }
        
            entry.subentries.listAppend(subentry);
        }
        if (!at_last_spirit)
        {
            if ((!janitors_relocated_to_park && !$monster[pygmy janitor].is_banished()) || (!have_machete  && myPathId() != PATH_POCKET_FAMILIARS))
            {
                ChecklistSubentry subentry;
                subentry.header = "Hidden Park";
            
                subentry.modifiers.listAppend("-combat");
                if (!have_machete && myPathId() != PATH_POCKET_FAMILIARS)
                {
                    int turns_remaining = MAX(0, 7 - $location[the hidden park].turnsAttemptedInLocation());
                    string line;
                    line += "Adventure for ";
                    if (turns_remaining == 1)
                        line += "One More Turn";
                    else
                        line += turns_remaining.int_to_wordy() + " more turns";
                    line += " here for antique machete to clear dense lianas.";
                    if (canadia_available())
                        line += "|Or potentially use muculent machete by acquiring forest tears. (kodama, Outskirts of Camp Logging Camp, 30% drop or clover)";
                    subentry.entries.listAppend(line);
                }
                if (!janitors_relocated_to_park)
                    subentry.entries.listAppend("Potentially relocate janitors to park via non-combat.");
                else
                    subentry.entries.listAppend("Acquire useful items from dumpster with -combat.");
                if (__misc_state["have hipster"])
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
                if (my_basestat($stat[muscle]) < 62)
                {
                    string line = "Will need " + (62 - my_basestat($stat[muscle])) + " more muscle to equip machete.";
                    subentry.entries.listAppend(line);
                }
            
                entry.subentries.listAppend(subentry);
            }
        }
        
        if (apartment_progress < 8) {
            ChecklistSubentry subentry;
            subentry.header = "Hidden Apartment";
            if (apartment_progress == 7 || $item[moss-covered stone sphere].available_amount() > 0) {
                subentry.entries.listAppend("Place moss-covered stone sphere in shrine.");
            } else if (apartment_progress == 0) {
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[an overgrown shrine (Northwest)]);
            } else {                    
                int totalTurnsSpent = $location[the hidden apartment building].turns_spent;

                int delayForNextNoncombat;

                if (totalTurnsSpent < 6) {
                    delayForNextNoncombat = 8 - totalTurnsSpent;
                } else {
                    delayForNextNoncombat = 6 - (totalTurnsSpent - 9) % 8;
                }
                
                string [int] curseSources;
                curseSources.listAppend("• Fighting a shaman.");
                if (hidden_tavern_unlocked) {
                    curseSources.listAppend("• Drinking a cursed punch from the tavern.");
                } else {
                    curseSources.listAppend("• " + HTMLGenerateSpanFont("Drinking a cursed punch from the tavern after you unlock it.", "grey"));
                }

                if ($effect[thrice-cursed].have_effect() > 0) {
                    subentry.entries.listAppend("You're thrice-cursed. Fight the protector spirit!");
                } else if ($effect[twice-cursed].have_effect() > 0) {
                    subentry.entries.listAppend("Need 1 more curse. Get cursed by:" + curseSources);
                } else if ($effect[once-cursed].have_effect() > 0) {
                    subentry.entries.listAppend("Need 2 more curses." + curseSources);
                } else {
                    subentry.entries.listAppend("Need 3 more curses. Get cursed by:" + HTMLGenerateIndentedText(curseSources));
                }

                subentry.entries.listAppend("Delay for " + pluralise(delayForNextNoncombat, "turn", "turns") + " to fight spirit.");
                
                // Warnings
                if (my_class() == $class[pastamancer] && my_thrall() == $thrall[Vampieroghi] && my_thrall().level >= 5) {
                    subentry.entries.listAppend(HTMLGenerateSpanFont("Change your thrall - Vampieroghi will remove curses.", "red"));
                }

                if ($effect[Ancient Fortitude].have_effect() > 0 && $effect[thrice-cursed].have_effect() == 0) {
                	subentry.entries.listAppend(HTMLGenerateSpanFont("Remove Ancient Fortitude effect - you will not be cursed while that effect is up.", "red"));
                }

                if (myPathId() == PATH_AVATAR_OF_SNEAKY_PETE && $skill[Shake it off].skill_is_usable()) {
                    subentry.entries.listAppend(HTMLGenerateSpanFont("Avoid using Shake It Off to heal", "red") + ", it'll remove the curse.");
                }
        
                if (__misc_state["have hipster"]) {
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                }
            }
            entry.subentries.listAppend(subentry);
        }
        if (office_progress < 8) {
            ChecklistSubentry subentry;
            subentry.header = "Hidden Office";
            if (office_progress == 7 || $item[crackling stone sphere].available_amount() > 0) {
                subentry.entries.listAppend("Place crackling stone sphere in shrine.");
            }  else if (office_progress == 0){
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[an overgrown shrine (Northeast)]);
            } else {
                int numberOfFilesFound = $item[McClusky file (page 1)].available_amount() + $item[McClusky file (page 2)].available_amount() + $item[McClusky file (page 3)].available_amount() + $item[McClusky file (page 4)].available_amount() + $item[McClusky file (page 5)].available_amount();
                int numberOfFilesLeft = 5 - numberOfFilesFound;

                boolean hasMcCluskyFile = $item[McClusky file (complete)].available_amount() > 0;
                boolean hasBoringBinderClip = $item[Boring binder clip].available_amount() > 0;
                
                int totalTurnsSpent = $location[the hidden office building].turns_spent;
                
                int delayForNextNoncombat;

                if (totalTurnsSpent < 6) {
                    delayForNextNoncombat = 5 - totalTurnsSpent;
                } else {
                    delayForNextNoncombat = 4 - (totalTurnsSpent - 6) % 5;
                }

                if (!hasMcCluskyFile) {
                    if (numberOfFilesLeft > 0) {
                        subentry.entries.listAppend("Kill " + pluralise(numberOfFilesLeft, "more pygmy witch accountant", "more pygmy witch accountants") + " for their files.");
                    }
                }

                if (delayForNextNoncombat == 0) {
                    if (hasMcCluskyFile) {
                        subentry.entries.listAppend("Fight the Ancient protector spirit next turn by choosing " + HTMLGenerateSpanOfClass("[Knock on the boss's office door]", "r_bold"));
                    } else if (!hasBoringBinderClip) {
                        subentry.entries.listAppend("Find the binder clip next turn by choosing " + HTMLGenerateSpanOfClass("[Raid the supply cabinet]", "r_bold"));
                    } else {
                        subentry.entries.listAppend(HTMLGenerateSpanFont("Don't have the full McClusky files but noncombat is next turn. Consider adventuring in the apartment building.", "red"));
                    }
                } else {
                    string message = "Delay for " + pluralise(delayForNextNoncombat, "turn", "turns") + " to";
                    if (hasBoringBinderClip || hasMcCluskyFile) {
                        message += " fight spirit.";
                    } else {
                        message += " find boring binder clip.";
                    }
                    subentry.entries.listAppend(message);
                }
        
                if (__misc_state["have hipster"]) {
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
                }
            }
            entry.subentries.listAppend(subentry);
        }
        if (hospital_progress < 8) {

            ChecklistSubentry subentry;
            subentry.header = "Hidden Hospital";

            if (hospital_progress == 7 || $item[dripping stone sphere].available_amount() > 0) {
                subentry.entries.listAppend("Place dripping stone sphere in shrine.");
            } else if (hospital_progress == 0) {
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[an overgrown shrine (Southwest)]);
            } else {
                boolean [item] outfitPieces = $items[bloodied surgical dungarees,surgical mask,head mirror,half-size scalpel].makeConstantItemArrayMutable();

                if (__misc_state["Torso aware"]) {
                    outfitPieces[$item[surgical apron]] = true;
                }
                
                item [int] ownedOutfitPieces;
                item [int] unequippedOutfitPieces;

                string unownedOutfitMessage = "Fight pygmy surgeons to get surgeon gear:";
                foreach outfitPiece in outfitPieces {
                    if (outfitPiece.available_amount() > 0) {
                        ownedOutfitPieces.listAppend(outfitPiece);

                        if (outfitPiece.equipped_amount() == 0) {
                            unequippedOutfitPieces.listAppend(outfitPiece);
                        } 
                    } else {
                        unownedOutfitMessage += "|* • " + outfitPiece;
                    }
                }

                if (unequippedOutfitPieces.count() > 0) {
                    subentry.entries.listAppend(HTMLGenerateSpanFont("Equip your " + unequippedOutfitPieces.listJoinComponents(", ", "and") + " first.", "red"));
                }

                if (ownedOutfitPieces.count() < 5) {
                    subentry.entries.listAppend(unownedOutfitMessage);
                    subentry.modifiers.listAppend("olfact surgeon");
                }
                
                int numberOfEquippedPieces = ownedOutfitPieces.count() - unequippedOutfitPieces.count();
                subentry.entries.listAppend((numberOfEquippedPieces * 10) + "% chance to fight spirit.");

                int totalTurnsSpent = $location[The Hidden Hospital].turns_spent;
                subentry.entries.listAppend(HTMLGenerateSpanFont("Alternatively, burn " + (31 - totalTurnsSpent) + " more turns.", "grey"));
            }
            
            entry.subentries.listAppend(subentry);
        }
    
        if (bowling_progress < 8) {

            ChecklistSubentry subentry;

            subentry.header = "Hidden Bowling Alley";
            subentry.modifiers.listAppend("+150% item, olfact bowler");

            if (bowling_progress == 7 || $item[scorched stone sphere].available_amount() > 0) {
                subentry.entries.listAppend("Place scorched stone sphere in shrine.");
            } else if (bowling_progress == 0) {
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[an overgrown shrine (southeast)]);
            } else {
                int numberOfRollsLeft = 6 - bowling_progress;
                int bowlingBallsNeeded = numberOfRollsLeft - $item[bowling ball].available_amount_including_closet();
                int bowlingBallsInInventory = $item[bowling ball].available_amount();

                if (bowlingBallsNeeded > 0) {
                    subentry.entries.listAppend("Find " + bowlingBallsNeeded + " more bowling balls by fighting pygmy bowlers.");
                }

                if (numberOfRollsLeft > 0) {
                    subentry.entries.listAppend("Adventure " + numberOfRollsLeft + " more times with bowling balls to fight spirit.");
                }
                                
                if (hidden_tavern_unlocked) {
                    if (!$monster[drunk pygmy].is_banished()) {
                        if ($item[bowl of scorpions].item_amount() == 0) {
                            subentry.entries.listAppend(HTMLGenerateSpanFont("Buy bowl of scorpions from the Hidden Tavern to free run.", "red"));
                        } else {
                            subentry.entries.listAppend("Use bowl of scorpions on drunk pygmy for free run.");
                        }
                    }
                } else {
                    subentry.entries.listAppend(HTMLGenerateSpanFont("Unlock the hidden tavern for free runs from drunk pygmies.", "grey"));
                }
            }
        
            entry.subentries.listAppend(subentry);
        }
        
        if (!at_last_spirit)
        {
            if ($location[a massive ziggurat].numberOfDenseLianaFoughtInShrine() < 3) {
                ChecklistSubentry subentry;
                subentry.header = "Massive Ziggurat";
                generateHiddenAreaUnlockForShrine(subentry.entries,$location[a massive ziggurat]);
                entry.subentries.listAppend(subentry);
            }

            if (!hidden_tavern_unlocked && myPathId() != PATH_G_LOVER && myPathId() != PATH_BEES_HATE_YOU)
            {
                ChecklistSubentry subentry;
                subentry.header = "Hidden Tavern";
                boolean should_output = true;
            
                if ($item[book of matches].available_amount() > 0)
                    subentry.entries.listAppend(HTMLGenerateSpanFont("Use book of matches.", "red"));
                else
                {
                    if (janitors_relocated_to_park)
                        subentry.entries.listAppend("Possibly acquire and use book of matches from janitors. (Pygmy janitors, Hidden Park, 20% drop)");
                    else
                        subentry.entries.listAppend("Possibly acquire and use book of matches from janitors. (Pygmy janitors, everywhere in the hidden city, 20% drop)");
                    
                    string [int] tavern_provides;
                    if (bowling_progress < 7 && __misc_state["free runs usable"])
                        tavern_provides.listAppend("Free runs from drunk pygmys.");
                    if (__misc_state["can drink just about anything"])
                    {
                        if (apartment_progress < 8)
                            tavern_provides.listAppend("Curses for hidden apartment.");
                        int adventures_given = 15;
                        if ($skill[the ode to booze].skill_is_usable())
                            adventures_given += 6;
                        
                        if (myPathId() != PATH_SLOW_AND_STEADY)
                            tavern_provides.listAppend("Nightcap drink. (Fog Murderer for " + adventures_given + " adventures)");
                    }
                    if (tavern_provides.count() > 0)
                        subentry.entries.listAppend("Hidden Tavern provides:|*" + tavern_provides.listJoinComponents("|*"));
                    else
                        should_output = false; //don't bother, no reason to... I think?
                
                }
                if (should_output)
                    entry.subentries.listAppend(subentry);
            }
        }
    }

    if (entry.subentries.count() > 0) {
        task_entries.listAppend(entry);
    }
}
