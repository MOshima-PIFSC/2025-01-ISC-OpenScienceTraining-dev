# Two-sex Von Bertalanffy growth function with lognormal error
vb_growth_with_lognormal_error <- function(t, Linf, K, t0, cv, sex) {
  # Generate perfect curve (different parameters for each sex)
  if (sex == "Female") {
    mu <- Linf[1] * (1 - exp(-K[1] * (t - t0[1])))
  } else {
    mu <- Linf[2] * (1 - exp(-K[2] * (t - t0[2])))
  }
  # Add lognormal error
  # Convert CV to sigma parameter for lognormal distribution
  sigma <- sqrt(log(1 + cv^2))
  mu_log <- log(mu) - (sigma^2)/2
  exp(rnorm(length(t), mean = mu_log, sd = sigma))
}

# simulate age and growth data
seed = 123
set.seed(seed)

# male then female
n_samp_by_sex = rpois(2,500)
max_age_by_sex = c(15,12)

male_age = runif(n_samp_by_sex[2],0,max_age_by_sex[2])
female_age = runif(n_samp_by_sex[1],0,max_age_by_sex[1])

input = list(Linf_f=120,
             Linf_m=100,
             K_f=0.25,
             K_m=0.3,
             t0_f=-0.5,
             t0_m=-0.5,
             cv=0.15)

female_length = vb_growth_with_lognormal_error(
        female_age,
        Linf = c(input$Linf_f, input$Linf_m),
        K = c(input$K_f, input$K_m),
        t0 = c(input$t0_f, input$t0_m),
        cv = input$cv,
        sex = "Female"
      )

male_length = vb_growth_with_lognormal_error(
        male_age,
        Linf = c(input$Linf_f, input$Linf_m),
        K = c(input$K_f, input$K_m),
        t0 = c(input$t0_f, input$t0_m),
        cv = input$cv,
        sex = "Male"
      )

female_data = data.frame(sex=rep("female",n_samp_by_sex[1]),
                       age=female_age,
                       length=female_length)
male_data = data.frame(sex=rep("male",n_samp_by_sex[2]),
                       age=male_age,
                       length=male_length)
data = rbind(female_data,male_data)

proj_dir = this.path::this.proj()
data_dir = file.path(proj_dir,"data")
dir.create(data_dir,recursive=TRUE)

write.csv(data,file=file.path(data_dir,"age-and-growth.csv"))

