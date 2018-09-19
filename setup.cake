// This is intended as a baseline cake build template
// NOTE: This file will be overwritten on self update, so use project.cake instead
#load "nuget:https://nuget.powerfarming.co.nz/api/odata?package=Cake.Recipe.PF&version=0.3.1"
#load "nuget:https://nuget.powerfarming.co.nz/api/odata?package=Cake.Recipe.PFHelpers&version=0.4.0"

Environment.SetVariableNames();

#load "project.cake"

BuildParameters.PrintParameters(Context);
ToolSettings.SetToolSettings(context: Context);

//Build.RunVanilla();
RunTarget(BuildParameters.Target);
