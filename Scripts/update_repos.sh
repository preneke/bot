#!/bin/bash
CUR=`pwd`
allrepos="bot cfast cor exp fds out radcal smv"
otherrepos="webpages wikis"
BRANCH=master
PUSH=

function usage {
echo "Update the repos $allrepos if they exist"
echo ""
echo "Options:"
echo "-h - display this message"
echo "-p - push updates to remote origin"
exit
}

FMROOT=
if [ -e ../.gitbot ]; then
   cd ../..
   FMROOT=`pwd`
else
   echo "***error: the update_repos.sh script must be run from"
   echo "          the bot/Scripts directory"
   exit
fi

while getopts 'hp' OPTION
do
case $OPTION  in
  h)
   usage;
   ;;
  p)
   PUSH="1";
   ;;
esac
done
shift $(($OPTIND-1))

echo "You are about update repos in the directory $FMROOT."
echo ""
echo "Press any key to continue or <CTRL> c to abort."
read val

UPDATE_REPO ()
{
  local repo=$1
  repodir=$FMROOT/$repo

  echo "------------- $repo -------------------------------------------"
  if [ ! -e $repodir ]; then
     echo "Skipping, $repo does not exist"
     return
  fi
  cd $repodir
  CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
  if [ "$BRANCH" != "$CURRENT_BRANCH" ]; then
    echo "Skipping, found branch $CURRENT_BRANCH, expecting branch $BRANCH"
    return
  fi
  echo ""
  echo "***  updating from origin"
  echo "     branch: $BRANCH"
  echo "     dir: $repodir"

  git fetch origin
  git merge origin/$BRANCH
  have_central=`git remote -v | awk '{print $1}' | grep firemodels | wc  -l`
  if [ "$have_central" -gt "0" ]; then
     echo ""
     echo "*** updating from firemodels"
     echo "    branch: $BRANCH"
     echo "    dir: $repodir"
     git fetch firemodels
     git merge firemodels/$BRANCH
     if [ "$PUSH" == "1" ]; then
        ahead=`git status -uno | grep ahead | wc -l`
        if [ "$ahead" -gt "0" ]; then
            echo "pushing changes in $repo to origin"
            git push origin $BRANCH
        fi
     fi
  fi
  if [[ "$repo" == "exp" ]]; then
     echo "Fetching origin."
     git submodule foreach git fetch origin
     echo "Updating origin submodules."
     git submodule foreach git merge origin/master
  fi
}

UPDATE_REPO2 ()
{
  local repo=$1
  repodir=$FMROOT/$repo

  if [ ! -e $repodir ]; then
     return
  fi
  echo "------------- $repo -------------------------------------------"
  cd $repodir
  BRANCH=`git rev-parse --abbrev-ref HEAD`
  echo ""
  echo "***  updating from firemodels"
  echo "     branch: $BRANCH"
  echo "     dir: $repodir"
  echo ""
  git fetch origin
  git merge origin/$BRANCH
  git status -uno
}

for repo in $allrepos
do 
  echo
  UPDATE_REPO $repo
done

for repo in $otherrepos
do 
  echo
  UPDATE_REPO2 $repo
done

cd $CURDIR
