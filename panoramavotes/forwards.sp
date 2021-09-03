public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// Only CS:GO is supported.
	if (GetEngineVersion() != Engine_CSGO)
	{
		strcopy(error, err_max, "Only CS:GO is supported.");
		return APLRes_Failure;
	}

	CreateNative("PanoramaVote.PanoramaVote", Native_PanoramaVote_Instance);
	CreateNative("PanoramaVote.Execute", Native_PanoramaVote_Execute);
	CreateNative("PanoramaVote.AddClient", Native_PanoramaVote_AddClient);

	CreateNative("PanoramaVote.Cancel", Native_PanoramaVote_Cancel);
	CreateNative("PanoramaVote.GetFailReason", Native_PanoramaVote_GetFailReason);

	CreateNative("PanoramaVote.SetDisplayText", Native_PanoramaVote_SetDisplayText);
	CreateNative("PanoramaVote.SetPassedText", Native_PanoramaVote_SetPassedText);
	CreateNative("PanoramaVote.SetCallbackData", Native_PanoramaVote_SetCallbackData);

	CreateNative("PanoramaVote.Initiator.get", Native_PanoramaVote_Initiator_get);
	CreateNative("PanoramaVote.Initiator.set", Native_PanoramaVote_Initiator_set);

	CreateNative("PanoramaVote.Team.get", Native_PanoramaVote_Team_get);
	CreateNative("PanoramaVote.Team.set", Native_PanoramaVote_Team_set);

	CreateNative("PanoramaVote.PassPercentage.get", Native_PanoramaVote_PassPercentage_get);
	CreateNative("PanoramaVote.PassPercentage.set", Native_PanoramaVote_PassPercentage_set);
	
	CreateNative("PanoramaVote.Issue.get", Native_PanoramaVote_Issue_get);
	CreateNative("PanoramaVote.Issue.set", Native_PanoramaVote_Issue_set);

	OnClientVoteReceived = new GlobalForward("PanoramaVotes_OnVoteReceive", ET_Hook, Param_Cell, Param_CellByRef);

	RegPluginLibrary("panoramavotes");
	return APLRes_Success;
}

public void OnMapStart()
{
	VoteManager = new VoteController();
}

public Action OnVoteReceived(int client, const char[] command, int argc)
{
	if(!VoteManager.IsVoteInProgress)
		return Plugin_Continue;
	
	char vote_choice[16];
	GetCmdArg(1, vote_choice, sizeof(vote_choice));
	
	// Convert the client vote decision into a integer (0 = Yes, 1 = No)
	int vote_decision = StringToInt(vote_choice[6]) - 1;
	
	// Execute the vote receive forward.
	Action fwd_return;
	Call_StartForward(OnClientVoteReceived);
	Call_PushCell(client); // int client
	Call_PushCellRef(vote_decision); // int &decision
	int error = Call_Finish(fwd_return);

	if (error != SP_ERROR_NONE)
	{
		ThrowNativeError(error, "OnClientVoteReceived - Error: %d", error);
		return Plugin_Stop;
	}

	// Stop the further actions if needs to.
	if (fwd_return >= Plugin_Handled)
	{
		int clients[1];
		clients[0] = client;
		
		int clients_count = 1;
		
		DisplayCustomVotePanel(clients, clients_count);	
		return fwd_return;
	}

	CastVote option = view_as<CastVote>(vote_decision);
	VoteManager.SetOptionCount(option, VoteManager.GetOptionCount(option) + 1);

	if(VoteManager.PotentialVotes <= (VoteManager.YesCount + VoteManager.NoCount))
	{
		DisplayCustomVoteResults();
	}

	return Plugin_Handled;
}

public void OnClientDisconnect_Post(int client)
{
	if (!VoteManager.IsVoteInProgress)
		return;

	if(GetClientCount() == 0)
	{
		DisplayCustomVoteResults();
	} else {
		if(ClientDecision[client] != VOTE_DECISION_NONE)
		{
			CastVote voteOption = view_as<CastVote>(ClientDecision[client]);
			VoteManager.SetOptionCount(voteOption, VoteManager.GetOptionCount(voteOption) - 1);
			ClientDecision[client] = VOTE_DECISION_NONE;
		}
	}
}