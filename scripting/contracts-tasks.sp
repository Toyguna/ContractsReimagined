#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#include <contracts>

#pragma newdecls required

// ============== [ GLOBAL VARIABLES ] ============== //

StringMap g_smTasks;
StringMap g_smContracts;

char CFG_TASKS[PLATFORM_MAX_PATH] = "addons/sourcemod/configs/ContractsReimagined/tasks.cfg";
char CFG_CONTRACTS[PLATFORM_MAX_PATH] = "addons/sourcemod/configs/ContractsReimagined/contracts.cfg";

// ============== [ FUNCTIONS ] ============== //

public void FileTasks_Initialize()
{
    g_smTasks = new StringMap();
    g_smContracts = new StringMap();
}

public void ReadTasks()
{
    g_smTasks.Clear();

    KeyValues kv = new KeyValues("Tasks");

    kv.ImportFromFile(CFG_TASKS);

    char id[MAX_TASK_ID];

    kv.GotoFirstSubKey(false);

    do {
        kv.GetSectionName(id, sizeof(id));

        Contracts_Task task;
        task.id = id;

        ReadTaskKey(kv, task)

        g_smTasks.SetArray(id, task, sizeof(task), true);
    } while(kv.GotoNextKey(false))

    delete kv;
}

void ReadTaskKey(KeyValues kv, Contracts_Task task)
{
    char section[255];

    char name[MAX_TASK_NAME];
    char str_type[MAX_TASK_STRTYPE];
    char str_detail_as[MAX_TASK_STRDETAIL];
    char str_detail_target[MAX_TASK_STRDETAIL];

    Contracts_TaskType type;
    Contracts_TaskDetail detail_as;
    Contracts_TaskDetail detail_target;

    kv.GetString("display_name", name, sizeof(name));
    kv.GetString("type", str_type, sizeof(str_type));

    kv.GotoFirstSubKey(false);

    do {
        kv.GetSectionName(section, sizeof(section));

        if (StrEqual(section, "details"))
        {
            kv.GetString("target", str_detail_as, sizeof(str_detail_as));
            kv.GetString("as", str_detail_target, sizeof(str_detail_target));

            break;
        }
    } while(kv.GotoNextKey(false))

    type = Contracts_TaskTypeFromString(str_type, sizeof(str_type));
    detail_as = Contracts_TaskDetailFromString(str_detail_as, sizeof(str_detail_as));
    detail_target = Contracts_TaskDetailFromString(str_detail_target, sizeof(str_detail_target));

    task.name = name;
    task.type = type;
    task.detail_as = detail_as;
    task.detail_target = detail_target;
    task.progress = 0;
    task.goal = -1;

    kv.GoBack();
}

public void ReadContracts()
{
    g_smContracts.Clear();

    KeyValues kv = new KeyValues("Contracts");

    kv.ImportFromFile(CFG_CONTRACTS);

    char id[MAX_CONTRACT_ID];

    kv.GotoFirstSubKey(false);

    do {
        kv.GetSectionName(id, sizeof(id));
        PrintToServer("contract: %s", id);

        Contracts_Contract contract;
        contract.Init();

        contract.id = id;

        ReadContractKey(kv, contract);

    } while(kv.GotoNextKey(false))

    delete kv;

}

void ReadContractKey(KeyValues kv, Contracts_Contract contract)
{
    char id[MAX_TASK_ID];

    char name[MAX_CONTRACT_NAME];

    kv.GetString("display_name", name, sizeof(name));
    
    kv.GotoFirstSubKey(false);
    kv.GotoNextKey(false);
    kv.GotoFirstSubKey(false); // go

    contract.name = name;

    Contracts_Task task;

    do {
        kv.GetSectionName(id, sizeof(id));
        PrintToServer("- id: %s", id);

        int goal = kv.GetNum(NULL_STRING, -1);
        PrintToServer("L goal: %d", goal);

        Contracts_CreateTaskFromId(id, task, sizeof(task));
        task.goal = goal;

        contract.AddTask(task);

    } while(kv.GotoNextKey(false))

    PrintToServer("contract name: %s \n", name);

    kv.GoBack();
    kv.GoBack();
}

// ============== [ UTILITY ] ============== //

/*
 * @return true on success, false otherwise
 */
public bool GetTaskTemplate(const char[] id, any[] buffer, int size)
{
    return g_smTasks.GetArray(id, buffer, size);
}

/*
 * @return true on success, false otherwise
 */
public bool GetContractTemplate(const char[] id, any[] buffer, int size)
{
    return g_smContracts.GetArray(id, buffer, size);
}