include("precompile_funcs.jl")

using OptimDash

using .PrecompileFuncs
PrecompileFuncs.precompile_optim()

app = OptimDash.make_app()

port = haskey(ENV, "PORT") ? parse(Int64, ENV["PORT"]) : 8050

OptimDash.Dash.run_server(app, "0.0.0.0", port)