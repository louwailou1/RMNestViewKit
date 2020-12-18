#!/bin/bash

git stash
git pull origin master --tags
git stash pop

VersionString=`grep -E 's.version.*=' BKNestScrollview.podspec`
VersionNumber=`tr -cd 0-9 <<<"$VersionString"`

NewVersionNumber=$(($VersionNumber + 1))
LineNumber=`grep -nE 's.version.*=' BKNestScrollview.podspec | cut -d : -f1`
sed -i "" "${LineNumber}s/${VersionNumber}/${NewVersionNumber}/g" BKNestScrollview.podspec

echo "current version is ${VersionNumber}, new version is ${NewVersionNumber}"

git add .
git commit -am ${NewVersionNumber}
git tag ${NewVersionNumber}
git push origin master --tags
cd ~/.cocoapods/repos/bluajackPrivatePods && git pull origin master && cd - && pod repo push bluajackPrivatePods BKNestScrollview.podspec --verbose --allow-warnings

