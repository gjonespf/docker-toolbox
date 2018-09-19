// Load your project specific stuff here

//#load "nuget:https://nuget.powerfarming.co.nz/api/odata?package=PowerFarming.PowerShell.BuildTools&version=0.2.2"
#addin "nuget:?package=Cake.Powershell&version=0.4.5"

BuildParameters.SetParameters(context: Context,
                            buildSystem: BuildSystem,
                            sourceDirectoryPath: "./src",
                            title: "PowerFarming.DockerToolbox",
                            repositoryOwner: "gjones@powerfarming.co.nz",
                            repositoryName: "PowerFarming.DockerToolbox",
                            shouldPostToMicrosoftTeams: true,
                            shouldRunGitVersion: true
                            );

//BuildParameters.Paths.Directories.NugetNuspecDirectory = BuildParameters.SourceDirectoryPath;

Task("Init")
    .IsDependentOn("PFInit")
    .IsDependentOn("Generate-Version-File-PF")
	.Does(() => {
		Information("Init");
    });

BuildParameters.Tasks.CleanTask
    .IsDependentOn("Generate-Version-File-PF")
    .Does(() => {
    });
BuildParameters.Tasks.RestoreTask
	//.IsDependentOn("Package-Docker")
    .Does(() => {
    });

BuildParameters.Tasks.PackageTask
	.IsDependentOn("Package-Docker");

BuildParameters.Tasks.BuildTask
	.IsDependentOn("Build-Docker");

Task("Publish")
	.IsDependentOn("Publish-Artifacts")
	.IsDependentOn("Publish-PFDocker")
	.Does(() => {
	});
    
Teardown(context =>
{
    // Executed AFTER the last task.
});

Task("PSSign")
    .Does(() =>
{
    StartPowershellFile("./Scripts/SignAll.ps1", args =>
        {
            args.Append("Path", BuildParameters.SolutionFilePath);
        });
});

Task("BuildPackage")
    .IsDependentOn("Build")
    .IsDependentOn("PSSign")
    .IsDependentOn("Package")
    .Does(() =>
{
    //Verbose("ProjClean");
});

Task("BuildPackagePublish")
    .IsDependentOn("Build")
    .IsDependentOn("Package")
    .IsDependentOn("Publish")
    .Does(() =>
{
    //Verbose("ProjClean");
});
