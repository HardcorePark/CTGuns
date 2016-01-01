#pragma semicolon 1
 
#define PLUGIN_VERSION "1.50"
#define PLUGIN_PREFIX "[\x06CT-Guns\x01]"
 
#include <sourcemod>
#include <sdktools>
 
#define WEAPONARRAYSIZE 64
 
public Plugin myinfo =
{
    name = "CT Guns",
    author = "Oscar Wos (OSWO), oaaron99",
    description = "CTGuns",
    version = PLUGIN_VERSION,
    url = "tangoworldwide.net",
};
 
/*ENUMS*/
enum MainSubMenu
{
    rifles,
    smgs,
    snipers,
    pistols,
}
 
char g_Smgs[][WEAPONARRAYSIZE] = {"ump45", "p90", "mp7", "mp9", "ppbizon", "mac10"};
char g_Rifles[][WEAPONARRAYSIZE] = {"ak47", "aug", "famas", "galil", "sg553", "m4a1", "m4a4"};
char g_Pistols[][WEAPONARRAYSIZE] = {"deagle", "cz75a", "tec9", "fiveseven", "usp_silencer", "glock", "p250", "hkp2000", "elite", "revolver"};
char g_Snipers[][WEAPONARRAYSIZE] = {"awp", "g3sg1", "ssg08", "scar20"};
 
char g_SmgsDis[][WEAPONARRAYSIZE] = {"UMP-45", "P90", "MP7", "MP9", "PP-Bizon", "MAC-10"};
char g_RiflesDis[][WEAPONARRAYSIZE] = {"AK-47", "AUG", "Famas", "Galil", "SG553", "M4a1 - Silenced", "M4a4"};
char g_PistolsDis[][WEAPONARRAYSIZE] = {"Deagle", "CZ75", "Tec-9", "Five-SeveN", "USP-S", "Glock-18", "P250", "P2000", "Dual Berettas", "R8 Revolver"};
char g_SnipersDis[][WEAPONARRAYSIZE] = {"AWP", "G3SG1", "SSG 08", "SCAR-20"};
 
/* GLOBALS */
char g_PrimaryWeapon[MAXPLAYERS + 1][512];
char g_SecondaryWeapon[MAXPLAYERS + 1][512];
 
bool g_PickedPrimary[MAXPLAYERS + 1];
bool g_PickedSecondary[MAXPLAYERS + 1];
bool g_GiveWeapons[MAXPLAYERS + 1];
bool g_TakenThisRound[MAXPLAYERS + 1];
 
/* MAINS */
public OnPluginStart()
{
    HookEvent("round_start", Event_Start);
    HookEvent("player_spawn", Event_Spawn);
    RegConsoleCmd("sm_ctguns", Command_ctguns);
    CreateTimer(120.0, advertisement, _, TIMER_REPEAT);
}
 
public Action Event_Start(Handle event, char[] name, bool dontBroadcast)
{
    for (int i = 0; i <= MAXPLAYERS + 1; i++)
    {
        if (IsValidPlayer(i))
        {
            g_TakenThisRound[i] = false;
        }
    }
}
 
public Action advertisement(Handle timer)
{
    PrintToChatAll("%s Type \x07!ctguns \x01to select your gun loadouts!", PLUGIN_PREFIX);
}
 
public Action Event_Spawn(Handle event, char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    int clientTeam = GetClientTeam(client);
    if(clientTeam == 3)
    {
        CreateTimer(0.1, giveguns, client);
    }  
}
 
public Action giveguns(Handle timer, any client)
{
    if(g_PickedPrimary[client] == true)
    {
        int weaponI = GetPlayerWeaponSlot(client, 0);
        if (weaponI != -1)
        {
            RemovePlayerItem(client, weaponI);
            RemoveEdict(weaponI);
        }
       
        GivePlayerItem(client, g_PrimaryWeapon[client], 0);
       
    } else {
        PrintToChat(client, "%s No Primary Picked! Use !ctguns", PLUGIN_PREFIX);
    }
   
    if(g_PickedSecondary[client] == true)
    {
        int weaponI = GetPlayerWeaponSlot(client, 1);
        if (weaponI != -1)
        {
            RemovePlayerItem(client, weaponI);
            RemoveEdict(weaponI);
        }
       
        GivePlayerItem(client, g_SecondaryWeapon[client], 0);
       
    } else {
        PrintToChat(client, "%s No Secondary Picked! Use !ctguns", PLUGIN_PREFIX);
    }  
}
 
public Action Command_ctguns(client, args)
{  
    if (g_TakenThisRound[client] && IsPlayerAlive(client))
    {
        PrintToChat(client, "%s You've already used !ctguns this round... You can use it when you die!", PLUGIN_PREFIX);
        return Plugin_Handled;
    }
   
    if (!IsPlayerAlive(client))
    {
        g_GiveWeapons[client] = false;
        PrintToChat(client, "%s You'll be given your weapons when you spawn in!", PLUGIN_PREFIX);
    } else {
        g_GiveWeapons[client] = true;
    }
   
    if (GetClientTeam(client) != 3)
    {
        PrintToChat(client, "%s You are on the wrong team!", PLUGIN_PREFIX);
        return Plugin_Handled;
    }
   
    MainMenu(client);
   
    g_TakenThisRound[client] = true;
   
    return Plugin_Handled;
}  
 
/* SUBS */
public MainMenu(client)
{
    Handle l_menu = CreateMenu(CTGunsMenuHandle, MENU_ACTIONS_ALL);
    SetMenuTitle(l_menu, "CT Guns");
    AddMenuItem(l_menu, "0", "Rifles");
    AddMenuItem(l_menu, "1", "SMGs");
    AddMenuItem(l_menu, "2", "Snipers");
    AddMenuItem(l_menu, "3", "Pistols");
    DisplayMenu(l_menu, client, 0);
}
 
public PistolsMenu(client)
{
    Handle pistol_menu = CreateMenu(PistolsMenuHandle, MENU_ACTIONS_ALL);
    SetMenuTitle(pistol_menu, "CT Guns - Pistols");
   
    char value[8];
   
    for (int i = 0; i <= 9; i++)
    {
        IntToString(i, value, sizeof(value));
        AddMenuItem(pistol_menu, value, g_PistolsDis[i]);
    }
   
    DisplayMenu(pistol_menu, client, 0);
}
 
public RiflesMenu(client)
{
    Handle rifle_menu = CreateMenu(RiflesMenuHandle, MENU_ACTIONS_ALL);
    SetMenuTitle(rifle_menu, "CT Guns - Rifles");  
 
    char value[8];
   
    for (int i = 0; i <= 6; i++)
    {
        IntToString(i, value, sizeof(value));
        AddMenuItem(rifle_menu, value, g_RiflesDis[i]);
    }
   
    DisplayMenu(rifle_menu, client, 0);
}
 
public SnipersMenu(client)
{
    Handle snipers_menu = CreateMenu(SnipersMenuHandle, MENU_ACTIONS_ALL);
    SetMenuTitle(snipers_menu, "CT Guns - Snipers");
 
    char value[8];
   
    for (int i = 0; i <= 3; i++)
    {
        IntToString(i, value, sizeof(value));
        AddMenuItem(snipers_menu, value, g_SnipersDis[i]);
    }
   
    DisplayMenu(snipers_menu, client, 0);
}
 
public SmgsMenu(client)
{
    Handle smgs_menu = CreateMenu(SmgsMenuHandle, MENU_ACTIONS_ALL);
    SetMenuTitle(smgs_menu, "CT Guns - SMGs");
 
    char value[8];
   
    for (int i = 0; i <= 5; i++)
    {
        IntToString(i, value, sizeof(value));
        AddMenuItem(smgs_menu, value, g_SmgsDis[i]);
    }
   
    DisplayMenu(smgs_menu, client, 0);
}
 
/* MENU HANDLES */
public CTGunsMenuHandle(Handle menu, MenuAction action, client, option)
{
    if(action == MenuAction_Select && IsValidPlayer(client))
    {
        char lOption[32];
        if(!GetMenuItem(menu, option, lOption, sizeof(lOption)))
        {
            PrintToChat(client, "%s Invalid Option", PLUGIN_PREFIX);
        }
       
        switch(MainSubMenu:StringToInt(lOption))
        {
            case rifles:
            {
                RiflesMenu(client);
            }
            case smgs:
            {
                SmgsMenu(client);
            }
            case snipers:
            {
                SnipersMenu(client);
            }
            case pistols:
            {
                PistolsMenu(client);
            }
        }  
    }
}
 
public RiflesMenuHandle(Handle menu, MenuAction action, client, option)
{
    if(action == MenuAction_Select && IsValidPlayer(client))
    {
        char lOption[32];
        if(!GetMenuItem(menu, option, lOption, sizeof(lOption)))
        {
            PrintToChat(client, "%s Invalid Option", PLUGIN_PREFIX);
        }
       
        int weaponI = GetPlayerWeaponSlot(client, 0);
        if (weaponI != -1)
        {
            RemovePlayerItem(client, weaponI);
            RemoveEdict(weaponI);
        }
       
        g_PickedPrimary[client] = true;
       
        PostMenuSelection(client, true, g_Rifles[option], g_RiflesDis[option]);
    }
}
 
public SmgsMenuHandle(Handle menu, MenuAction action, client, option)
{
    if(action == MenuAction_Select && IsValidPlayer(client))
    {
        char lOption[32];
        if(!GetMenuItem(menu, option, lOption, sizeof(lOption)))
        {
            PrintToChat(client, "%s Invalid Option", PLUGIN_PREFIX);
        }
       
        int weaponI = GetPlayerWeaponSlot(client, 0);
        if (weaponI != -1)
        {
            RemovePlayerItem(client, weaponI);
            RemoveEdict(weaponI);
        }
       
        g_PickedPrimary[client] = true;
       
        PostMenuSelection(client, true, g_Smgs[option], g_SmgsDis[option]);
    }
}
 
public SnipersMenuHandle(Handle menu, MenuAction action, client, option)
{
    if(action == MenuAction_Select && IsValidPlayer(client))
    {
        char lOption[32];
        if(!GetMenuItem(menu, option, lOption, sizeof(lOption)))
        {
            PrintToChat(client, "%s Invalid Option", PLUGIN_PREFIX);
        }
       
        int weaponI = GetPlayerWeaponSlot(client, 0);
        if (weaponI != -1)
        {
            RemovePlayerItem(client, weaponI);
            RemoveEdict(weaponI);
        }
       
        g_PickedPrimary[client] = true;
       
        PostMenuSelection(client, true, g_Snipers[option], g_SnipersDis[option]);
    }
}
 
public PistolsMenuHandle(Handle menu, MenuAction action, client, option)
{
    if(action == MenuAction_Select && IsValidPlayer(client))
    {
        char lOption[32];
        if(!GetMenuItem(menu, option, lOption, sizeof(lOption)))
        {
            PrintToChat(client, "%s Invalid Option", PLUGIN_PREFIX);
        }
       
        int weaponI = GetPlayerWeaponSlot(client, 1);
        if (weaponI != -1)
        {
            RemovePlayerItem(client, weaponI);
            RemoveEdict(weaponI);
        }
       
        g_PickedSecondary[client] = true;
       
        PostMenuSelection(client, false, g_Pistols[option], g_PistolsDis[option]);
    }
}
 
/* FUNCTIONS */
stock void PostMenuSelection(int client, bool primary, char[] weapon, char[] disName)
{
    if (IsPlayerAlive(client))
    {
        PrintToChat(client, "%s You've been given a(n): \x07%s", PLUGIN_PREFIX, disName);
    } else {
        PrintToChat(client, "%s Your loadout now has a(n): \x07%s", PLUGIN_PREFIX, disName);
    }
   
    char weaponName[128];
    strcopy(weaponName, sizeof(weaponName), weapon);
    Format(weaponName, sizeof(weaponName), "weapon_%s", weaponName);
   
    if (primary)
    {
        g_PrimaryWeapon[client] = weaponName;
    }
    else
    {
        g_SecondaryWeapon[client] = weaponName;
    }
   
    if (g_GiveWeapons[client])
        GivePlayerItem(client, weaponName, 0);     
}
 
stock bool IsValidPlayer(int client, bool alive = false)
{
    if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (alive == false || IsPlayerAlive(client)))
    {
       return true;
    }
   
    return false;
}