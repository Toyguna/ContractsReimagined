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
        PrintToServer("[Contracts] %T", "Err_DatabaseConnect", LANG_SERVER);
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
        PrintToServer("[Contracts] %T", "Err_DatabaseConnect", LANG_SERVER);
        LogError("[Contracts] Database failure: %s", error);
    }
    else 
    {
        hDatabase = db;
        PrintToServer("[Contracts] %T", "Success_DatabaseConnect", LANG_SERVER);

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
}

public void DB_CreateClientEntry(int client)
{
    if (IsDatabaseNull()) return;
}

public bool DB_ClientHasEntry(int client)
{
    if (IsDatabaseNull()) return false;

    return true;
}

public void DB_SaveAllClients()
{
    if (IsDatabaseNull()) return;

}

public void DB_SaveClient(int client)
{
    if (IsDatabaseNull()) return;

}

public void DB_LoadClient(int client)
{
    if (IsDatabaseNull()) return;

}