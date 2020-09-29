init
{
    vars.lastSplit = 0;
}

update
{
    vars.split = features["pixel"].min(30) > 96 && features["square"].min(30) > 92 && features["stuff"].min(30) > 92;
}

start
{
}

reset
{
}

split
{
	if (vars.split && Environment.TickCount - vars.lastSplit > 60*1000)
	{
		vars.lastSplit = Environment.TickCount;
		return true;
	}
}

isLoading
{
}
