# Request an entire GPU node for interactive usage (you'll end up with a shell on the compute node)
# Run as: sh gpunode.sh
salloc --nodes 1 --qos interactive --time 01:00:00 --constraint gpu --gpus 4 --account=ntrain1
