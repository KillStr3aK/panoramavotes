#define VOTE_CONTROLLER_ENT "vote_controller"

bool g_bIsVoteInProgress;

methodmap VoteController __nullable__
{
	public VoteController()
	{
		int entity;
		if((entity = FindEntityByClassname(-1, VOTE_CONTROLLER_ENT)) < 0 && (entity = CreateEntityByName(VOTE_CONTROLLER_ENT)) == -1)
		{
			SetFailState("Unable to get or create entity %s", VOTE_CONTROLLER_ENT);
		}

		return view_as<VoteController>(entity);
	}

	property int Index
	{
		public get()
		{
			return view_as<int>(this);
		}
	}

	property int PotentialVotes
	{
		public get()
		{
			return GetEntProp(this.Index, Prop_Send, "m_nPotentialVotes");
		}

		public set(int value)
		{
			SetEntProp(this.Index, Prop_Send, "m_nPotentialVotes", value);
		}
	}

	property int OnlyTeamToVote
	{
		public get()
		{
			return GetEntProp(this.Index, Prop_Send, "m_iOnlyTeamToVote");
		}

		public set(int value)
		{
			SetEntProp(this.Index, Prop_Send, "m_iOnlyTeamToVote", value);
		}
	}

	property bool IsYesNoVote
	{
		public get()
		{
			return view_as<bool>(GetEntProp(this.Index, Prop_Send, "m_bIsYesNoVote"));
		}

		public set(bool value)
		{
			SetEntProp(this.Index, Prop_Send, "m_bIsYesNoVote", value);
		}
	}

	property bool IsVoteInProgress
	{
		public get()
		{
			return g_bIsVoteInProgress;
		}

		public set(bool value)
		{
			g_bIsVoteInProgress = value;
		}
	}

	property int YesCount
	{
		public get()
		{
			return GetEntProp(this.Index, Prop_Send, "m_nVoteOptionCount", _, 0);
		}

		public set(int value)
		{
			SetEntProp(this.Index, Prop_Send, "m_nVoteOptionCount", 0, _, value);
		}
	}

	property int NoCount
	{
		public get()
		{
			return GetEntProp(this.Index, Prop_Send, "m_nVoteOptionCount", _, 1);
		}

		public set(int value)
		{
			SetEntProp(this.Index, Prop_Send, "m_nVoteOptionCount", 1, _, value);
		}
	}

	public int GetOptionCount(CastVote option)
	{
		return GetEntProp(this.Index, Prop_Send, "m_nVoteOptionCount", _, view_as<int>(option));
	}

	public void SetOptionCount(CastVote option, int count)
	{
		SetEntProp(this.Index, Prop_Send, "m_nVoteOptionCount", count, _, view_as<int>(option));
	}
}