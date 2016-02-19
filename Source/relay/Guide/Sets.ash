
import "relay/Guide/Support/Checklist.ash";
import "relay/Guide/Sets/Sets import.ash";

void SetsInit()
{
    SCountersInit();
    QHitsInit();
}


void SetsGenerateResources(ChecklistEntry [int] resource_entries)
{
	SFamiliarsGenerateResource(resource_entries);
	SSemirareGenerateResource(resource_entries);
	SSkillsGenerateResource(resource_entries);
	SMiscItemsGenerateResource(resource_entries);
	SCopiedMonstersGenerateResource(resource_entries);
    SPulveriseGenerateResource(resource_entries);
    SCountersGenerateResource(resource_entries);
    SFaxGenerateResource(resource_entries);
    SClassesGenerateResource(resource_entries);
    SEquipmentGenerateResource(resource_entries);
    S8bitRealmGenerateResource(resource_entries);
    SCalculateUniverseGenerateResource(resource_entries);
    SEventsGenerateResource(resource_entries);
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
	SBountyHunterHunterGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SOldLevel9GenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SFaxGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SDungeonsOfDoomGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SOlfactionGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SHolidayGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SRemindersGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SEventsGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SClassesGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SEquipmentGenerateTasks(task_entries, optional_task_entries, future_task_entries);
	SMiscItemsGenerateTasks(task_entries, optional_task_entries, future_task_entries);
    SPVPGenerateTasks(task_entries, optional_task_entries, future_task_entries);
}


void SetsGenerateMissingItems(ChecklistEntry [int] items_needed_entries)
{
    QHitsGenerateMissingItems(items_needed_entries);
}