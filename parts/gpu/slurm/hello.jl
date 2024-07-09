using MPI, CUDA, Libdl

#_______________________________________________________________________________
# Get MPI version string from libmpi.so
#

function get_mpi_version_string()
    buf_size = 8192 # HACK: this should be enough space
    buf = Array{UInt8}(undef, buf_size)
    buflen = Ref{Cint}()

    hndl = Libdl.dlopen(MPI.libmpi, Libdl.RTLD_LAZY | Libdl.RTLD_GLOBAL)

    try
        ptr = Libdl.dlsym(hndl, :MPI_Get_library_version)
        ccall(ptr, Cint, (Ptr{UInt8}, Ref{Cint}), buf, buflen)
    finally
        Libdl.dlclose(hndl)
    end

    @assert buflen[] < buf_size
    resize!(buf, buflen[])
    return String(buf)
end

#-------------------------------------------------------------------------------


#_______________________________________________________________________________
# Get information on which Device and Bus a GPU is connected to:
#

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

#-------------------------------------------------------------------------------


MPI.Init()
MPI.ThreadLevel(2)

comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
size = MPI.Comm_size(comm)
name = gethostname()

devices = get_device_attributes()

# get the MPI version string and print it. This will be the same for every
# rank, so do this only on Rank 0
if rank == 0
    version_string = get_mpi_version_string()
    println("MPI Version: $(version_string)")
end

println(
    "Hello world, I am rank $(rank) of $(size) on $(name). " *
    "I have $(ndevices()) GPUs with properties: $(devices)" 
)

MPI.Barrier(comm)
