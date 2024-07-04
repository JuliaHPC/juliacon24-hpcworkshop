# Request an entire CPU node for interactive usage (you'll end up with a shell on the compute node)
# Run as: sh cpunode.sh
salloc --nodes 1 --qos interactive --time 01:00:00 --constraint cpu --account=ntrain1
