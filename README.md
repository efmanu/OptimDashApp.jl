# Dash Optim App
Web app to optimize functions of 2 variables using Optim.jl, created with Dash.jl.

NB: Only functions with 2 parameters

### Run DashOptim App
From the project folder, enter the following commands in Julia REPL
```julia
    julia>using Pkg
    julia>Pkg.activate(".")
    julia>include("run.jl")
```

### Deploy in Herokuapp
From the project folder, enter the following commands in command line/terminal etc.
```
heroku login #then login to heroku app with your credentials
git push heroku master
```
Sometimes push won't work, then do

```
git push heroku master:master -f
```
