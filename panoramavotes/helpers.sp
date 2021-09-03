void UpdatePotentialVotes()
{
    if (!VoteManager.IsVoteInProgress)
		return;

    if(VoteInfo.Setup.ClientCount == 0)
    {
        if(VoteInfo.Setup.Team == VOTE_TEAMID_EVERYONE)
        {
            VoteManager.PotentialVotes = GetClientCount();
        } else {
            VoteManager.PotentialVotes = GetTeamClientCount(VoteInfo.Setup.Team);
        }
    } else {
        VoteManager.PotentialVotes = VoteInfo.Setup.ClientCount;
    }
}

bool PrecacheImage(const char[] text, Timer callback)
{
	char url[PLATFORM_MAX_PATH];
	GetImageFromText(text, url, sizeof(url));
	
	if (IsNullString(url))
		return false;
	
	Event event = CreateEvent("show_survival_respawn_status");
	
	if (event)
	{
		Format(url, sizeof(url), "<font class='fontSize-l'>Loading UI Image...</font>\n%s", url);
		
		event.SetString("loc_token", url);
		event.SetInt("duration", 0);
		event.SetInt("userid", -1);
		
        int clients[MAXPLAYERS];
		int client_count;
		GetVoteBroadcastClients(clients, client_count);
		
		for (int current_client; current_client < client_count; current_client++)
		{
			event.FireToClient(clients[current_client]);
		}
		
		event.Cancel();
	}
	
	CreateTimer(1.0, callback);
	return true;
}

void GetImageFromText(const char[] text, char[] buffer, int length)
{
	static Regex rgx;
	
	if (!rgx)
	{
		rgx = new Regex("<img .*src=(?:\\'|\\\").+(?:\\'|\\\").*\\/?>");
	}
	
	rgx.Match(text);
	
	if (rgx.MatchCount())
	{
		rgx.GetSubString(0, buffer, length);
	}
}

void GetVoteBroadcastClients(int clients[MAXPLAYERS], int &client_count)
{
	if (VoteInfo.Setup.ClientCount)
	{
		// Verify the clients array.
		for (int current_client; current_client < VoteInfo.Setup.ClientCount; current_client++)
		{
			if (!IsClientInGame(VoteInfo.Setup.Clients[current_client]))
			{
				VoteInfo.Setup.Clients[VoteInfo.Setup.ClientCount--] = 0;
			}
		}
		
		clients = VoteInfo.Setup.Clients;
		client_count = VoteInfo.Setup.ClientCount;
	}
	else
	{
		for (int current_client = 1; current_client <= MaxClients; current_client++)
		{
			if (IsClientInGame(current_client) && !IsFakeClient(current_client) && (VoteInfo.Setup.Team == VOTE_TEAMID_EVERYONE || VoteInfo.Setup.Team == GetClientTeam(current_client)))
			{
				clients[client_count++] = current_client;
			}
		}
	}
}