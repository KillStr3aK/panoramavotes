public int Native_PanoramaVote_Instance(Handle plugin, int params)
{
    int initiator = GetNativeCell(1);
    VoteInfo.Setup.Initiator = initiator;
    return initiator;
}

public int Native_PanoramaVote_Cancel(Handle plugin, int params)
{
    if(!VoteManager.IsVoteInProgress)
    {
        return ThrowNativeError(SP_ERROR_NATIVE, "No vote is in progress.");
    }

    if(VoteInfo.Plugin != plugin)
    {
        return ThrowNativeError(SP_ERROR_NATIVE, "Cannot cancel other plugin vote.");
    }

    int clients[MAXPLAYERS];
	int client_count;
	GetVoteBroadcastClients(clients, client_count);
	
	Protobuf msg = view_as<Protobuf>(StartMessageEx(VoteFailMsg, clients, client_count, USERMSG_RELIABLE));
	
	msg.SetInt("team", VoteInfo.Setup.Team);
	msg.SetInt("reason", view_as<int>(VOTE_FAILED_GENERIC));
	
	EndMessage();

    VoteInfo.Reset();
    VoteManager.IsVoteInProgress = false;
    return 0;
}

public int Native_PanoramaVote_Execute(Handle plugin, int params)
{
    if(VoteManager.IsVoteInProgress)
    {
        return ThrowNativeError(SP_ERROR_NATIVE, "A vote is already in progress.");
    }

    if(VoteInfo.Setup.Team == CS_TEAM_NONE)
        VoteInfo.Setup.Team = VOTE_TEAMID_EVERYONE;

    if(VoteInfo.Setup.PassPercentage == 0.0)
        VoteInfo.Setup.PassPercentage = DEFAULT_PASS_PERCENTAGE;
    
    VoteInfo.Plugin = plugin;
    VoteInfo.PassedCallback = view_as<PanoramaVoteCallback>(GetNativeFunction(3));
    VoteInfo.FailedCallback = view_as<PanoramaVoteCallback>(GetNativeFunction(4));

    VoteManager.OnlyTeamToVote = VoteInfo.Setup.Team;

    for(CastVote option = VOTE_OPTION1; option < VOTE_UNCAST; option++)
    {
        VoteManager.SetOptionCount(option, 0);
    }

    VoteManager.IsVoteInProgress = true;
    UpdatePotentialVotes();

    if (!PrecacheImage(VoteInfo.Setup.DisplayString, Timer_RepeatVoteDisplay))
	{
		int clients[MAXPLAYERS];
		int client_count;
		GetVoteBroadcastClients(clients, client_count);
		DisplayCustomVotePanel(clients, client_count);
	}

    int timeout = GetNativeCell(2);
    if(timeout != VOTE_DURATION_FOREVER)
    {
        delete VoteInfo.Timeout;
        VoteInfo.Timeout = CreateTimer(float(timeout), Timer_DisplayCustomVoteResults);
    }

    for(int i = 1; i <= MaxClients; i++)
    {
        ClientDecision[i] = VOTE_DECISION_NONE;
    }

    return 0;
}

public any Native_PanoramaVote_GetFailReason(Handle plugin, int params)
{
    int positive_votes = VoteManager.GetOptionCount(VOTE_OPTION1);
	int negative_votes = VoteManager.GetOptionCount(VOTE_OPTION2);
		
	// No one voted.
	if (!(positive_votes + negative_votes))
	{
		return VOTE_FAILED_QUORUM_FAILURE;
	}
		
	// Not enough players voted positively.
	if (negative_votes > positive_votes && VoteInfo.Setup.PassPercentage == DEFAULT_PASS_PERCENTAGE)
	{
		return VOTE_FAILED_YES_MUST_EXCEED_NO;
	}
		
	// Generic failure.
	return VOTE_FAILED_GENERIC;
}

public int Native_PanoramaVote_SetDisplayText(Handle plugin, int params)
{
    GetNativeString(2, VoteInfo.Setup.DisplayString, sizeof(PanoramaVoteSetup::DisplayString));
}

public int Native_PanoramaVote_SetPassedText(Handle plugin, int params)
{
    GetNativeString(2, VoteInfo.Setup.PassedString, sizeof(PanoramaVoteSetup::PassedString));
}

public int Native_PanoramaVote_SetCallbackData(Handle plugin, int params)
{
    VoteInfo.Setup.Data = GetNativeCell(2);
}

public int Native_PanoramaVote_Initiator_set(Handle plugin, int params)
{
    VoteInfo.Setup.Initiator = GetNativeCell(2);
}

public int Native_PanoramaVote_Team_set(Handle plugin, int params)
{
    VoteInfo.Setup.Team = GetNativeCell(2);
}

public int Native_PanoramaVote_PassPercentage_set(Handle plugin, int params)
{
    VoteInfo.Setup.PassPercentage = GetNativeCell(2);
}

public int Native_PanoramaVote_Issue_set(Handle plugin, int params)
{
    VoteInfo.Setup.Issue = GetNativeCell(2);
}

public any Native_PanoramaVote_Initiator_get(Handle plugin, int params)
{
    if(!VoteManager.IsVoteInProgress)
    {
        return ThrowNativeError(SP_ERROR_NATIVE, "No vote is in progress.");
    }

    return VoteInfo.Setup.Initiator;
}

public any Native_PanoramaVote_Team_get(Handle plugin, int params)
{
    if(!VoteManager.IsVoteInProgress)
    {
        return ThrowNativeError(SP_ERROR_NATIVE, "No vote is in progress.");
    }

    return VoteInfo.Setup.Team;
}

public any Native_PanoramaVote_PassPercentage_get(Handle plugin, int params)
{
    if(!VoteManager.IsVoteInProgress)
    {
        return ThrowNativeError(SP_ERROR_NATIVE, "No vote is in progress.");
    }

    return VoteInfo.Setup.PassPercentage;
}

public any Native_PanoramaVote_Issue_get(Handle plugin, int params)
{
    if(!VoteManager.IsVoteInProgress)
    {
        return ThrowNativeError(SP_ERROR_NATIVE, "No vote is in progress.");
    }

    return VoteInfo.Setup.Issue;
}

public int Native_PanoramaVote_AddClient(Handle plugin, int params)
{
    VoteInfo.Setup.Clients[VoteInfo.Setup.ClientCount++] = GetNativeCell(2);
}