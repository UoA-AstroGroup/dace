using Test

baremodule NativeDACE
    using Base, CxxWrap
    eval(x) = Core.eval(NativeDACE, x)
    mutable struct Interval
        m_lb::Float64
        m_ub::Float64
    end
    @wrapmodule(() -> ENV["DACE_LIBRARY"], :define_julia_module)
    function __init__()
        @initcxx
    end
end

@testset "Native Julia interface" begin
    NativeDACE.init(3, 1)
    x = NativeDACE.DA(1, 1.0)
    @test NativeDACE.evalScalar((1.0 + x) * (1.0 + x), 0.2) ≈ 1.44

    A = NativeDACE.AlgebraicMatrix{NativeDACE.DA}(2, 2)
    A[1, 1] = 2.0 + x
    A[2, 2] = NativeDACE.DA(4.0)
    A[1, 2] = A[2, 1] = NativeDACE.DA(0.0)
    values, vectors = NativeDACE.eigh(A)
    @test NativeDACE.evalScalar(values[1], 0.2) ≈ 2.2
    @test NativeDACE.cons(values[2]) ≈ 4.0
    @test abs(NativeDACE.cons(vectors[1, 1])) ≈ 1.0
end
