library(macpan2)
m = Compartmental(system.file("starter_models", "sir", package = "macpan2"))
s =m$simulators$tmb(30
  , state = c(S = 99, I = 1, R = 0)
  , flow = c(foi = 0, gamma = 0.1)
  , beta = 0.25, N = 100
)

# do this once per ensemble
# this is set up to tell s$report how to parse the pvec
# that gets passed
# key are mat, row, and col
# default is just a placeholder
pf = data.frame( # each row is a scalar
              #  beta ,  gamma
    mat     = c("beta", "flow")
  , row     = c(0     , 1     ) # row and col are positions in these matrices
  , col     = c(0     , 0     )
  , default = c(0.25  , 0.1   ) # value to place, could be different
  # become initial values for 
)
s$replace$params_frame(pf)


# do this once per iteration of the ensemble
# parameter vector with beta and gamma:
       # beta, gamma
pvec = c(0.25, 0.1)

s$report(pvec, .phases = "during")
s$report(pvec + 0.1, .phases = "during")
s$report(.phases = "during")
