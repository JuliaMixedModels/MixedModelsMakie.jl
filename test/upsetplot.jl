kb07data = MixedModels.dataset(:kb07)
verbaggdata = MixedModels.dataset(:verbagg)
sleepdata = MixedModels.dataset(:sleepstudy)

# m2: kb07, spkr*prec*load categorical fixed effects, subj + item grouping
f = upsetplot(m2, kb07data)
@test save(joinpath(OUTDIR, "upset_kb07_subj.png"), f)

f = upsetplot(m2, kb07data; gf=:item)
@test save(joinpath(OUTDIR, "upset_kb07_item.png"), f)

# g1: verbagg (GLMM), gender + btype + situ categorical fixed effects
f = upsetplot(g1, verbaggdata)
@test save(joinpath(OUTDIR, "upset_verbagg_subj.png"), f)

# Mutating form into a GridPosition
let f = Figure()
    upsetplot!(f[1, 1], m2, kb07data)
    @test save(joinpath(OUTDIR, "upset_kb07_gridpos.png"), f)
end

# Observation counts (gf=nothing)
f = upsetplot(m2, kb07data; gf=nothing)
@test save(joinpath(OUTDIR, "upset_kb07_obs.png"), f)

# Error: unknown grouping factor
@test_throws ArgumentError upsetplot(m2, kb07data; gf=:nonexistent)

# Error: model has no categorical fixed effects (m1 uses only continuous `days`)
@test_throws ArgumentError upsetplot(m1, sleepdata)
