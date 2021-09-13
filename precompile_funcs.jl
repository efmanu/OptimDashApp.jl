module PrecompileFuncs

using OptimDash
using OptimDash.Optim
using OptimDash.PlotlyJS

function precompile_optim()
    chn = Base.Channel{Vector{Float64}}(Inf)
    user_funcs = "f(x) = x[1]^2 + 3*x[2]^2"
    funcs_init = "[3.0, 3.0]"
    lb_str = "[-10.0, -10.0]"
    ub_str = "[10.0, 10.0]"
    eval_f, init_f, lb_f, ub_f = OptimDash.eval_definition(
        user_funcs, funcs_init, lb_str, ub_str
    )
    function g(f)
        function _g(x)
            put!(chn, x)
            return Base.invokelatest(f, x)
        end
        return _g
    end
    alg = BFGS()
    results = optimize(g(eval_f), init_f, alg, Optim.Options(x_tol = 1e-5))
    
    bound_range = (ub_f - lb_f)./1000
    range_value = [collect(1:10) for _ in 1:2]
    z =  rand(1:10,10,10)
    heat_plt = heatmap(
        x = range_value[1], y = range_value[2], 
        z = z
    )
    # scatter_plt = scatter(
    #     ;x=x_graph, y=y_graph, 
    #     mode="lines", line_color="black"
    # )
    fig = OptimDash.PlotlyJS.plot(heat_plt)
    return "success"
end
end