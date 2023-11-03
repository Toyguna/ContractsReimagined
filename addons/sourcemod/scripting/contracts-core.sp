#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#include <contracts>
#include <contracts-tasks.sp>
#include <contracts-natives.sp>
#include <contracts-utility.sp>
#include <contracts-database.sp>

#pragma newdecls required

public Plugin myinfo =
{
	name = "Contracts Reimagined",
	author = "Toyguna",
	description = "A SourceMod plugin for in-game contracts.",
	version = "b0.0.1",
	url = "https://github.com/Toyguna/ContractsReimagined"
};

// ============== [ GLOBAL VARIABLES ] ============== //


//  - Variables
ArrayList ga_PlayerContracts;
bool ga_bPlayerHasContract[MAXPLAYERS + 1] = { false, ... };

//   - Global Forwards
GlobalForward gforward_ContractCompletion;
GlobalForward gforward_TaskCompletion;

//  - ConVars
ConVar g_cvDatabaseCfg;


// ============== [ FORWARDS ] ============== //

public void OnPluginStart()
{
    /* / Initialization / */
    Init_Variables();
    Register_GlobalForwards();

    //  : Files
    FileTasks_Initialize();

    ReadTasks();
    ReadContracts();
}

public void OnPluginEnd()
{
    DB_SaveAllClients();
}

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
    RegPluginLibrary("contracts");

    Register_Natives();

    return APLRes_Success;
}

public void OnClientPutInServer(int client)
{
    LoadPlayer(client);
}

public void OnClientDisconnect(int client)
{
    UnloadPlayer(client);
}


// ============== [ INITIALIZATION ] ============== //

void Init_Variables()
{
    ga_PlayerContracts = new ArrayList(sizeof(Contracts_Contract));
}

void Init_ConVars()
{

}

void Register_GlobalForwards()
{
    gforward_TaskCompletion = new GlobalForward("Contracts_OnTaskCompletion", ET_Ignore, Param_Cell, Param_String, Param_Cell);
    gforward_ContractCompletion = new GlobalForward("Contracts_OnContractCompletion", ET_Ignore, Param_Cell, Param_String);
}

void Register_Natives()
{
    CreateNative("Contracts_ClientHasContract", Native_ClientHasContract);

    CreateNative("Contracts_GetClientContract", Native_GetClientContract);
    CreateNative("Contracts_SetClientContract", Native_SetClientContract);

    CreateNative("Contracts_TaskTypeFromString", Native_TaskTypeFromString);
    CreateNative("Contracts_StringFromTaskType", Native_StringFromTaskType);
    CreateNative("Contracts_TaskDetailFromString", Native_TaskDetailFromString);
    CreateNative("Contracts_StringFromTaskDetail", Native_StringFromTaskDetail);

    CreateNative("Contracts_CreateTaskFromId", Native_CreateTaskFromId);
    CreateNative("Contracts_CreateContractFromId", Native_CreateContractFromId);
}

// ============== [ FUNCTIONS ] ============== //

void LoadPlayer(int client)
{
    ga_bPlayerHasContract[client] = false;

    DB_LoadClient(client);

    ga_bPlayerHasContract[client] = true;
}

void UnloadPlayer(int client)
{
    DB_SaveClient(client);

    ga_bPlayerHasContract[client] = false;
} 


// ============== [ UTILITY ] ============== //

public bool ClientHasContract(int client)
{
    return ga_bPlayerHasContract[client];
}

/*
 * Get a player's contract
 *
 * @param client Client index
 * @param buffer Buffer to store contract
 * @param size Size of buffer
 * @return true if success, false otherwise
 */
public bool GetClientContract(int client, any[] buffer, int size)
{
    bool hasContract = ClientHasContract(client);

    if (!hasContract) return false;
    if (size < 1) return false;

    ga_PlayerContracts.GetArray(client, buffer, size);

    return true;
}

/*
 * Set a player's contract
 *
 * @param client Client index
 * @param contract Contract 
 * @param size Size of contract
 * @return true if success, false otherwise
 */
public void SetClientContract(int client, any[] contract, int size)
{
    if (size < 1) return;

    ga_PlayerContracts.SetArray(client, contract, size);

    ga_bPlayerHasContract[client] = true;
}


// ============== [ CALL FORWARDS ] ============== //

/*
    @param client Client Index
    @param contract_id Contract Id
*/ 
public void CallForward_OnContractCompletion(int client, const char[] contract_id)
{
    Call_StartForward(gforward_ContractCompletion);

    Call_PushCell(client);
    Call_PushString(contract_id);

    Call_Finish();
}

/*
    @param client Client Index
    @param task_id Task Id
    @param goal Goal
*/ 
public void CallForward_OnTaskCompletion(int client, const char[] task_id, int goal)
{
    Call_StartForward(gforward_TaskCompletion);

    Call_PushCell(client);
    Call_PushString(task_id);
    Call_PushCell(goal);

    Call_Finish();
}