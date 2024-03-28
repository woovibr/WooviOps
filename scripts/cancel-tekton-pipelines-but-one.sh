#!/bin/bash
echo "make sure you have tekton cli installed..."

if [ "$#" -ne 1 ]; then
    echo "Missing variable"
    echo "Usage: sh $0 <namespace>"
    echo "Ex: sh $0 tekton-woovi-server"
    exit 1
fi


namespace="$1"


output=$(tkn pr list -n $namespace)


first=$(echo "$output" | awk 'NR == 3 { print $1 }')


names=$(echo "$output" | awk 'NR > 2 { print $1 }')

for name in $names; do
    status=$(echo "$output" | awk -v name="$name" '$1 == name {print $NF}')

    if [ "$name" != "$first" ] && [ "$status" == "Running" ]; then
        echo "Deleting $name..."
        tkn pr cancel $name -n $namespace --grace CancelledRunFinally
    fi
done
