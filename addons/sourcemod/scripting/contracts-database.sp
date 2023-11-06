#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#include <contracts>

#pragma newdecls required
#pragma semicolon 1

// BRUH NOT THE DA-TA-BA-SE A-GA-IN ! ! !

// ============== [ GLOBAL VARIABLES ] ============== //

Database hDatabase;


// ============== [ FUNCTIONS ] ============== //

public void DB_Connect()
{
    ConVar cfg = FindConVar("contracts_database_cfg");

    if (cfg == null) 
    {
        PrintToServer("%s %T", CONSOLE_PREFIX, "Err_DatabaseConnect", LANG_SERVER);
        return; 
    }

    char buffer[32];
    cfg.GetString(buffer, sizeof(buffer));

    Database.Connect(DB_GetDatabase, buffer);
}

public void DB_GetDatabase(Database db, const char[] error, any data)
{
    if (db == null)
    {
        PrintToServer("%s %T", CONSOLE_PREFIX, "Err_DatabaseConnect", LANG_SERVER);
        LogError("%s Database failure: %s", CHAT_PREFIX, error);
    }
    else 
    {
        hDatabase = db;
        PrintToServer("%s %T", CONSOLE_PREFIX, "Success_DatabaseConnect", LANG_SERVER);

        DB_CreateDatabase();
    }
}

public bool IsDatabaseNull()
{
    return hDatabase == null;
}

public void DB_CreateDatabase()
{
    if (IsDatabaseNull()) return;

    SQL_LockDatabase(hDatabase);
    // contracts_users
    SQL_FastQuery(hDatabase, 
    "CREATE TABLE IF NOT EXISTS contracts_users (userid int NOT NULL auto_increment PRIMARY KEY, authid varchar(64) NOT NULL UNIQUE, contractid varchar(32) NOT NULL);");
    // contracts_tasks
    SQL_FastQuery(hDatabase,
    "CREATE TABLE IF NOT EXISTS contracts_tasks (userid int NOT NULL, taskid varchar(32) NOT NULL, goal int NOT NULL, progress int NOT NULL, contractid varchar(32) NOT NULL);");
    SQL_UnlockDatabase(hDatabase);
}

public void DB_CreateClientEntry(int client)
{
    if (IsDatabaseNull()) return;
    if (DB_ClientHasEntry(client)) return;

    char authid[MAX_AUTHID_LENGTH];
    GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));

    Contracts_Contract contract;
    bool has_contract = Contracts_GetClientContract(client, contract, sizeof(contract));
    char contract_id[MAX_CONTRACT_ID];
    
    if (has_contract)
    {
        contract_id = contract.id;
    }
    else
    {
        contract_id = "false";
    }

    char query[256];
    Format(query, sizeof(query), 
    "INSERT INTO contracts_users(authid, contractid) VALUES ('%s','%s')",
    authid, contract_id
    );

    char name[MAX_NAME_LENGTH];
    GetClientName(client, name, sizeof(name));
    PrintToServer("%s %T", CONSOLE_PREFIX, "DB_FirstLogin", LANG_SERVER, name);

    SQL_LockDatabase(hDatabase);
    SQL_FastQuery(hDatabase, query);
    SQL_UnlockDatabase(hDatabase);
}

public bool DB_ClientHasEntry(int client)
{
    if (IsDatabaseNull()) return false;

    char authid[MAX_AUTHID_LENGTH];
    GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));

    char query[256];

    bool has_entry = false;

    Format(query, sizeof(query), "SELECT * FROM contracts_users WHERE authid = '%s';", authid);

    SQL_LockDatabase(hDatabase);
    DBResultSet hQuery = SQL_Query(hDatabase, query);

    if (SQL_GetRowCount(hQuery) != 0)
    {
        has_entry = true;
    }

    SQL_UnlockDatabase(hDatabase);

    delete hQuery;
    return has_entry;
}

public void DB_SaveAllClients()
{
    if (IsDatabaseNull()) return;

    for (int i = 0; i < GetClientCount(); i++)
    {
        if (!IsClientValid(i)) continue;
        if (IsFakeClient(i)) continue;

        DB_SaveClient(i);
    }

}

public void DB_SaveClient(int client)
{
    if (IsDatabaseNull()) return;
    if (!DB_ClientHasEntry(client)) DB_CreateClientEntry(client);

    int userid = DB_GetClientUserId(client);
    if (userid == -1) return;

    Contracts_Contract contract;
    bool has_contract = Contracts_GetClientContract(client, contract, sizeof(contract));

    char contract_id[MAX_CONTRACT_ID];

    if (has_contract)
    {
        contract_id = contract.id;
    }
    else
    {
        contract_id = "false";
    }

    // UPDATE CONTRACTS_USERS
    char query[256];
    Format(query, sizeof(query),
    "UPDATE contracts_users SET contractid = '%s' WHERE userid = %d;",
    contract_id, userid);

    SQL_LockDatabase(hDatabase);
    SQL_FastQuery(hDatabase, query);
    SQL_UnlockDatabase(hDatabase);

    // UPDATE CONTRACTS_TASKS

    //  : DELETE TASKS
    //  (try to delete even if player does not have tasks.)
    Format(query, sizeof(query),
    "DELETE FROM contracts_tasks WHERE userid = %d",
    userid);

    SQL_LockDatabase(hDatabase);
    SQL_FastQuery(hDatabase, query);
    SQL_UnlockDatabase(hDatabase);

    if (!has_contract) return;

    //  : CREATE TASKS
    ArrayList tasks = contract.tasks;

    Contracts_Task task;

    for (int i = 0; i < tasks.Length; i++)
    {
        tasks.GetArray(i, task, sizeof(task));

        Format(query, sizeof(query),
        "INSERT INTO contracts_tasks VALUES(%d, '%s', %d, %d, '%s')",
        userid, task.id, task.goal, task.progress, contract_id);

        SQL_LockDatabase(hDatabase);
        SQL_FastQuery(hDatabase, query);
        SQL_UnlockDatabase(hDatabase);
    }
}

public void DB_LoadClient(int client)
{
    if (IsDatabaseNull()) return;
    if (!DB_ClientHasEntry(client)) return;

    int userid = DB_GetClientUserId(client);
    if (userid == -1) return;

    char contractid[MAX_CONTRACT_ID];
    DB_GetClientContractId(client, contractid, sizeof(contractid));

    // Return if client does not have a contract registered in database
    if (StrEqual(contractid, "false")) return;

    Contracts_Contract contract;
    if (!Contracts_CreateContractFromId(contractid, contract, sizeof(contract))) return;

    ArrayList tasks = contract.tasks;

    char query[256];
    Format(query, sizeof(query),
    "SELECT * FROM contracts_tasks WHERE userid = %d;",
    userid);

    SQL_LockDatabase(hDatabase);
    DBResultSet hQuery = SQL_Query(hDatabase, query);

    int goal;
    int progress;

    int i = 0;

    Contracts_Task task;

    while (SQL_FetchRow(hQuery))
    {
        tasks.GetArray(i, task, sizeof(task));

        goal = SQL_FetchInt(hQuery, 2);
        progress = SQL_FetchInt(hQuery, 3);

        task.goal = goal;
        task.progress = progress;
        
        tasks.SetArray(i, task, sizeof(task));

        i++;
    }

    SQL_UnlockDatabase(hDatabase);
    delete hQuery;

    Contracts_SetClientContract(client, contract, sizeof(contract));
}

public void DB_GetClientContractId(int client, char[] buffer, int size)
{
    if (IsDatabaseNull()) return;
    if (!DB_ClientHasEntry(client)) return;

    if (size < 1) return;

    int userid = DB_GetClientUserId(client);
    if (userid == -1) return;

    char query[256];
    Format(query, sizeof(query), 
    "SELECT contractid FROM contracts_users WHERE userid = %d;",
    userid);

    SQL_LockDatabase(hDatabase);
    DBResultSet hQuery = SQL_Query(hDatabase, query);

    while (SQL_FetchRow(hQuery))
    {
        SQL_FetchString(hQuery, 0, buffer, size);
    }

    SQL_UnlockDatabase(hDatabase);

    delete hQuery;
}

public int DB_GetClientUserId(int client)
{
    if (IsDatabaseNull()) return -1;
    if (!DB_ClientHasEntry(client)) return -1;
    
    int userid = -1;

    char authid[MAX_AUTHID_LENGTH];
    GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));

    char query[256];

    Format(query, sizeof(query), "SELECT * FROM contracts_users WHERE authid = '%s';", authid);

    SQL_LockDatabase(hDatabase);
    DBResultSet hQuery = SQL_Query(hDatabase, query);

    while (SQL_FetchRow(hQuery))
    {
        userid = SQL_FetchInt(hQuery, 0);
    }

    SQL_UnlockDatabase(hDatabase);
    delete hQuery;

    return userid;
}