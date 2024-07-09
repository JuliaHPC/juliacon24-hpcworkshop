using CpuId, MPI, CUDA, Hwloc, AbstractTrees

import AbstractTrees: PreOrderDFS
import Hwloc: hwloc_pci_class_string

import Base: filter, Fix1
filter(f::Function)::Function = Fix1(filter, f)

const cpucycle_mask = (
    (1 << (64 - leading_zeros(CpuId.cputhreads()))) - 1
) % UInt32

cpucycle_coreid() = Int(cpucycle_id()[2] & cpucycle_mask)

function get_device_attributes()
    attr = Dict{Tuple{Int32, Int32}, Int32}()
    for i in 0:(ndevices()-1)
        d = CuDevice(i)
        attr[(
            attribute(d, CUDA.CU_DEVICE_ATTRIBUTE_PCI_BUS_ID),
            attribute(d, CUDA.CU_DEVICE_ATTRIBUTE_PCI_DEVICE_ID)
        )] = d
    end
    attr
end

function tag_subtree!(tree_node, val)
    for n in collect(AbstractTrees.PreOrderDFS(tree_node))
        n.tag = val
    end
end

function distance_to_core!(node, target_index)
    # shield re-entrance when iterating
    node.tag = 1

    if node.type == :PU
        # println("Checking: $(nodevalue(node).os_index)")
        if nodevalue(node).os_index == target_index
            return true, 0
        end
    end

    for child in node.children
        if child.tag == 1
            continue
        end

        found, dist = distance_to_core!(child, target_index)
        if found
            return true, dist + 1
        end
    end

    if node.parent != nothing
        found, dist = distance_to_core!(node.parent, target_index)
        if found
            return true, dist + 1
        end
    end

    return false, typemax(Int)
end

function distance_to_core(root, node, target_index)
    tag_subtree!(root, 0) 
    found, dist = distance_to_core!(node, target_index)
    tag_subtree!(root, 0) 
    return found, dist
end
    
sys_devs = children(gettopology())
pci_devs = PreOrderDFS(sys_devs) |> collect |> filter(x->x.type==:PCI_Device)
gpu_devs = pci_devs |> filter(x->hwloc_pci_class_string(nodevalue(x).attr.class_id) == "3D")

function get_device_distances(core)
    attr = get_device_attributes()
    dist = Dict{Int32, Int32}()
    dev  = Dict{Int32, Int32}()
    for d in gpu_devs
        idx = attr[(nodevalue(d).attr.bus, nodevalue(d).attr.dev)]
        found, dev_d = distance_to_core(sys_devs, d, core)
        if found
            dist[idx] = dev_d
            dev[dev_d] = idx
        end
    end
    dist, dev
end
    
dist, dev = get_device_distances(cpucycle_coreid())
closest_dev = dev[dev |> keys |> minimum]
println(closest_dev)
