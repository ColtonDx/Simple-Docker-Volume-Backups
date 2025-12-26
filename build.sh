#!/bin/bash

####
# CONFIGURATION
####
BACKUP_DIRECTORY="/mnt/Backups"
DATE=$(date +%Y-%m-%d)

####
# DISCOVER STACKS
####

# Find all containers with an SDVB label and extract unique label values
SDVB_STACK=($(docker ps --filter "label=SDVB" --format '{{.ID}}' | xargs -n1 docker inspect --format '{{range $k,$v := .Config.Labels}}{{if eq $k "SDVB"}}SDVB={{$v}}{{end}}{{end}}' | sort -u))

####
# BACKUP LOOP
####

for STACK_NAME in "${SDVB_STACK[@]}"; do
    CLEANED_STACK_NAME="${STACK_NAME#SDVB=}"
    TAR_FILE="${BACKUP_DIRECTORY}/${CLEANED_STACK_NAME}_Backup_${DATE}.tar"

    # Get containers with this label
    CONTAINERS=($(docker ps -q --filter "label=${STACK_NAME}"))

    if [ ${#CONTAINERS[@]} -eq 0 ]; then
        echo "No containers found for stack: $STACK_NAME"
        continue
    fi

    echo "Stopping containers for stack: $STACK_NAME"
    docker stop "${CONTAINERS[@]}"

    VOLUMES=()
    for CONTAINER in "${CONTAINERS[@]}"; do
        # Get only named volumes (exclude bind mounts)
        VOLUME_NAMES=$(docker inspect --format='{{range .Mounts}}{{if eq .Type "volume"}}{{.Name}} {{end}}{{end}}' "$CONTAINER")

        for VOLUME_NAME in $VOLUME_NAMES; do
            VOLUME_PATH=$(docker volume inspect --format '{{.Mountpoint}}' "$VOLUME_NAME")

            # Exclude docker.sock or anything suspicious
            if [[ "$VOLUME_PATH" != *"docker.sock"* ]]; then
                VOLUMES+=("$VOLUME_PATH")
            fi
        done
    done

    # Remove duplicates
    VOLUMES=($(echo "${VOLUMES[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

    echo "Creating backup: $TAR_FILE"
    tar -cvf "$TAR_FILE" "${VOLUMES[@]}"

    echo "Restarting containers for stack: $STACK_NAME"
    docker start "${CONTAINERS[@]}"

    echo "Backup for stack '$STACK_NAME' completed!"
    echo "--------------------------------------------"
done
