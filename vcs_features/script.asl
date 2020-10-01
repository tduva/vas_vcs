
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
}

init
{
}

update
{
	vars.missionPassed = features["p1"].min(80) > 96 && features["p2"].min(80) > 92 && features["p3"].min(80) > 96;
	vars.loadingGame = features["bar"].min(30) > 94 && features["text"].min(30) > 94 && features["text"].old(100) < 94;
	vars.test = features["p1"].min(80);

	if (timer.CurrentPhase != vars.PrevPhase)
	{
		if (timer.CurrentPhase == TimerPhase.NotRunning)
		{
			vars.passedCount.Clear();
			vars.DebugOutput("Cleared list of passed missions");
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
		var m = System.Text.RegularExpressions.Regex.Match(splitName, @"\bx(\d)\b");
		if (m.Success)
		{
			var targetNum = int.Parse(m.Groups[1].Value);
			if (!vars.passedCount.ContainsKey(splitIndex))
			{
				vars.passedCount.Add(splitIndex, 0);
			}
			vars.passedCount[splitIndex]++;
			var currentNum = vars.passedCount[splitIndex];
			vars.DebugOutput("Split '"+splitName+"' at "+currentNum+"/"+targetNum);
			if (vars.passedCount[splitIndex] == targetNum)
			{
				return true;
			}
		}
		else {
			vars.DebugOutput("Split '"+splitName+"'");
			return true;
		}
	}
}

isLoading
{
}
