#!/bin/ash
until /root/cozy-emails/bin/emails; do
	echo "Cozy-emails crashed with exit code $?. Respawning.."
	sleep 1
done


