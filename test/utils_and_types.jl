@testset "utilities" begin
    ppts = MixedModelsMakie.ppoints(64)
    @test length(ppts) == 64
    @test first(ppts) ≈ inv(128)

    @test MixedModelsMakie.zquantile(0.025) ≈ -1.96 atol = 0.005
    @test MixedModelsMakie.zquantile(0.975) ≈ 1.96 atol = 0.005
    @test MixedModelsMakie.zquantile(0.50) ≈ 0
end

@testset "_resolve_orderby" begin
    cn = ["(Intercept)", "days"]
    @test isnothing(MixedModelsMakie._resolve_orderby(cn, nothing))
    @test MixedModelsMakie._resolve_orderby(cn, 2) == 2
    @test MixedModelsMakie._resolve_orderby(cn, :days) == 2
    @test MixedModelsMakie._resolve_orderby(cn, "days") == 2
    @test_throws ArgumentError MixedModelsMakie._resolve_orderby(cn, :nonexistent)
end

@testset "_histcurve" begin
    curve = MixedModelsMakie._histcurve(zeros(50); bins=1)
    @test curve isa MixedModelsMakie._StepCurve
    @test length(curve.x) == length(curve.density)
    # closed at 0 on both ends, and the single bin spans the whole range
    @test first(curve.density) == 0
    @test last(curve.density) == 0
    @test maximum(curve.density) == 50

    curve2 = MixedModelsMakie._histcurve(zeros(50); bins=5)
    @test maximum(curve2.density) == 50
end

@testset "Simple linear regression" begin
    a, b = 1, 2
    n = 100
    x = 1:n
    y = randn(MersenneTwister(42), n) * 0.1
    @. y += a + b * x
    result = simplelinreg(x, y)
    @test result isa Tuple
    @test a ≈ result[1] atol = 0.05
    @test b ≈ result[2] atol = 0.05

    # constant x makes the Gram matrix singular, so Cholesky fails and
    # simplelinreg must fall back to a QR-based solve instead of erroring
    xconst = fill(3.0, n)
    resultconst = simplelinreg(xconst, y)
    @test resultconst isa Tuple
    @test length(resultconst) == 2
    @test all(isfinite, resultconst)
end

@testset "confint_table" begin
    wald = confint_table(m1_speed, 0.68)
    bsamp = parametricbootstrap(MersenneTwister(42), 1000, m1_speed; progress)
    boot = confint_table(bsamp, 0.68)

    @test wald.coefname == boot.coefname
    @test wald.estimate ≈ boot.estimate rtol = 0.05
    @test wald.lower ≈ boot.lower rtol = 0.05
    @test wald.upper ≈ boot.upper rtol = 0.05

    @test all(splat(isapprox),
              zip(MixedModelsMakie.confint_table(mr).estimate, fixef(mr)))

    @test fixefnames(mr) == MixedModelsMakie.confint_table(mr).coefname
    @test fixefnames(mr) == MixedModelsMakie.confint_table(br).coefname

    sigma = confint_table(b1, 0.68; ptype=:σ)
    @test sort(sigma.coefname) ==
          ["residual", "subj: (Intercept)", "subj: days"]

    rho = confint_table(b1, 0.68; ptype=:ρ)
    @test rho.coefname == ["subj: (Intercept), days"]

    theta = confint_table(b1, 0.68; ptype=:θ)
    @test sort(theta.coefname) == ["θ1", "θ2", "θ3"]

    @test_throws ArgumentError confint_table(b1; ptype=:σs)

    sigma_subj = confint_table(b2, 0.68; ptype=:σ, group=:subj)
    @test sort(sigma_subj.coefname) ==
          ["subj: (Intercept)", "subj: load: yes", "subj: prec: maintain",
           "subj: spkr: old"]

    sigma_item = confint_table(b2, 0.68; ptype=:σ, group=:item)
    @test sort(sigma_item.coefname) == ["item: (Intercept)", "item: spkr: old"]

    rho_item = confint_table(b2, 0.68; ptype=:ρ, group=:item)
    @test rho_item.coefname == ["item: (Intercept), spkr: old"]

    @test_throws ArgumentError confint_table(b2; ptype=:β, group=:subj)
    @test_throws ArgumentError confint_table(b2; ptype=:θ, group=:subj)
    @test_throws ArgumentError confint_table(b2; ptype=:σ, group=:nope)

    @test confint_table(b1, 0.68; ptype=:sigma) == sigma
    @test confint_table(b1, 0.68; ptype=:rho) == rho
    @test confint_table(b1, 0.68; ptype=:theta) == theta
end

@testset "ranefinfo" begin
    reinfo = ranefinfo(m1_speed)
    @test isone(length(reinfo))
    @test keys(reinfo) == (:subj,)
    re1 = only(reinfo)
    @test isa(re1, RanefInfo)
    @test re1.cnames == ["(Intercept)", "days"]
    @test first(re1.levels) == "S308"
    @test first(re1.ranef) ≈ -0.081830 atol = 1e-5
    @test first(re1.stddev) ≈ 0.140354 atol = 1e-5
    f = Figure()
    @test f.content == Any[]
    caterpillar!(f, re1)
    @test length(f.content) == 2
    @test isa(first(f.content), Axis)
    @test size(f.layout) == (1, 2)
    tbl = ranefinfotable(re1)
    @test keys(tbl) == (:name, :level, :cmode, :cstddev)
    @test length(tbl.cmode) == length(re1.cnames) * length(re1.levels)

    tbl2 = ranefinfotable(m1_speed, :subj)
    @test tbl2 == tbl

    reinfo2 = ranefinfo(m2)
    @test keys(reinfo2) == (:subj, :item)
    tbl_all = ranefinfotable(reinfo2)
    @test keys(tbl_all) == (:group, :name, :level, :cmode, :cstddev)
    @test length(tbl_all.cmode) ==
          length(ranefinfotable(reinfo2.subj).name) +
          length(ranefinfotable(reinfo2.item).name)
    @test all(==(:subj), tbl_all.group[1:length(ranefinfotable(reinfo2.subj).name)])
end

@testset "shrinkageinfo" begin
    sinfo = shrinkageinfo(m1_speed)
    @test isone(length(sinfo))
    @test keys(sinfo) == (:subj,)
    si1 = only(sinfo)
    @test isa(si1, ShrinkageInfo)
    @test si1.cnames == ["(Intercept)", "days"]
    @test first(si1.levels) == "S308"
    @test size(si1.λ) == (2, 2)
    @test size(si1.blups) == size(si1.blimps) == (length(si1.levels), length(si1.cnames))

    si2 = shrinkageinfo(m1_speed, :subj)
    @test si2.cnames == si1.cnames
    @test si2.blups == si1.blups
    @test si2.blimps == si1.blimps
    @test si2.λ == si1.λ

    tbl = shrinkageinfotable(si1)
    @test keys(tbl) == (:name, :level, :cmode, :rmode)
    @test length(tbl.cmode) == length(si1.cnames) * length(si1.levels)

    tbl2 = shrinkageinfotable(m1_speed, :subj)
    @test tbl2 == tbl

    sinfo2 = shrinkageinfo(m2)
    @test keys(sinfo2) == (:subj, :item)
    tbl_all = shrinkageinfotable(sinfo2)
    @test keys(tbl_all) == (:group, :name, :level, :cmode, :rmode)
    @test length(tbl_all.cmode) ==
          length(shrinkageinfotable(sinfo2.subj).name) +
          length(shrinkageinfotable(sinfo2.item).name)
end
