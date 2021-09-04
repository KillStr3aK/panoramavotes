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
	vote.SetDisplayText("is <img src='https://cdn.discordapp.com/avatars/262042968628789249/01886a53c044bc43a96bce8009e066db.png?size=32'/> Er!k a <b>rat</b>?");
	vote.SetPassedText("<font color='#3df218'>Yes!</font>");
	vote.Execute(15, OnPassed, OnFailed);
	return Plugin_Handled;
}

void OnPassed(int results[MAXPLAYERS + 1])
{
	PrintToChatAll(" \x04atleast good in beat saber! watch him playing: https://www.twitch.tv/er1k97");
}

void OnFailed(int results[MAXPLAYERS + 1])
{
	PrintToChatAll(" \x07oh bro you're right, he made antidll, isn't he?");
}

public Action PanoramaVotes_OnVoteReceive(int client, int &decision)
{
	PrintToChatAll(" \x06%N \x01voted %s", client, decision == 0 ? "\x04yes" : "\x07no");
}