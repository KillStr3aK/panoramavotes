#if defined _panoramavotes_included
 #endinput
#endif
#define _panoramavotes_included

#define SERVER_OPERATOR_ID 		0	 /**< Console vote initiator id */
#define DEFAULT_PASS_PERCENTAGE 50.0 /**< Vote pass percenage that will be setted if 'PanoramaVoteSetup::PassPercentage' isn't setted */
#define VOTE_DURATION_FOREVER 	0 	 /**< Vote should be broadcasted as long as possible */

#define MAX_VOTE_DETAILS_LENGTH 64
#define INVALID_ISSUE -1
#define MAX_VOTE_OPTIONS 5

#define VOTE_TEAMID_EVERYONE -1

#define PANORAMA_STRING_LENGTH 512

/**
 * Client's custom vote decisions.
 */
enum VoteDecision
{
	VOTE_DECISION_NONE = -1,
	VOTE_DECISION_YES,
	VOTE_DECISION_NO
}

/**
 * https://github.com/perilouswithadollarsign/cstrike15_src/blob/f82112a2388b841d72cb62ca48ab1846dfcc11c8/game/shared/shareddefs.h#L208-L216
 */
enum CastVote
{
	VOTE_OPTION1,  // Use this for Yes
	VOTE_OPTION2,  // Use this for No
	VOTE_OPTION3,
	VOTE_OPTION4,
	VOTE_OPTION5,
	VOTE_UNCAST
};

/**
 * Vote issue. These are mapped to translation strings and pass strings by VoteStart and VotePass
 * https://github.com/perilouswithadollarsign/cstrike15_src/blob/f82112a2388b841d72cb62ca48ab1846dfcc11c8/game/shared/shareddefs.h#L185-L206
 */
enum VoteIssue
{
	VOTE_ISSUE_UNDEFINED = 1, 
	VOTE_ISSUE_KICK, 
	VOTE_ISSUE_CHANGELEVEL, 
	VOTE_ISSUE_NEXTLEVEL, 
	VOTE_ISSUE_SWAPTEAMS, 
	VOTE_ISSUE_SCRAMBLE, 
	VOTE_ISSUE_RESTARTGAME, 
	VOTE_ISSUE_SURRENDER, 
	VOTE_ISSUE_REMATCH, 
	VOTE_ISSUE_CONTINUE, 
	VOTE_ISSUE_PAUSEMATCH, 
	VOTE_ISSUE_UNPAUSEMATCH, 
	VOTE_ISSUE_LOADBACKUP, 
	VOTE_ISSUE_ENDWARMUP, 
	VOTE_ISSUE_STARTTIMEOUT, 
	VOTE_ISSUE_ENDTIMEOUT, 
	VOTE_ISSUE_READYFORMATCH, 
	VOTE_ISSUE_NOTREADYFORMATCH, 
	
	// Represents the highest possible index of the enum
	VOTE_ISSUE_MAX
}

/**
 * Reasons a vote was failed.
 * https://github.com/perilouswithadollarsign/cstrike15_src/blob/f82112a2388b841d72cb62ca48ab1846dfcc11c8/game/shared/shareddefs.h#L142-L179
 */
enum VoteFailReason
{
	VOTE_FAILED_GENERIC = 0, 
	VOTE_FAILED_TRANSITIONING_PLAYERS, 
	VOTE_FAILED_RATE_EXCEEDED,  // "time" is used
	VOTE_FAILED_YES_MUST_EXCEED_NO, 
	VOTE_FAILED_QUORUM_FAILURE, 
	VOTE_FAILED_ISSUE_DISABLED, 
	VOTE_FAILED_MAP_NOT_FOUND, 
	VOTE_FAILED_MAP_NAME_REQUIRED, 
	VOTE_FAILED_FAILED_RECENTLY,  // "time" is used
	VOTE_FAILED_FAILED_RECENT_KICK,  // "time" is used
	VOTE_FAILED_FAILED_RECENT_CHANGEMAP,  // "time" is used
	VOTE_FAILED_FAILED_RECENT_SWAPTEAMS,  // "time" is used
	VOTE_FAILED_FAILED_RECENT_SCRAMBLETEAMS,  // "time" is used
	VOTE_FAILED_FAILED_RECENT_RESTART,  // "time" is used
	VOTE_FAILED_TEAM_CANT_CALL, 
	VOTE_FAILED_WAITINGFORPLAYERS, 
	VOTE_FAILED_PLAYERNOTFOUND,  // Deprecated, same as generic failure
	VOTE_FAILED_CANNOT_KICK_ADMIN, 
	VOTE_FAILED_SCRAMBLE_IN_PROGRESS, 
	VOTE_FAILED_SWAP_IN_PROGRESS, 
	VOTE_FAILED_SPECTATOR, 
	VOTE_FAILED_DISABLED, 
	VOTE_FAILED_NEXTLEVEL_SET, 
	VOTE_FAILED_REMATCH, 
	VOTE_FAILED_TOO_EARLY_SURRENDER, 
	VOTE_FAILED_CONTINUE, 
	VOTE_FAILED_MATCH_PAUSED, 
	VOTE_FAILED_MATCH_NOT_PAUSED, 
	VOTE_FAILED_NOT_IN_WARMUP, 
	VOTE_FAILED_NOT_10_PLAYERS, 
	VOTE_FAILED_TIMEOUT_ACTIVE, 
	VOTE_FAILED_TIMEOUT_INACTIVE,  // Deprecated, same as generic failure
	VOTE_FAILED_TIMEOUT_EXHAUSTED, 
	VOTE_FAILED_CANT_ROUND_END, 
	
	// Represents the highest possible index of the enum
	VOTE_FAILED_MAX
}

/**
 * Any of the following prototypes will work as a vote callback.
 */
typeset PanoramaVoteCallback
{
	/**
	 * Called when a vote result is available.
	 *
	 * @param results	    Array that contains the decisions of the voters.
	 */
	function void (int results[MAXPLAYERS + 1]);

	/**
	 * Called when a vote result is available.
	 *
	 * @param results	    Array that contains the decisions of the voters.
	 * @param data          Data passed to PanoramaVote.Execute() when vote was executed.
	 */
	function void (int results[MAXPLAYERS + 1], any data);
};

forward void PanoramaVotes_OnVoteReceive(int client, int &decision);

methodmap PanoramaVote __nullable__
{
	/**
	* Create a new Panorama Vote.
	*
	* @param initiator     Client index that initiated the vote.
	* @return              PanoramaVote 'instance'.
	*/
    public native PanoramaVote(int initiator = SERVER_OPERATOR_ID);

    // Custom vote initiator client index (who executed the vote), or SERVER_OPERATOR_ID for console. 
    property int Initiator
    {
        public native get();

        public native set(int value);
    }

    // Team id to broadcast the custom vote.
	// 
	// Note: This is ignored if 'Participants' list is specified.
	//
	// CS_TEAM_NONE (0)   	   To everyone
	// CS_TEAM_SPECTATOR (1)   To spectators only
	// CS_TEAM_T (2) 		   To terrorists only
	// CS_TEAM_CT (3)   	   To counter-terrorists only
    property int Team
    {
        public native get();

        public native set(int value);
    }

	// The required percenage of players who voted positively for the custom vote to pass.
	// Leaving the variable value as 0.0 will automatically set it to 'DEFAULT_PASS_PERCENTAGE'.
    property float PassPercentage
    {
        public native get();

        public native set(float value);
    }

	// Custom vote issue id to use.
    property VoteIssue Issue
    {
        public native get();

        public native set(VoteIssue value);
    }

	// Disposition string to display on the custom vote panel once the vote has executed. (HTML based text)
    public native void SetDisplayText(const char[] text);

	// Disposition string to display on the custom vote panel once the vote has passed. (HTML based text)
    public native void SetPassedText(const char[] text);

	// Optional data to parse through vote callbacks.
    public native void SetCallbackData(any data);

	// Execute vote.
    public native void Execute(int timeout = VOTE_DURATION_FOREVER, PanoramaVoteCallback PassedCallback = INVALID_FUNCTION, PanoramaVoteCallback FailedCallback = INVALID_FUNCTION);

	// Get the reason why the vote has failed.
    public static native VoteFailReason GetFailReason();

	// Cancel currently running vote.
	public static native void Cancel();
}

#if !defined REQUIRE_PLUGIN
public void __pl_customvotes_SetNTVOptional()
{
	MarkNativeAsOptional("PanoramaVote.PanoramaVote");
	MarkNativeAsOptional("PanoramaVote.Cancel");
	MarkNativeAsOptional("PanoramaVote.Execute");
	MarkNativeAsOptional("PanoramaVote.GetFailReason");

	MarkNativeAsOptional("PanoramaVote.SetDisplayText");
	MarkNativeAsOptional("PanoramaVote.SetPassedText");
	MarkNativeAsOptional("PanoramaVote.SetCallbackData");

	MarkNativeAsOptional("PanoramaVote.Initiator.get");
	MarkNativeAsOptional("PanoramaVote.Initiator.set");

	MarkNativeAsOptional("PanoramaVote.Team.get");
	MarkNativeAsOptional("PanoramaVote.Team.set");

	MarkNativeAsOptional("PanoramaVote.PassPercentage.get");
	MarkNativeAsOptional("PanoramaVote.PassPercentage.set");

	MarkNativeAsOptional("PanoramaVote.Issue.get");
	MarkNativeAsOptional("PanoramaVote.Issue.set");
}
#endif

public SharedPlugin __pl_panoramavotes = 
{
	name = "panoramavotes", 
	file = "panoramavotes.smx", 
#if defined REQUIRE_PLUGIN
    required = 1, 
#else
    required = 0, 
#endif
}; 