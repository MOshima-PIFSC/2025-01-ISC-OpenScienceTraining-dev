
# Nicholas Ducharme-Barth
# 2025/01/25
# R code to modify a baseline stock synthesis model
# change steepness and run alternative versions of the model

# Copyright (c) 2025 Nicholas Ducharme-Barth

# load packages
    library(r4ss)

# define paths
	proj_dir = this.path::this.proj()
    from_dir = file.path(proj_dir,"stock-synthesis-models","base-model")
    to_dir = file.path(proj_dir,"stock-synthesis-models","steepness-0.7")
    dir.create(to_dir,recursive=TRUE)

# read control file
    tmp_ctl = SS_readctl(file=file.path(from_dir,"control.ss"),
                         datlist = file.path(from_dir,"data.ss"))

# modify
    tmp_ctl$SR_parms["SR_BH_steep","INIT"] = 0.7

# write out file using r4ss functions
    SS_writectl(tmp_ctl,outfile=file.path(to_dir,"control.ss"),overwrite=TRUE)


# give permissions to executable
    system(paste0("cd ",dir_exec,"; chmod 777 ", ss3_exec))

# copy over executable & other stock synthesis input files
    dir_exec = file.path(proj_dir,"executables","stock-synthesis","3.30.22.1")
    ss3_exec = "ss3_linux"  
    file.copy(from=file.path(dir_exec,ss3_exec),to=to_dir,overwrite=TRUE)
    file.copy(from=file.path(from_dir,c("data.ss","forecast.ss","starter.ss")),to=to_dir,overwrite=TRUE)

# run the model
    run(dir=to_dir,exe=ss3_exec,show_in_console=TRUE,skipfinished=FALSE)
