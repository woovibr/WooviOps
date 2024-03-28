#!/usr/bin/env bash
set -x #echo on

helm install argocd ./deployments/argocd --namespace argocd
