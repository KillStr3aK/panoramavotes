#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <regex>
#include <panoramavotes>

#pragma tabsize 4;
#pragma newdecls required;
#pragma semicolon 1;

#include "panoramavotes/PanoramaVote.sp"
#include "panoramavotes/VoteController.sp"

#include "panoramavotes/globals.sp"
#include "panoramavotes/helpers.sp"
#include "panoramavotes/forwards.sp"
#include "panoramavotes/callbacks.sp"
#include "panoramavotes/natives.sp"

public Plugin myinfo = 
{
	name = "[CS:GO] Panorama Votes",
	author = "Nexd @ Eternar, KoNLiG", // Most of the code & logic is used from KoNLiG's 'customvotes' plugin, and other sources back to 2014.
	description = "Exposes the functionality of the internal CS:GO vote panels.",
	version = "1.0",
	url = "https://github.com/KillStr3aK  | https://eternar.dev || https://steamcommunity.com/id/KoNLiGrL || KoNLiG#0001"
};

public void OnPluginStart()
{
	// Initialize user messages ids.
	if ((VoteStartMsg = GetUserMessageId("VoteStart")) == INVALID_MESSAGE_ID)
	{
		SetFailState("Couldn't get 'VoteStart' user message id.");
	}
	
	if ((VotePassMsg = GetUserMessageId("VotePass")) == INVALID_MESSAGE_ID)
	{
		SetFailState("Couldn't get 'VotePass' user message id.");
	}
	
	if ((VoteFailMsg = GetUserMessageId("VoteFailed")) == INVALID_MESSAGE_ID)
	{
		SetFailState("Couldn't get 'VoteFailed' user message id.");
	}

	// Hook 'vote' command which will be a votes receive listener.
	AddCommandListener(OnVoteReceived, "vote");
}