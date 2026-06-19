module options;

import std.conv : to;

import args : Arg, Optional;

static struct Options
{
	@Arg("winmd file to process", Optional.no) string meta;
	@Arg("output directory", Optional.no) string outDir;
}
