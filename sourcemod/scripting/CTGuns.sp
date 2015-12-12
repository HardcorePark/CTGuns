#pragma semicolon 1

#define PLUGIN_VERSION "1.06"
#define PLUGIN_PREFIX "[\x06Tango CT-Guns\x01]"

#include <sourcemod>
#include <SDKTools>

public Plugin myinfo = 
{
	name = "CTGuns",
	author = "Oscar Wos (OSWO)",
	description = "CTGuns",
	version = PLUGIN_VERSION,
	url = "www.tangoworldwide.net",
};

enum MainSubMenu
{
	pistols,
	rifles,
	snipers,
	smgs,
	shotguns,
	mgs,
};

enum PistolsSubMenu
{
	deagle,
	cz75,
	tec9,
	fiveseven,
	usps,
	glock18,
	p250,
	p2000,
	dualberettas,
	k8revolver,	
};

enum RiflesSubMenu
{
	ak47,
	aug,
	famas,
	galil,
	sg553,
	m4a1,
	m4a4,
}

Handle g_RoundTimer;
bool g_Enabled = true;

char g_PrimaryWeapon[MAXPLAYERS + 1][512];
char g_SecondaryWeapon[MAXPLAYERS + 1][512];

bool g_PickedPrimary[MAXPLAYERS + 1];
bool g_PickedSecondary[MAXPLAYERS + 1];

public OnPluginStart()
{
	RegConsoleCmd("sm_guns", Command_guns);
	HookEvent("round_start", Event_Start);
	HookEvent("round_end", Event_End);
	HookEvent("player_spawn", Event_Spawn);
	CreateTimer(120.0, advertisement, TIMER_REPEAT);
}

public Action advertisement(Handle timer)
{
	PrintToChatAll("%s If you wish to select your guns on CT. Write \x10!guns", PLUGIN_PREFIX);
}

public Action Event_Start(Handle event, char[] name, bool dontBroadcast)
{
	g_Enabled = true;
	g_RoundTimer = CreateTimer(30.0, Timer_Round);
}

public Action Event_End(Handle event, char[] name, bool dontBroadcast)
{
	g_Enabled = false;
	
	if (g_RoundTimer != INVALID_HANDLE)
	{
		if(CloseHandle(g_RoundTimer))
		{
			g_RoundTimer = INVALID_HANDLE;
		}
	}	
}

public Action Timer_Round(Handle timer)
{
	g_Enabled = false;
}

public Action Event_Spawn(Handle event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int clientTeam = GetClientTeam(client);
	if(clientTeam == 3)
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
			PrintToChat(client, "%s No Primary Picked! Use !guns", PLUGIN_PREFIX);
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
			PrintToChat(client, "%s No Secondary Picked! Use !guns", PLUGIN_PREFIX);
		}	
	}	
}

	
public Action Command_guns(client, args)
{	
	if (!IsPlayerAlive(client))
	{
		PrintToChat(client, "%s You must be alive!", PLUGIN_PREFIX);
		return Plugin_Handled;
	}
	
	if (GetClientTeam(client) != 3)
	{
		PrintToChat(client, "%s You are on the wrong team!", PLUGIN_PREFIX);
		return Plugin_Handled;
	}
	
	if (g_Enabled == false)
	{
		PrintToChat(client, "%s You can only use this command for the first 30 seconds!", PLUGIN_PREFIX);
		return Plugin_Handled;
	}

	Handle l_menu = CreateMenu(CTGunsMenuHandle, MENU_ACTIONS_ALL);
	SetMenuTitle(l_menu, "Tango CT Guns");
	AddMenuItem(l_menu, "0", "Pistols");
	AddMenuItem(l_menu, "1", "Rifles");
	DisplayMenu(l_menu, client, 0);
	
	return Plugin_Handled;
}

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
			case pistols:
			{
				PistolsMenu(client);
			}
			case rifles:
			{
				RiflesMenu(client);
			}
		}	
	}
}

public PistolsMenu(client)
{
	Handle pistol_menu = CreateMenu(PistolsMenuHandle, MENU_ACTIONS_ALL);
	SetMenuTitle(pistol_menu, "CT Guns - Pistols");
	AddMenuItem(pistol_menu, "0", "Desert Eagle");
	AddMenuItem(pistol_menu, "1", "CZ75-Auto");
	AddMenuItem(pistol_menu, "2", "Tec-9");
	AddMenuItem(pistol_menu, "3", "Five-SeveN");
	AddMenuItem(pistol_menu, "4", "USP-S");
	AddMenuItem(pistol_menu, "5", "Glock-18");
	AddMenuItem(pistol_menu, "6", "P250");
	AddMenuItem(pistol_menu, "7", "P2000");
	AddMenuItem(pistol_menu, "8", "Dual Berettas");
	AddMenuItem(pistol_menu, "9", "R8 Revolver");
	DisplayMenu(pistol_menu, client, 0);
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
		
		char weaponName[512];
		g_PickedSecondary[client] = true;
		
		switch(PistolsSubMenu:StringToInt(lOption))
		{
			case deagle:
			{
				PrintToChat(client, "%s You've been given a: \x07Deagle", PLUGIN_PREFIX);
				
				weaponName = "weapon_deagle";
				GivePlayerItem(client, weaponName, 0);
				g_SecondaryWeapon[client] = weaponName;
			}
			case cz75:
			{
				PrintToChat(client, "%s You've been given a: \x07CZ75", PLUGIN_PREFIX);
				
				weaponName = "weapon_cz75a";
				GivePlayerItem(client, weaponName, 0);
				g_SecondaryWeapon[client] = weaponName;
			}
			case tec9:
			{
				PrintToChat(client, "%s You've been given a: \x07Tec-9", PLUGIN_PREFIX);

				weaponName = "weapon_tec9";
				GivePlayerItem(client, weaponName, 0);
				g_SecondaryWeapon[client] = weaponName;
			}
			case fiveseven:
			{
				PrintToChat(client, "%s You've been given a: \x07Five-SeveN", PLUGIN_PREFIX);
				
				weaponName = "weapon_fiveseven";
				GivePlayerItem(client, weaponName, 0);
				g_SecondaryWeapon[client] = weaponName;
			}
			case usps:
			{
				PrintToChat(client, "%s You've been given a: \x07USP-S", PLUGIN_PREFIX);
				
				weaponName = "weapon_usp_silencer";
				GivePlayerItem(client, weaponName, 0);
				g_SecondaryWeapon[client] = weaponName;
			}
			case glock18:
			{
				PrintToChat(client, "%s You've been given a: \x07Glock-18", PLUGIN_PREFIX);
				
				weaponName = "weapon_glock";
				GivePlayerItem(client, weaponName, 0);
				g_SecondaryWeapon[client] = weaponName;
			}
			case p250:
			{
				PrintToChat(client, "%s You've been given a: \x07P250", PLUGIN_PREFIX);
				
				weaponName = "weapon_p250";
				GivePlayerItem(client, weaponName, 0);
				g_SecondaryWeapon[client] = weaponName;
			}
			case p2000:
			{
				PrintToChat(client, "%s You've been given a: \x07P2000", PLUGIN_PREFIX);

				weaponName = "weapon_hkp2000";
				GivePlayerItem(client, weaponName, 0);
				g_SecondaryWeapon[client] = weaponName;
			}
			case dualberettas:
			{
				PrintToChat(client, "%s You've been given: \x07Dual Berettas", PLUGIN_PREFIX);
				
				weaponName = "weapon_elite";
				GivePlayerItem(client, weaponName, 0);
				g_SecondaryWeapon[client] = weaponName;
			}
			case k8revolver:
			{
				PrintToChat(client, "%s You've been given a: \x07R8 Revolver", PLUGIN_PREFIX);
				
				weaponName = "weapon_revolver";
				GivePlayerItem(client, weaponName, 0);
				g_SecondaryWeapon[client] = weaponName;
			}
		}
	}
}

public RiflesMenu(client)
{
	Handle rifle_menu = CreateMenu(RiflesMenuHandle, MENU_ACTIONS_ALL);
	SetMenuTitle(rifle_menu, "CT Guns - Rifles");
	AddMenuItem(rifle_menu, "0", "AK-47");
	AddMenuItem(rifle_menu, "1", "AUG");
	AddMenuItem(rifle_menu, "2", "Famas");
	AddMenuItem(rifle_menu, "3", "Galil");
	AddMenuItem(rifle_menu, "4", "SG 553");
	AddMenuItem(rifle_menu, "5", "M4a1 - Silenced");
	AddMenuItem(rifle_menu, "6", "M4a4");
	DisplayMenu(rifle_menu, client, 0);
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
		
		char weaponName[512];
		g_PickedPrimary[client] = true;
		
		switch(PistolsSubMenu:StringToInt(lOption))
		{
			case ak47:
			{
				PrintToChat(client, "%s You've been given a: \x07AK-47", PLUGIN_PREFIX);
				
				weaponName = "weapon_ak47";
				GivePlayerItem(client, weaponName, 0);
				g_PrimaryWeapon[client] = weaponName;
			}
			case aug:
			{
				PrintToChat(client, "%s You've been given a: \x07AUG", PLUGIN_PREFIX);
				
				weaponName = "weapon_aug";
				GivePlayerItem(client, weaponName, 0);
				g_PrimaryWeapon[client] = weaponName;
			}
			case famas:
			{
				PrintToChat(client, "%s You've been given a: \x07Famas", PLUGIN_PREFIX);
				
				weaponName = "weapon_famas";
				GivePlayerItem(client, weaponName, 0);
				g_PrimaryWeapon[client] = weaponName;
			}
			case galil:
			{
				PrintToChat(client, "%s You've been given a: \x07Galil", PLUGIN_PREFIX);
				
				weaponName = "weapon_galilar";
				GivePlayerItem(client, weaponName, 0);
				g_PrimaryWeapon[client] = weaponName;
			}
			case sg553:
			{
				PrintToChat(client, "%s You've been given a: \x07SG553", PLUGIN_PREFIX);
				
				weaponName = "weapon_sg556";
				GivePlayerItem(client, weaponName, 0);
				g_PrimaryWeapon[client] = weaponName;
			}
			case m4a1:
			{
				PrintToChat(client, "%s You've been given a: \x07M4a1 - Silenced", PLUGIN_PREFIX);
				
				weaponName = "weapon_m4a1_silencer";
				GivePlayerItem(client, weaponName, 0);
				g_PrimaryWeapon[client] = weaponName;
			}
			case m4a4:
			{
				PrintToChat(client, "%s You've been given a: \x07M4a4", PLUGIN_PREFIX);
				
				weaponName = "weapon_m4a1";
				GivePlayerItem(client, weaponName, 0);
				g_PrimaryWeapon[client] = weaponName;
			}
		}
	}
}
			
stock bool IsValidPlayer(int client, bool alive = false)
{
   if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (alive == false || IsPlayerAlive(client)))
   {
       return true;
   }
   return false;
}
