module PrecompileFuncs
    using OptimDash
    using OptimDash.Optim

function precompile_optim()
    chn = Base.Channel{Vector{Float64}}(Inf)
    user_funcs = "f(x) = (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2"
    funcs_init = "[0.0, 0.0]"
    eval_f, init_f = OptimDash.eval_definition(user_funcs, funcs_init)
    function g(f)
        function _g(x)
            put!(chn, x)
            return Base.invokelatest(f, x)
        end
        return _g
    end
    results = optimize(g(eval_f), init_f)
    return "success"
end
end