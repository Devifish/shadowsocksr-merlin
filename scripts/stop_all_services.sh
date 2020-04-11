#!/bin/ash

# Kill all services
killall ssr-redir 2>/dev/null
killall unbound 2>/dev/null

echo "All service stopped."
