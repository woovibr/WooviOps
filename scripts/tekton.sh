#!/usr/bin/env bash

set echo off

lb='%s\n' 
olm=$'Installing, Operator Lifecycle Manager'; printf "$lb" "$olm" 
NAMESPACE="tekton-pipelines"
OPERATORNAMESPACE="operators"
WAIT_TIME=2
MAX_WAIT_TIME=10

printf ''
## operator lifecycle manager
curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.26.0/install.sh | bash -s v0.26.0
sleep 5

op=$'Installing, Tekton Operator'; printf "$lb" "$op" 

## tekton operator
kubectl create -f https://operatorhub.io/install/tektoncd-operator.yaml

test=$'Getting operator status...'; printf "$lb" "$test" 

sleep 5
## see if it is running
kubectl get csv -n operators



# Check if the namespace exists
if kubectl get namespace "$NAMESPACE" &> /dev/null; then
    echo "Namespace $NAMESPACE exists."
    
    # Check if the namespace is active
    STATUS=$(kubectl get namespace "$NAMESPACE" -o jsonpath='{.status.phase}')
    if [ "$STATUS" = "Active" ]; then
        echo "Namespace $NAMESPACE is active."
    else
        echo "Namespace $NAMESPACE exists but is not active. Waiting for it to become active..."
        
        # Loop to check the status every 2 seconds, up to a maximum of 10 seconds
        for (( i=0; i<MAX_WAIT_TIME; i+=WAIT_TIME )); do
            sleep $WAIT_TIME
            STATUS=$(kubectl get namespace "$NAMESPACE" -o jsonpath='{.status.phase}')
            if [ "$STATUS" = "Active" ]; then
                echo "Namespace $NAMESPACE is now active."
                exit 0
            fi
        done
        
        # If the namespace is still not active after 10 seconds, exit with an error
        echo "Namespace $NAMESPACE is still not active after $MAX_WAIT_TIME seconds. Exiting with an error."
        exit 1
    fi
else
    echo "Namespace $NAMESPACE does not exist. Creating..."
    kubectl create namespace "$NAMESPACE"
    echo "Namespace $NAMESPACE created."
fi

sleep 5
# apply tekton config before installing core charts
kubectl apply -f ./deployments/tekton/TektonConfig.yaml -n tekton-pipelines

sleep 5

## all cdrs
kubectl apply -f https://raw.githubusercontent.com/tektoncd/operator/main/config/crs/kubernetes/config/all/operator_v1alpha1_config_cr.yaml

# helm install tekton ./deployments/tekton --namespace tekton-pipelines
