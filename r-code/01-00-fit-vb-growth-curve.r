
# Nicholas Ducharme-Barth
# 2025/01/25
# Fit a von Bertalanffy growth curve to some simulated age and growth data

# Copyright (c) 2025 Nicholas Ducharme-Barth

# load packages
    library(data.table)
    library(ggplot2)
    library(magrittr)

# define paths
	proj_dir = this.path::this.proj()
    from_dir = file.path(proj_dir,"data")

# read in data
    age_dt = fread(file=file.path(from_dir,"age-and-growth.csv"))

# define likelihood function
    nll_function = function(par,data){
        # estimate on log-scale to restrict to positive values
        Linf = exp(par[1])
        K = exp(par[2])
        t0 = par[3]
        cv = exp(par[4])

        # define expectation
        mu = Linf * (1 - exp(-K * (data$age - t0)))
        sigma = sqrt(log(1 + cv^2))
        mu_log = log(mu) - (sigma^2)/2

        # calculate the negative log-likelihood
        nll = -sum(dlnorm(data$length, meanlog = mu_log, sdlog = sigma, log = TRUE))
        return(nll)
    }

# fit the model
    init_par = c(Linf=log(110),
                K=log(0.15),
                t0=0,
                cv=log(0.3))
    model_data = age_dt
    fit = optim(par=init_par, fn = nll_function, data = model_data, method="BFGS")

# extract estimated parameters
    est_par = as.list(c(exp(fit$par[1]),exp(fit$par[2]),fit$par[3],exp(fit$par[4])))

# plot expected vs. predicted
    model_data$predicted = est_par$Linf * (1 - exp(-est_par$K * (model_data$age - est_par$t0)))

    p = model_data %>%
        .[order(age)] %>%
        ggplot() +
        ylim(0,NA) +
		xlab("Age") +
        ylab("Length") +
        geom_point(aes(x=age,y=length),color="black",fill="blue",shape=21,cex=3,alpha=0.3) +
        geom_path(aes(x=age,y=predicted),linewidth=1.5) +
		theme(panel.background = element_rect(fill = "white", color = "black", linetype = "solid"),
							panel.grid.major = element_line(color = 'gray70',linetype = "dotted"), 
							panel.grid.minor = element_line(color = 'gray70',linetype = "dotted"),
							strip.background =element_rect(fill="white"),
							legend.key = element_rect(fill = "white"))    

