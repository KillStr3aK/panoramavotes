public Action Timer_DisplayCustomVoteResults(Handle timer)
{
	VoteInfo.Timeout = INVALID_HANDLE;
	DisplayCustomVoteResults();
}

void DisplayCustomVotePanel(int[] clients, int clients_count)
{
	Protobuf msg = view_as<Protobuf>(StartMessageEx(VoteStartMsg, clients, clients_count, USERMSG_RELIABLE));
	
	msg.SetInt("team", VoteInfo.Setup.Team);
	msg.SetInt("ent_idx", VoteInfo.Setup.Initiator);
	msg.SetInt("vote_type", view_as<int>(VoteInfo.Setup.Issue));
	msg.SetString("disp_str", VoteInfo.Setup.DisplayString);
	msg.SetString("details_str", "");
	msg.SetString("other_team_str", ""); // Not used in CS:GO, permanently disabled by Valve.
	msg.SetBool("is_yes_no_vote", true);
	msg.SetInt("entidx_target", 0);
	
	EndMessage();
}

void DisplayCustomVoteResults()
{
	int positive_votes = VoteManager.GetOptionCount(VOTE_OPTION1);
	
	int clients[MAXPLAYERS];
	int client_count;
	GetVoteBroadcastClients(clients, client_count);
	
	PanoramaVoteCallback callback;
	bool reset = false;
	
	if ((float(positive_votes) / float(client_count)) * 100.0 >= VoteInfo.Setup.PassPercentage)
	{
		if (!PrecacheImage(VoteInfo.Setup.PassedString, Timer_RepeatVotePass))
		{
			Protobuf msg = view_as<Protobuf>(StartMessageEx(VotePassMsg, clients, client_count, USERMSG_RELIABLE));
			
			msg.SetInt("team", VoteInfo.Setup.Team);
			msg.SetInt("vote_type", view_as<int>(VoteInfo.Setup.Issue));
			msg.SetString("disp_str", VoteInfo.Setup.PassedString);
			msg.SetString("details_str", "");
			
			EndMessage();
			reset = true;
		}
		
		callback = VoteInfo.PassedCallback;
	}
	else
	{
		Protobuf msg = view_as<Protobuf>(StartMessageEx(VoteFailMsg, clients, client_count, USERMSG_RELIABLE));
		
		msg.SetInt("team", VoteInfo.Setup.Team);
		msg.SetInt("reason", view_as<int>(PanoramaVote.GetFailReason()));
		
		EndMessage();
		
		callback = VoteInfo.FailedCallback;
	}
	
	if (callback != INVALID_FUNCTION)
	{
		Call_StartFunction(VoteInfo.Plugin, callback);
		Call_PushArray(ClientDecision, sizeof(ClientDecision));

		if(VoteInfo.Setup.Data != 0)
			Call_PushCell(VoteInfo.Setup.Data);
			
		Call_Finish();
	}
	
	if(reset)
		VoteInfo.Reset();
		
	VoteManager.IsVoteInProgress = false;
}

Action Timer_RepeatVotePass(Handle timer)
{
	int clients[MAXPLAYERS];
	int client_count;
	GetVoteBroadcastClients(clients, client_count);
	
	Protobuf msg = view_as<Protobuf>(StartMessageEx(VotePassMsg, clients, client_count, USERMSG_RELIABLE));
	
	msg.SetInt("team", VoteInfo.Setup.Team);
	msg.SetInt("vote_type", view_as<int>(VoteInfo.Setup.Issue));
	msg.SetString("disp_str", VoteInfo.Setup.PassedString);
	msg.SetString("details_str", "");
	
	EndMessage();
	VoteInfo.Reset();
}

public Action Timer_RepeatVoteDisplay(Handle timer)
{
	int clients[MAXPLAYERS];
	int client_count;
    
	GetVoteBroadcastClients(clients, client_count);
	DisplayCustomVotePanel(clients, client_count);
}