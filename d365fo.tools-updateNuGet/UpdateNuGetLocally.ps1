#Get the NuGet packages currently present in the Azure DevOps Artifact feed
$currentFeedNuGetPackages = Get-D365AzureDevOpsNuget -Uri "https://dev.azure.com/DevOps/D365/" -FeedName "D365Update" -PeronalAccessToken "Your PAT" -Latest
#iterate through the packages in the artifact feed
foreach ($NuGetPackage in $currentFeedNuGetPackages) 
{
    #find the NuGet package in LCS with the name from the package in the artifact feed
    $lcsNuGetPackages = Get-D365LcsAssetFile -FileType NuGetPackage -AssetFilename "$($NuGetPackage.Name)*" 
    $PackageVersion = $NuGetPackage.Version
    foreach ($NuGetPackageLCS in $lcsNuGetPackages) 
    {  
        $fileName = $NuGetPackageLCS.FileName 
        #get the filename from the LCS NuGet package        
        if ($fileName -Match "\d+.\d+.\d+.\d+") 
        { 
            #check for the package with the highest version and set it as the package to download
            if ($([Version]$Matches[0]) -gt [Version]$PackageVersion) 
            {                 
                $NuGetPackageToDownload = $NuGetPackageLCS
                $PackageVersion = $([Version]$Matches[0])
            } 
        }  
    } 
    $fileName = $NuGetPackageToDownload.FileName 
    #download the newest LCS package
    $NuGetPackageToDownload |  Invoke-D365AzCopyTransfer -DestinationUri "C:\Temp\d365fo.tools\nuget\$FileName"     
    #push the LCS package into the artifact feed
    Invoke-D365AzureDevOpsNugetPush -Path $fileName -source "Your NuGet Source" -ShowOriginalProgress  
}