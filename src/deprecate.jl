@deprecate(facetregressiontable(data, response::Union{Symbol,AbstractString},
                                predictor::Union{Symbol,AbstractString},
                                group::Union{Symbol,AbstractString};
                                orderby::Symbol=:none, rev::Bool=false),
           DataFrame(facetregressioninfotable(data, response, predictor, group; orderby,
                                              rev)))

@deprecate(facetregressiontable(m::LinearMixedModel,
                                predictor::Union{Symbol,AbstractString},
                                group::Union{Symbol,AbstractString}=first(fnames(m));
                                orderby::Symbol=:none, rev::Bool=false),
           DataFrame(facetregressioninfotable(m, predictor, group; orderby, rev)))

@deprecate(facetregressiontable(m::LinearMixedModel;
                                group::Union{Symbol,AbstractString}=first(fnames(m)),
                                orderby::Symbol=:none, rev::Bool=false),
           DataFrame(facetregressioninfotable(m; group, orderby, rev)))
