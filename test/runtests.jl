using Atak
using Test
using Dates
using Ionic

@testset "Atak.jl" begin
    @testset "Store" begin
        storedir = mktempdir()
        s = store(storedir)

        @testset "Namespace" begin
            ns = namespace(s, :test)
            @test isdir(joinpath(storedir, "test"))
        end

        @testset "Document" begin
            ns = namespace(s, :docs)
            d = document(ns, :test, "hello")
            @test isfile(joinpath(storedir, "docs", "test.jld2"))
            @test getvalue(d) == "hello"
            setvalue!(d, "world")
            @test getvalue(d) == "world"
        end

        @testset "Collection" begin
            ns = namespace(s, :cols)
            c = collection(ns, :test, Int[1, 2, 3])
            @test isfile(joinpath(storedir, "cols", "test.jld2"))
            @test getvalue(c) == [1, 2, 3]
            setvalue!(c, [4, 5, 6])
            @test getvalue(c) == [4, 5, 6]
        end
    end

    @testset "Scheduler" begin
        s = Scheduler()
        start!(s)

        results = []
        lock = ReentrantLock()

        schedule!(() -> @lock(lock, push!(results, 1)), s, Sched.UserInteractive)
        schedule!(() -> @lock(lock, push!(results, 2)), s, Sched.Normal)
        schedule!(() -> @lock(lock, push!(results, 3)), s, Sched.Low)

        sleep(0.1)

        stop!(s)

        @lock lock begin
            @test length(results) == 3
            @test results[1] == 1
            @test results[2] == 2
            @test results[3] == 3
        end
    end
end
