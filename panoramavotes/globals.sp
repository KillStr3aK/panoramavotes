UserMsg VoteStartMsg;
UserMsg VotePassMsg;
UserMsg VoteFailMsg;

VoteController VoteManager;
VoteInformation VoteInfo;

GlobalForward OnClientVoteReceived;

VoteDecision ClientDecision[MAXPLAYERS + 1] = { VOTE_DECISION_NONE, ... };