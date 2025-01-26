
# Nicholas Ducharme-Barth
# 2025/01/25
# R code to modify a baseline stock synthesis model using a 'for' loop
# change steepness and run alternative versions of the model

# Copyright (c) 2025 Nicholas Ducharme-Barth

# load packages
    library(r4ss)

# define paths
	proj_dir = this.path::this.proj()
    from_dir = file.path(proj_dir,"stock-synthesis-models","base-model")
    dir_exec = file.path(proj_dir,"executables","stock-synthesis","3.30.23.1")
    ss3_exec = "ss3_linux"

#_____________________________________________________________________________________________________________________________
# analyze in a for loop
    steepness_vec = c(0.5,0.6,0.7)
    for(i in seq_along(steepness_vec)){
        # make new directory
            tmp_dir = file.path(proj_dir,"stock-synthesis-models","steepness-",steepness_vec[i])
            dir.create(tmp_dir,recursive=TRUE)
        
        # modify control file
        # read in baseline stock synthesis files using r4ss functions
            tmp_ctl = SS_readctl(file=file.path(from_dir,"control.ss_new"),datlist = file.path(from_dir,"data_echo.ss_new"))
            tmp_ctl$SR_parms["SR_BH_steep","INIT"] = steepness_vec[i]
        
        # write out file using r4ss functions
            SS_writectl(tmp_ctl,outfile=file.path(tmp_dir,"control.ss"),overwrite=TRUE)
        # copy remaining input files and executable
            file.copy(from=file.path(from_dir,c("starter.ss_new","data_echo.ss_new","forecast.ss_new")),to=file.path(tmp_dir,c("starter.ss","data.ss","forecast.ss")))
            file.copy(from=file.path(dir_exec,ss3_exec),to=tmp_dir)

        # run the model
            run(dir=tmp_dir,exe=ss3_exec,show_in_console=TRUE,skipfinished=FALSE)

        # clean-up workspace
        rm(list=c("tmp_dir","tmp_ctl"))
    }
