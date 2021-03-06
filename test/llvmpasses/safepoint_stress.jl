# RUN: julia --startup-file=no %s | opt -load libjulia.so -LateLowerGCFrame -S - | FileCheck %s

println("""
%jl_value_t = type opaque
declare %jl_value_t addrspace(10)* @alloc()
declare void @one_arg_boxed(%jl_value_t addrspace(10)*)
declare %jl_value_t*** @jl_get_ptls_states()

define void @stress(i64 %a, i64 %b) {
    %ptls = call %jl_value_t*** @jl_get_ptls_states()
""")

# CHECK: %gcframe = alloca %jl_value_t addrspace(10)*, i32 10002
for i = 1:10000
    println("\t%arg$i = call %jl_value_t addrspace(10)* @alloc()")
end

for i = 1:10000
    println("\tcall void @one_arg_boxed(%jl_value_t addrspace(10)* %arg$i)")
end

println("""
    ret void
}
""")
