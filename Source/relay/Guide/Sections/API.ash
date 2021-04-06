//Support auto-refreshing guide while editing code:
static
{
    string __last_compile_time = "";
    __last_compile_time = now_to_string("kmsS");
}

string [string] generateAPIResponse()
{
    //35ms response time measured in-run
    string [string] result;
    
    boolean should_force_reload = false;
    
    if (should_force_reload)
    {
        result["need to reload"] = should_force_reload;
        return result;
    }
    
    //Unique identifiers to determine whether a reload is necessary:
    //All of these will be checked by the javascript.
    result["turns played"] = my_turncount();
    result["hp"] = my_hp();
    result["mp"] = my_mp();
    result["+ml"] = monster_level_adjustment();
    result["+init"] = initiative_modifier();
    result["combat rate"] = combat_rate_modifier();
    result["+item"] = item_drop_modifier();
    result["familiar"] = my_familiar().to_int();
    result["adventures remaining"] = my_adventures();
    result["meat available"] = my_meat();
    result["stills available"] = stills_available();
    result["enthroned familiar"] = my_enthroned_familiar();
    result["bjorned familiar"] = my_bjorned_familiar();
    result["pulls remaining"] = pulls_remaining();
    result["location"] = my_location();
    
    if (true)
    {
        int [effect] my_effects = my_effects();
        int total_effect_length = 0;
        foreach e in my_effects
            total_effect_length += my_effects[e];
        
        result["effect count"] = my_effects.count();
        result["total effect length"] = total_effect_length;
    }
    result["fullness available"] = availableFullness();
    result["drunkenness available"] = availableDrunkenness();
    result["spleen available"] = availableSpleen();
    result["auto attack id"] = get_auto_attack(); //for copied monsters warning, don't want that to be stale
    
    if (true)
    {
        result["equipped items"] = equipped_items().to_json();
    }
    
    if (false)
    {
        //if we need a clockwork maid? maybe?
        result["campground items"] = get_campground().to_json();
    }
    if (__iotms_usable[$item[Order of the Green Thumb Order Form]])
    {
        int plant_count = 0;
        string [location, 3] florist_plants = get_florist_plants();
        foreach l in florist_plants
        {
            foreach key in florist_plants[l]
            {
                if (florist_plants[l][key] != "")
                    plant_count+= 1;
            }
        }
        result["plant count"] = plant_count;
    }
    
    if (true)
    {
        //Before discovering get_inventory() existed, this was very intensive - 40ms API load versus 25ms, or 28ms versus 16ms;
        //With get_inventory(), maybe it won't be a problem? In-run, it's about 0.2ms.
        int item_count = 0;
        foreach it, amount in get_inventory()
            item_count += amount;
        result["item count"] = item_count;
    }
    if (true)
    {
        //When foldables change, item count does not, so we need to manually watch them:
        //FIXME probably spooky putty/etc?
        int [int] output;
        boolean [item] relevant_items_strings = lookupItemsArray($strings[deceased crimbo tree,broken champagne bottle,tinsel tights,wad of used tape,makeshift garbage shirt,flimsy hardwood scraps]);
        foreach it in relevant_items_strings
        {
            if (it.available_amount() > 0)
                output[it.to_int()] = it.available_amount();
        }
        
        result["relevant items"] = output.to_json();
    }
    /*else if (true)
    {
        //Checking every item is slow. But certain items won't trigger a reload, but need to. So:
        boolean [item] relevant_items = $items[photocopied monster,4-d camera,pagoda plans,Elf Farm Raffle ticket,skeleton key,heavy metal thunderrr guitarrr,heavy metal sonata,Hey Deze nuts,rave whistle,damp old boot,map to Professor Jacking's laboratory,world's most unappetizing beverage,squirmy violent party snack,White Citadel Satisfaction Satchel,rusty screwdriver,giant pinky ring,The Lost Pill Bottle,GameInformPowerDailyPro magazine,dungeoneering kit,Knob Goblin encryption key,dinghy plans,Sneaky Pete's key,Jarlsberg's key,Boris's key,fat loot token,bridge,chrome ore,asbestos ore,linoleum ore,csa fire-starting kit,tropical orchid,stick of dynamite,barbed-wire fence,psychoanalytic jar,digital key,Richard's star key,star hat,star crossbow,star staff,star sword,Wand of Nagamar,Azazel's tutu,Azazel's unicorn,Azazel's lollipop,smut orc keepsake box,blessed large box,massive sitar,hammer of smiting,chelonian morningstar,17-alarm saucepan,shagadelic disco banjo,squeezebox of the ages,E.M.U. helmet,E.M.U. harness,E.M.U. joystick,E.M.U. rocket thrusters,E.M.U. unit,wriggling flytrap pellet,Mer-kin trailmap,Mer-kin stashbox,Makeshift yakuza mask,Novelty tattoo sleeves,strange goggles,zaibatsu level 2 card,zaibatsu level 3 card,flickering pixel,jar of oil,bowl of scorpions,molybdenum magnet,steel lasagna,steel margarita,steel-scented air freshener,Grandma's Map,mer-kin healscroll,scented massage oil,soggy used band-aid,extra-strength red potion,red pixel potion,red potion,filthy poultice,gauze garter,green pixel potion,cartoon heart,red plastic oyster egg,Manual of Dexterity,Manual of Labor,Manual of Transmission,wet stunt nut stew,lost key,resolution: be more adventurous,sugar sheet,sack lunch,glob of Blank-Out,gaudy key,plus sign,Newbiesport&trade; tent,Frobozz Real-Estate Company Instant House (TM),dry cleaning receipt,book of matches,rock band flyers,jam band flyers,disassembled clover,continuum transfunctioner,UV-resistant compass,eyepatch,carton of astral energy drinks,astral hot dog dinner,astral six-pack,gym membership card,tattered scrap of paper,bowling ball, snow boards,reassembled blackbird,reconstituted crow,louder than bomb,odd silver coin,grimstone mask,empty rain-doh can,Lord Spookyraven's spectacles,lump of Brituminous coal,bone rattle,mer-kin knucklebone,spooky glove,steam-powered model rocketship,crappy camera,shaking crappy camera,hedge maze puzzle,ghost of a necklace,telegram from Lady Spookyraven,Lady Spookyraven's finest gown,recipe: mortar-dissolving solution,disposable instant camera,unstable fulminate,thunder thigh,aquaconda brain,lightning milk,White Citadel Satisfaction Satchel,handful of smithereens,Loathing Legion jackhammer,lynyrd skin,red zeppelin ticket,lynyrd snare,glark cable,Fernswarthy's key,bottle of G&uuml;-Gone,BURT,handful of juicy garbage,Jeff Goldblum larva,imbued seal-blubber candle,claw of the infernal seal,junk junk,sea lasso,seal tooth,worthless trinket,worthless gewgaw,worthless knick-knack,gnollish toolbox,poppy,opium grenade,talisman o' namsilat,toxic globule,yellow pixel,greek pasta spoon of peril,hellseal disguise,8042,uncapped red lava bottle,uncapped green lava bottle,uncapped blue lava bottle,capped red lava bottle,capped green lava bottle,capped blue lava bottle,insulated gold wire,little firkin,normal barrel,big tun,weathered barrel,dusty barrel,disintegrating barrel,moist barrel,rotting barrel,mouldering barrel,barnacled barrel,incriminating evidence,dangerous chemicals,kidnapped orphan,bat-oomerang,bat-jute,bat-o-mite,rad,cashew,stuffing fluffer];
        
        
        int [int] output;
        
        foreach it in relevant_items
        {
            if (it.available_amount() > 0)
                output[it.to_int()] = it.available_amount();
        }
        
        boolean [item] relevant_items_strings = lookupItemsArray($strings[cornucopia]);
        foreach it in relevant_items_strings
        {
            if (it.available_amount() > 0)
                output[it.to_int()] = it.available_amount();
        }
        
        result["relevant items"] = output.to_json();
    }*/
    
    /*if (true)
    {
        //Possibly switch to this in 17.7? It's slower by 4ms, but drastically simplifies implementation.
        //The other method is 9/10ms.
        //16ms:
        //result["mafia properties"] = get_all_properties("", false).to_json();
        //13ms:
        buffer mafia_properties;
        foreach property_name, property_value in get_all_properties("", false)
        {
            mafia_properties.append(property_value);
        }
        result["mafia properties"] = mafia_properties.to_string();
    }
    else if (true)*/
    if (true)
    {
        boolean [string] relevant_mafia_properties = $strings[merkinQuestPath,questF01Primordial,questF02Hyboria,questF03Future,questF04Elves,questF05Clancy,questG01Meatcar,questG02Whitecastle,questG03Ego,questG04Nemesis,questG05Dark,questG06Delivery,questI01Scapegoat,questI02Beat,questL02Larva,questL03Rat,questL04Bat,questL05Goblin,questL06Friar,questL07Cyrptic,questL08Trapper,questL09Topping,questL10Garbage,questL11MacGuffin,questL11Manor,questL11Palindome,questL11Pyramid,questL11Worship,questL12War,questL13Final,questM01Untinker,questM02Artist,questM03Bugbear,questM04Galaktic,questM05Toot,questM06Gourd,questM07Hammer,questM08Baker,questM09Rocks,questM10Azazel,questM11Postal,questM12Pirate,questM13Escape,questM14Bounty,questM15Lol,questS01OldGuy,questS02Monkees,sidequestArenaCompleted,sidequestFarmCompleted,sidequestJunkyardCompleted,sidequestLighthouseCompleted,sidequestNunsCompleted,sidequestOrchardCompleted,cyrptAlcoveEvilness,cyrptCrannyEvilness,cyrptNicheEvilness,cyrptNookEvilness,desertExploration,gnasirProgress,relayCounters,timesRested,currentEasyBountyItem,currentHardBountyItem,currentSpecialBountyItem,volcanoMaze1,_lastDailyDungeonRoom,seahorseName,chasmBridgeProgress,_aprilShower,lastAdventure,lastEncounter,_floristPlantsUsed,_fireStartingKitUsed,_psychoJarUsed,hiddenHospitalProgress,hiddenBowlingAlleyProgress,hiddenApartmentProgress,hiddenOfficeProgress,pyramidPosition,parasolUsed,_discoKnife,lastPlusSignUnlock,olfactedMonster,photocopyMonster,lastTempleUnlock,volcanoMaze1,blankOutUsed,peteMotorbikeCowling,peteMotorbikeGasTank,peteMotorbikeHeadlight,peteMotorbikeMuffler,peteMotorbikeSeat,peteMotorbikeTires,_petePeeledOut,_navelRunaways,_peteRiotIncited,_petePartyThrown,hiddenTavernUnlock,_dnaPotionsMade,_psychokineticHugUsed,dnaSyringe,_warbearGyrocopterUsed,questM20Necklace,questM21Dance,grimstoneMaskPath,cinderellaMinutesToMidnight,merkinVocabularyMastery,_pirateBellowUsed,questM21Dance,_defectiveTokenChecked,questG07Myst,questG08Moxie,questESpClipper,questESpGore,questESpJunglePun,questESpFakeMedium,questESlMushStash,questESlAudit,questESlBacteria,questESlCheeseburger,questESlCocktail,questESlSprinkles,questESlSalt,questESlFish,questESlDebt,_pickyTweezersUsed,_bittycar,questESpSerum,questESpOutOfOrder,_shrubDecorated,questESpEVE,questESpSmokes,questG09Muscle,_rapidPrototypingUsed,nsTowerDoorKeysUsed,_chateauDeskHarvested,lastGoofballBuy,nsChallenge1,nsChallenge2,nsContestants1,nsContestants2,nsContestants3,lastDesertUnlock,questM18Swamp,edPiece,warehouseProgress,questEStFishTrash,questEStNastyBears,questEStSocialJusticeI,questEStSocialJusticeII,questEStSuperLuber,questEStZippityDooDah,_summonAnnoyanceUsed,questEStWorkWithFood,questM24Doc,questEStGiveMeFuel,_mayoTankSoaked,_feastUsed,spelunkyNextNoncombat,spelunkySacrifices,spelunkyStatus,spelunkyUpgrades,spelunkyWinCount,_deckCardsDrawn,_glarkCableUses,_banderRunaways,questM25Armorer,pyramidBombUsed,_powerPillUses,nextAdventure,_barrelPrayer,questECoBucket,_machineTunnelsAdv,_snojoFreeFights,snojoSetting,_lastCombatStarted,batmanZone,batmanUpgrades,batmanTimeLeft,batmanStats,questLTTQuestByWire,questM26Oracle,sourceTerminalEducate1,sourceTerminalEducate2,sourceTerminalEnquiry,_sourceTerminalDigitizeUses,_sourceTerminalEnhanceUses,_sourceTerminalExtrudes,_detectiveCasesCompleted,_pottedTeaTreeUsed,lastIslandUnlock,falloutShelterChronoUsed,_timeSpinnerMinutesUsed,_lynyrdSnareUses,_noobSkillCount,_universeCalculated,_expertCornerCutterUsed,boomBoxSong,_questPartyFair,_questPartyFairQuest,_neverendingPartyFreeTurns,_latteRefillsUsed,_latteBanishUsed,_latteCopyUsed,_latteDrinkUsed,_kgbTranquilizerDartUses,banishedMonsters,lastLightsOutTurn,lastVoteMonsterTurn,_lastCombatStarted,_sausageFights,_saberMod,_saberForceMonster,_daycareRecruits,_daycareGymScavenges,_campAwayCloudBuffs,_campAwaySmileBuffs,moonTuned,zeppelinProtestors,questL11Ron,questL11Shen,questGuzzlr,_canSeekBirds,_birdOfTheDayMods,_pocketProfessorLectures,_thesisDelivered,crystalBallMonster,_feelLonelyUsed,_feelExcitementUsed,_feelPeacefulUsed,_feelEnvyUsed,_feelHatredUsed,_feelNostalgicUsed,_feelPrideUsed,_feelSuperiorUsed,_monstersMapped,mappingMonsters,retroCapeSuperhero,retroCapeWashingInstructions,shockingLickCharges,_pottedPowerPlant,backupCameraMode,_backUpUses,backupCameraReverserEnabled];
        
        if (false)
        {
            //Give full description:
            string [string] mafia_properties;
            foreach property_name in relevant_mafia_properties
            {
                mafia_properties[property_name] = get_property(property_name);
            }
            result["mafia properties"] = mafia_properties.to_json();
        }
        else
        {
            //Give partial description: (equivalent for equivalency testing)
            //65% smaller
            buffer mafia_properties;
            boolean first = true;
            foreach property_name in relevant_mafia_properties
            {
                //This could fail an update if two properties coincidentally update a certain way - i.e. "1" and "21" becoming "12" and "1" both would be "121" - but it's unlikely to happen, and the faster this is, the better.
                /*if (first)
                    first = false;
                else
                    mafia_properties.append(",");*/
                string value = get_property(property_name);
                mafia_properties.append(value);
            }
            result["mafia properties"] = mafia_properties.to_string();
        }
        result["logged in"] = playerIsLoggedIn();
    }
    if (my_path_id() == PATH_AVATAR_OF_WEST_OF_LOATHING || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE || my_path_id() == PATH_THE_SOURCE || my_path_id() == PATH_GELATINOUS_NOOB)
    {
        int skill_count = 0;
        foreach s in $skills[]
        {
            if (s.skill_is_usable())
                skill_count += 1;
        }
        result["skill_count"] = skill_count;
    }
    else if (true)
    {
        int relevant_skill_count = 0;
        foreach s in $skills[Gothy Handwave]
        {
            if (s.skill_is_usable())
                relevant_skill_count += 1;
        }
        result["relevant_skill_count"] = relevant_skill_count;
    }
    result["last compile time"] = __last_compile_time;
    
    result["monster_phylum"] = monster_phylum().to_string();
    return result;
}
