GPG_AGENT_PID=$(pidof gpg-agent)
if [ -n "$GPG_AGENT_ID" ]; then
    echo "Starting gpg-agent..."
    gpg-connect-agent /bye
fi
