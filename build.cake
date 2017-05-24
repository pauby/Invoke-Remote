#tool "nuget:?package=GitVersion.CommandLine"

var p_target = Argument("target", "Default");
var p_pkgdir = Argument("pkgdir", "_buildArtifacts");
var p_ApiKey = Argument("ApiKey", "");
var p_SourceUrl = Argument("SourceURL", "");

/*
Information("target is " + p_target);
Information("pkgdir is " + p_pkgdir);
Information("ApiKey is " + p_ApiKey);
Information("SourceURL is " + p_SourceUrl);
*/

Task("Default")
  .IsDependentOn("Build")
  .Does(() =>
{
});


Task("Clean")
  .Does(() =>
{
  CleanDirectories(new string[] { p_pkgdir });
});


Task("Build")
  .IsDependentOn("Clean")
  .Does(() =>
{
  Information("retrieving version and building Chocolatey package");

  var gitversion = GitVersion().AssemblySemVer;
  Information("version is " + gitversion);

  EnsureDirectoryExists(p_pkgdir);

  ChocolateyPack("./nuget/invoke-remote.nuspec", new ChocolateyPackSettings {
    Version = gitversion,
    OutputDirectory = p_pkgdir
  });
});


Task("Publish")
  .IsDependentOn("Build")
  .Does(() =>
{  
  var nupkgFiles = GetFiles(p_pkgdir + "/**/*.nupkg");
  foreach(var nupkgFile in nupkgFiles)
  {
      ChocolateyPush(nupkgFile, new ChocolateyPushSettings {
        ApiKey = p_ApiKey,
        Source = p_SourceUrl
      });
  }
});


RunTarget(p_target);
