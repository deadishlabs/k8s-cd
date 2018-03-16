#!/bin/bash
# Check GitHub for newest version, update deployment
#
# Maintainer: https://github.com/deadishlabs

alias kubez='kubectl --kubeconfig=/etc/kube/kubeconfig'
HOMEDIR=`pwd`

# STEP 1 - get all replication controllers, loop through them
for name in $(kubez get deployments | grep -v NAME | grep -v nginx | grep -v nats | awk '{ print $1 }');
do
 
 # STEP 2 - get newest version from GH
 cd $HOMEDIR
 mkdir $name
 cd $name

 git init --quiet
 
 #MAKE .GIT/CONFIG
 
 rm -f .git/config
 echo [remote \"$name\"] > .git/config
 echo url = https://$GH_USER:$GH_TOKEN@$GITHUB2/$name.git >> .git/config
 git fetch --tags --quiet $name

 NEW_VERSION=$(git describe --tags `git rev-list --tags --max-count=1`)

 cd $HOMEDIR
 rm -rf $name
 
 # STEP 3 - get current version
 
 OLD_VERSION=$(kubez describe deployment $name | grep Image | awk '{ print $2 }' | awk -F ':' '{ print $2 }')
 
 # STEP 4 - update deployment if new version exists
 echo
 echo $name :
 echo Newest version: $NEW_VERSION
 echo Current version: $OLD_VERSION
 
 if [ "$NEW_VERSION" != "$OLD_VERSION" ] ; then
  echo New version detected.
  echo Running: kubez set image deployment/$name $name=$REGISTRY/$name:$NEW_VERSION
  kubez set image deployment/$name $name=$REGISTRY/$name:$NEW_VERSION
  echo
 else
  echo
  echo No new version detected.
 fi
  
done
