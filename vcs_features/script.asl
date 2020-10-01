
startup
{
	vars.PrevPhase = null;
	vars.lastSplit = 0;
	vars.passedCount = new Dictionary<int, int>();
	vars.missionPassed = true;
	vars.loadingGame = true;

	Action<string> DebugOutput = (text) => {
		print("[GTAVCS Autosplitter] "+text);
	};
	vars.DebugOutput = DebugOutput;

	Func<string, string, int> parseTargetNum = (text, regex) => {
		var m = System.Text.RegularExpressions.Regex.Match(text, regex);
		if (m.Success)
		{
			return int.Parse(m.Groups[1].Value);
		}
		return 0;
	};

	Func<string, int> GetTargetNum = (text) => {
		// TODO: Add settings
		if (true) {
			var num = parseTargetNum(text, @"\bx(\d)\b");
			if (num > 0)
			{
				return num;
			}
		}
		if (true) {
			var num = parseTargetNum(text, @"\[(\d)\]");
			if (num > 0)
			{
				return num;
			}
		}
		return 0;
	};
	vars.GetTargetNum = GetTargetNum;
}

init
{
}

update
{
	vars.missionPassed = features["ap"].min(30) > 94 || features["mp1"].min(30) > 94 || features["mp2"].min(30) > 94;
	vars.loadingGame = features["bar"].min(30) > 94 && features["text"].min(30) > 94 && features["text"].old(100) < 94;
	vars.test = features["p1"].min(80);

	if (timer.CurrentPhase != vars.PrevPhase)
	{
		if (timer.CurrentPhase == TimerPhase.NotRunning)
		{
			vars.passedCount.Clear();
			vars.DebugOutput("Cleared mission pass counts");
		}
		vars.PrevPhase = timer.CurrentPhase;
	}
}

start
{
}

reset
{
}

split
{
	if ((vars.loadingGame || vars.missionPassed) && Environment.TickCount - vars.lastSplit > 10*1000)
	{
		vars.lastSplit = Environment.TickCount;
		var splitName = timer.CurrentSplit.Name;
		var splitIndex = timer.CurrentSplitIndex;
		var info = "[Start: "+vars.loadingGame+" Pass: "+vars.missionPassed+"]";
		var targetNum = vars.GetTargetNum(splitName);
		if (targetNum > 0)
		{
			if (!vars.passedCount.ContainsKey(splitIndex))
			{
				vars.passedCount.Add(splitIndex, 0);
			}
			vars.passedCount[splitIndex]++;
			var currentNum = vars.passedCount[splitIndex];
			vars.DebugOutput("Split '"+splitName+"' at "+currentNum+"/"+targetNum+" "+info);
			if (vars.passedCount[splitIndex] == targetNum)
			{
				return true;
			}
		}
		else {
			vars.DebugOutput("Split '"+splitName+"' "+info);
			return true;
		}
	}
}

isLoading
{
}
