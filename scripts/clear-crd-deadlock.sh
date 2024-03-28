#!/usr/bin/env bash

set echo off

#sometimes when dealing with operators, some crds get orphanaged if you delete 
#resources in the wrong order or don't respect the time it takes to delete upper scope resources, 
# its a pain in the ass, this is how you remove them manually. 
#values is a list of cdr names
# always use a lifecicle manager for that 
VALUES=()

for var in "${VALUES[@]}"
do
    echo "Processing $var"
    # Apply kubectl patch command to each value
    kubectl patch crd/${var} -p '{"metadata":{"finalizers":[]}}' --type=merge
done

for var in "${VALUES[@]}"
do
    echo "Processing $var"
    # Apply kubectl patch command to each value
    kubectl delete crd ${var} 
done