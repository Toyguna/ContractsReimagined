#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#include <contracts>

#pragma newdecls required


// ============== [ UTILITY ] ============== //

public bool IsClientValid(int client)
{
    return 0 < client <= MaxClients && IsClientConnected(client);
}