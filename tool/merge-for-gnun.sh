#! /bin/bash

LANG=C

# error: Your local changes to the following files would be overwritten by merge:
# error: The following untracked working tree files would be overwritten by merge:

STATE=0
LOCAL_FILES=""
NEW_FILES=""

git merge origin/master -s recursive -X theirs 2>&1 | while read; do
  if [ $STATE -eq 0 ]; then
    if [ "${REPLY}" = "Already up-to-date." ]; then
      STATE=99
      echo $REPLY
    elif [ "${REPLY}" = "Fast-forward" ]; then
      STATE=99
      echo $REPLY
    elif [ "${REPLY}" = "Aborting" ]; then
      echo "checkout original..."
      echo $LOCAL_FILES
      git checkout $LOCAL_FILES

      echo "Removing ..."
      echo "$NEW_FILES"
      rm -f $NEW_FILES

      git merge origin/master -s recursive -X theirs
      exit 0
    elif [ "${REPLY:0:25}" = "error: Your local changes" ]; then
      STATE=1
    elif [ "${REPLY:0:25}" = "error: The following untr" ]; then
      STATE=2
    else
      echo $REPLY
    fi
  elif [ $STATE -eq 1 ]; then
    if [ "${REPLY:0:6}" = "Please" ]; then
      STATE=0
    else
      LOCAL_FILES="$LOCAL_FILES $REPLY";
    fi
  elif [ $STATE -eq 2 ]; then
    if [ "${REPLY:0:6}" = "Please" ]; then
      STATE=0
    else
      NEW_FILES="$NEW_FILES $REPLY";
    fi
  elif [ $STATE -eq 99 ]; then
    echo $REPLY
  fi
done
