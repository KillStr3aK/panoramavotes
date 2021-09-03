enum struct PanoramaVoteSetup
{
    // Custom vote initiator client index (who executed the vote), or SERVER_OPERATOR_ID for console. 
    int Initiator;

    // Team id to broadcast the custom vote.
	// 
	// Note: This is ignored if 'Participants' list is specified.
	//
	// CS_TEAM_NONE (0)   	   To everyone
	// CS_TEAM_SPECTATOR (1)   To spectators only
	// CS_TEAM_T (2) 		   To terrorists only
	// CS_TEAM_CT (3)   	   To counter-terrorists only
    int Team;

    // Vote participants.
    int Clients[MAXPLAYERS];

    // Number of players in the array.
	int ClientCount;

    // Custom vote issue id to use.
    VoteIssue Issue;

    // The required percenage of players who voted positively for the custom vote to pass.
	// Leaving the variable value as 0.0 will automatically set it to 'DEFAULT_PASS_PERCENTAGE'.
    float PassPercentage;

    // Disposition string to display on the custom vote panel once the vote has executed. (HTML based text)
    char DisplayString[PANORAMA_STRING_LENGTH];

    // Disposition string to display on the custom vote panel once the vote has passed. (HTML based text)
    char PassedString[PANORAMA_STRING_LENGTH];

    // Optional data to parse through vote callbacks.
    any Data;

    // Resets back everything to default values.
    void Reset()
    {
        this.Team = VOTE_TEAMID_EVERYONE;

        this.Issue = VOTE_ISSUE_UNDEFINED;

        this.PassPercentage = 0.0;

        this.DisplayString = NULL_STRING;
        this.PassedString = NULL_STRING;

        this.Data = 0;
    }
}

enum struct VoteInformation
{
    // Source plugin handle.
    Handle Plugin;

    // Result callbacks.
    PanoramaVoteCallback PassedCallback;
    PanoramaVoteCallback FailedCallback;

    PanoramaVoteSetup Setup;

    // Timeout handler
    Handle Timeout;

    // Resets back everything to default values.
    void Reset()
    {
        this.Plugin = null;

        this.PassedCallback = INVALID_FUNCTION;
        this.FailedCallback = INVALID_FUNCTION;

        this.Setup.Reset();

        delete this.Timeout;
    }
}