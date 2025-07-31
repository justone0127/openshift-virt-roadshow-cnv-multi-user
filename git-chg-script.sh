#!/bin/bash

OLD_GIT_URL="https://github.com/rhpds/openshift-virt-roadshow-cnv-multi-user"
NEW_GIT_URL="https://github.com/justone0127/openshift-virt-roadshow-cnv-multi-user.git"
DEPLOYMENT_NAME="showroom"
CONTAINER_NAME="content"

for i in {1..20}; do
  PROJECT="showroom-user${i}"
  echo "🔄 Processing project: $PROJECT"

  # 프로젝트 변경
  oc project $PROJECT >/dev/null 2>&1

  # 현재 값 확인
  CURRENT_URL=$(oc get deployment/$DEPLOYMENT_NAME \
    -o=jsonpath="{.spec.template.spec.containers[?(@.name=='$CONTAINER_NAME')].env[?(@.name=='GIT_REPO_URL')].value}")

  echo "Current URL: $CURRENT_URL"

  if [[ "$CURRENT_URL" == "$OLD_GIT_URL" ]]; then
    echo "⏹️ Scaling down deployment..."
    oc scale deployment/$DEPLOYMENT_NAME --replicas=0

    echo "✏️ Updating GIT_REPO_URL to $NEW_GIT_URL..."
    oc set env deployment/$DEPLOYMENT_NAME \
      --containers=$CONTAINER_NAME \
      GIT_REPO_URL=$NEW_GIT_URL

    echo "▶️ Scaling up deployment..."
    oc scale deployment/$DEPLOYMENT_NAME --replicas=1

    echo "✅ Updated successfully for $PROJECT"
  else
    echo "⚠️ Skipped: URL already updated or different."
  fi

  echo "-----------------------------------------"
done
