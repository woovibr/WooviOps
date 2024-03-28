#!/usr/bin/env bash
set -x #echo on

kubectl port-forward -n argocd svc/argocd-server 8080:443
