
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

	settings.Add("multi", true, "Combined Splitting");
	settings.SetToolTip("multi", "Several splits combined into one by specifying in the split name how many\ntheoretical splits (Mission Passes etc.) it takes to actually split");
	settings.CurrentDefaultParent = "multi";
	settings.Add("multiTotal", true, "Set total: [<number>]");
	settings.SetToolTip("multiTotal", "Add '[<number>]' anywhere, will cause other formats to be ignored for that split");
	settings.Add("multiMultiplication", true, "Multiplication: x<number>");
	settings.SetToolTip("multiMultiplication", "Add 'x<number>' anywhere (e.g. 'OBWAT? x3' = 3 or 'Mission Name (x4)' = 4)");
	settings.Add("multiPlus", true, "Addition: <part> + <part>");
	settings.SetToolTip("multiPlus", "Add anywhere between parts to add together (e.g. 'HTH x4 + Dupe' = 4+1 = 5 or 'Mission1 + Mission2' = 1+1 = 2)");
	settings.Add("multiNumber", true, "Number in front: <number> <split name>");
	settings.SetToolTip("multiNumber", "Add a number at the very beginning of a split name, possibly after Subsplits formatting (e.g. '2 Asset Takeovers' = 2)");
}

init
{
	Func<string, string, int> parseTargetNum = (text, regex) => {
		var m = System.Text.RegularExpressions.Regex.Match(text, regex);
		if (m.Success)
		{
			return int.Parse(m.Groups[1].Value);
		}
		return 0;
	};

	Func<string, int> GetTargetNum = (text) => {
		// Remove Subsplits Formatting
		text = System.Text.RegularExpressions.Regex.Replace(text, @"^(-|\{.*\})", "");
		if (settings["multiTotal"]) {
			var num = parseTargetNum(text, @"\[(\d+)\]");
			if (num > 0)
			{
				return num;
			}
		}
		var result = 0;
		var parts = settings["multiPlus"] ? text.Split('+') : new string[]{text};
		foreach (var part in parts)
		{
			var num = 0;
			if (settings["multiMultiplication"])
			{
				num += parseTargetNum(part, @"\bx(\d+)\b");
			}
			if (settings["multiNumber"])
			{
				num += parseTargetNum(part, @"^\s*(\d+)\b");
			}
			if (num > 0)
			{
				result += num;
			}
			else
			{
				result++;
			}
		}
		return result;
	};
	vars.GetTargetNum = GetTargetNum;
}

update
{
	vars.missionPassed = features["ap"].min(30) > 94 || features["mp1"].min(30) > 94 || features["mp2"].min(30) > 94;
	vars.loadingGame = features["vcs"].min(30) > 94;

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
		if (!timer.CurrentTime.RealTime.HasValue || timer.CurrentTime.RealTime.Value.TotalSeconds < 10)
		{
			// May split right after starting the timer otherwise, since the title screen may be there
			return false;
		}
		vars.lastSplit = Environment.TickCount;
		var splitName = timer.CurrentSplit.Name;
		var splitIndex = timer.CurrentSplitIndex;
		var info = "[Start: "+vars.loadingGame+" Pass: "+vars.missionPassed+"]";
		var targetNum = vars.GetTargetNum(splitName);
		if (targetNum > 1)
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
