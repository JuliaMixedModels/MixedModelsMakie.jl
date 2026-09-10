f = shrinkageplot(m1)
@test save(joinpath(OUTDIR, "shrinkage_sleepstudy.png"), f)

f = shrinkageplot(m2, :item)
@test save(joinpath(OUTDIR, "shrinkage_kb07_item.png"), f)

f = shrinkageplot(m2, :subj)
@test save(joinpath(OUTDIR, "shrinkage_kb07_subj.png"), f)

f = shrinkageplot(m2; ellipse=true)
@test save(joinpath(OUTDIR, "shrinkage_kb07_subj_ellipse.png"), f)

f = shrinkageplot(m2; ellipse=true, cols=["spkr: old", "prec: maintain", "(Intercept)"])
@test save(joinpath(OUTDIR, "shrinkage_kb07_subj_cols.png"), f)

@test_throws(ArgumentError("You only specified a single column. You need at least two."),
             shrinkageplot(m2; ellipse=true, cols=["spkr: old"]))

@test_throws(ArgumentError("Random effect grouping only has a single predictor associated with it (\"(Intercept)\"). You need at least two."),
             shrinkageplot(m2int; ellipse=false))

@test_throws(ArgumentError("Random effect grouping only has a single predictor associated with it (\"(Intercept)\"). You need at least two."),
             shrinkageplot(m2int, :item))

f = shrinkageplot(m2; ellipse=true, ellipse_scale=2)
@test save(joinpath(OUTDIR, "shrinkage_kb07_subj_ellipse_scaled.png"), f)

f = shrinkageplot(g1, :item)
@test save(joinpath(OUTDIR, "shrinkage_verbagg.png"), f)

f = shrinkageplot(g1, :item; ellipse=true, n_ellipse=2)
@test save(joinpath(OUTDIR, "shrinkage_verbagg_ellipse.png"), f)

f = shrinkageplot(m1; labels=true)
@test save(joinpath(OUTDIR, "shrinkage_sleepstudy_labels.png"), f)

f = shrinkageplot(m2, :subj; labels=["S030", "S031"])
@test save(joinpath(OUTDIR, "shrinkage_kb07_subj_labels_subset.png"), f)

@test_throws(ArgumentError("Specified columns not found in random effects: [\"nonexistent\"]"),
             shrinkageplot(m1; labels=["nonexistent"]))

f = shrinkageplot(m1; labels=:auto)
@test save(joinpath(OUTDIR, "shrinkage_sleepstudy_labels_auto.png"), f)

f = shrinkageplot(m2, :item; labels=:auto, n_labels=3)
@test save(joinpath(OUTDIR, "shrinkage_kb07_item_labels_auto.png"), f)

@test_throws(ArgumentError("Unsupported value for `labels`: bogus. Use `true`, `false`, " *
                           "`:auto`, or a vector of level names/indices."),
             shrinkageplot(m1; labels=:bogus))

si = shrinkageinfo(m1, :subj)
f = shrinkageplot(si; ellipse=true)
@test save(joinpath(OUTDIR, "shrinkage_sleepstudy_from_info.png"), f)

f = shrinkagedot(m1)
@test save(joinpath(OUTDIR, "shrinkagedot_sleepstudy.png"), f)

f = shrinkagedot(m2, :subj; orderby=Symbol("(Intercept)"))
@test save(joinpath(OUTDIR, "shrinkagedot_kb07_subj_orderby_name.png"), f)

f_int = shrinkagedot(m2, :subj; orderby=1)
@test save(joinpath(OUTDIR, "shrinkagedot_kb07_subj_orderby_idx.png"), f_int)

f = shrinkagedot(m2, :subj; orderby="prec: maintain", cols=["load: yes", "prec: maintain"])
@test save(joinpath(OUTDIR, "shrinkagedot_kb07_subj_orderby_name_string.png"), f)

f = shrinkagedot(m1; orderby=nothing)
@test save(joinpath(OUTDIR, "shrinkagedot_sleepstudy_unordered.png"), f)

f = shrinkagedot(m1; ordertype=:ref)
@test save(joinpath(OUTDIR, "shrinkagedot_sleepstudy_orderby_ref.png"), f)

@test_throws(ArgumentError("ordertype must be :shrunk or :ref, got :bogus"),
             shrinkagedot(m1; ordertype=:bogus))
