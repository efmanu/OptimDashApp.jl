function eval_definition(fn, init_val, lb, ub)
    return (
        eval(Meta.parse(fn)),
        eval(Meta.parse(init_val)),
        eval(Meta.parse(lb)),
        eval(Meta.parse(ub))
    )
end
