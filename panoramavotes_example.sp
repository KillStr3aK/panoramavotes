#include <sourcemod>
#include <panoramavotes>

#pragma tabsize 0;
#pragma newdecls required;
#pragma semicolon 1;

public Plugin myinfo = 
{
	name = "Example usage of PanoramaVotes",
	author = "Nexd",
	description = "",
	version = "1.0",
	url = "https://github.com/KillStr3aK"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_testvote", Command_TestVote);
}

public Action Command_TestVote(int client, int args)
{
	PanoramaVote vote = new PanoramaVote(client);
	vote.SetDisplayText("Enable <b>bunnyhop</b>?");
	vote.SetPassedText("<font color='#3df218'>Yes!</font>");
	vote.Execute(15, OnPassed, OnFailed);
	return Plugin_Handled;
}

void OnPassed(int results[MAXPLAYERS + 1])
{
	ConVar sv_autobunnyhopping = FindConVar("sv_autobunnyhopping");
	sv_autobunnyhopping.BoolValue = true;
	
	PrintToChatAll(" \x04Bunnyhop enabled!");
}

void OnFailed(int results[MAXPLAYERS + 1])
{
	PrintToChatAll(" \x07unluko, keep walking");
}

public Action PanoramaVotes_OnVoteReceive(int client, int &decision)
{
	PrintToChatAll(" \x06%N \x01voted %s", client, decision == 0 ? "\x04yes" : "\x07no");
}