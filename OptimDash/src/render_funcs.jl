function render_all()
    return dbc_container([
        dbc_row([
            render_info()
        ]),
        dbc_row([
            render_func_init(),
            dbc_col([
                dbc_button("Optimize!", color="success", id="dopt-btn-optim")
            ], md =2),            
            render_plots()
        ])
    ])
end
function render_info()
    return dbc_col([
        dbc_jumbotron([
            html_h1("Dash Optim App", className="dopt-display-3"),
            html_p(
                "Web app to optimize various functions with the help of Dash.jl and Optim.jl ",
                className="lead",
            ),
            html_hr(className="my-2"),
            html_p(
                "Enter functions and initial conditions in the input boxes and press optimize button",
            ),
            html_p(
                "NB: Only functions with 2 parameters",
            )
        ])
    ])
end
function render_func_init()
    return dbc_col([
        html_div([
            render_function(),        
            render_init(),
        ]),        
    ], md=4)
end
function render_function()
    return dbc_card([
        dbc_cardbody([
            html_h4("Enter the objective function:", className="card-title"),
            html_div([
                dbc_textarea(
                    id = "dopt-user-funcs",
                    bs_size="lg",
                    className="mb-3",
                    value="f(x) = x[1]^2 + 3*x[2]^2",
                )
            ]),
        ])
    ])
end
function render_init()
    return dbc_card([
            dbc_cardbody([
                html_h4("Enter the intial solution:", className="card-title"),
                html_div([
                    dbc_textarea(
                        id = "dopt-user-func-init",
                        bs_size="lg",
                        className="mb-3",
                        value="[2.0, -1.0]",
                    )
                ]),
            ])
        ])
end
function render_liveupdates()
    global x_graph
    global y_graph
    return html_div([
        html_h3("Plots"),
        dcc_interval(
            id="interval-component",
            interval=1000, # in milliseconds
            n_intervals=0,
            disabled=false
        ),
        dcc_graph(id="dopt-params-state",
            figure=Dict(
                "data" => [
                    Dict("x" => x_graph, "y" => y_graph),
                ]
            )
        )
    ])
end
function render_plots()
    return dbc_col(id="dopt-params-plot-loc", md = 6)
end