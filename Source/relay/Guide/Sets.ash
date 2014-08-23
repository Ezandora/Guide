
import "relay/Guide/Support/Checklist.ash";
import "relay/Guide/Sets/Sets import.ash";

void SetsInit()
{
    SCountersInit();
    QHitsInit();
    
    SDNAInit();
}


void SetsGenerateResources(ChecklistEntry [int] available_resources_entries)
{
	SFamiliarsGenerateResource(available_resources_entries);
	SSemirareGenerateResource(available_resources_entries);
	SSkillsGenerateResource(available_resources_entries);
	SMiscItemsGenerateResource(available_resources_entries);
	SCopiedMonstersGenerateResource(available_resources_entries);
    STomesGenerateResource(available_resources_entries);
    SSmithsnessGenerateResource(available_resources_entries);
	SSugarGenerateResource(available_resources_entries);
    SPulverizeGenerateResource(available_resources_entries);
    SLibramGenerateResource(available_resources_entries);
    SWOTSFGenerateResource(available_resources_entries);
    SCountersGenerateResource(available_resources_entries);
    SGardensGenerateResource(available_resources_entries);
    SFaxGenerateResource(available_resources_entries);
    SJarlsbergGenerateResource(available_resources_entries);
    SCOTGenerateResource(available_resources_entries);
    SSneakyPeteGenerateResource(available_resources_entries);
    SDNAGenerateResource(available_resources_entries);
    SPlasticVampireFangsGenerateResource(available_resources_entries);
    SSpeakeasyGenerateResource(available_resources_entries);
    SHeavyRainsGenerateResource(available_resources_entries);
    
}

void SetsGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	SFamiliarsGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SSemirareGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SDispensaryGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SCouncilGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SCopiedMonstersGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SAftercoreGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	QHitsGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	S8bitRealmGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SDailyDungeonGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SCountersGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SWOTSFGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SKOLHSGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SBountyHunterHunterGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SOldLevel9GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SFaxGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SDungeonsOfDoomGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SPsychoanalyticGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SOlfactionGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SHolidayGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SRemindersGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SGrimstoneGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SSneakyPeteGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SDNAGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SHeavyRainsGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    
}


void SetsGenerateMissingItems(ChecklistEntry [int] items_needed_entries)
{
    QHitsGenerateMissingItems(items_needed_entries);
}