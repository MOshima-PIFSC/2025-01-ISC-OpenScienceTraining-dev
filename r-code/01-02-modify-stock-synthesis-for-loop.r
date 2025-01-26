
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
    dir_exec = file.path(proj_dir,"executables","stock-synthesis","3.30.22.1")
    ss3_exec = "ss3_linux"

# give permissions to executable
    system(paste0("cd ",dir_exec,"; chmod 777 ", ss3_exec))

#_____________________________________________________________________________________________________________________________
# analyze in a for loop; we already ran the 0.7 model in a previous script
    steepness_vec = c(0.5,0.6,0.8)
    for(i in seq_along(steepness_vec)){
        # make new directory
            tmp_dir = file.path(proj_dir,"stock-synthesis-models",paste0("steepness-",steepness_vec[i]))
            dir.create(tmp_dir,recursive=TRUE)
        
        # modify control file
        # read in baseline stock synthesis files using r4ss functions
            tmp_ctl = SS_readctl(file=file.path(from_dir,"control.ss"),datlist = file.path(from_dir,"data.ss"))
            tmp_ctl$SR_parms["SR_BH_steep","INIT"] = steepness_vec[i]
        
        # write out file using r4ss functions
            SS_writectl(tmp_ctl,outfile=file.path(tmp_dir,"control.ss"),overwrite=TRUE)
        # copy remaining input files and executable
            file.copy(from=file.path(from_dir,c("starter.ss","data.ss","forecast.ss")),to=file.path(tmp_dir,c("starter.ss","data.ss","forecast.ss")))
            file.copy(from=file.path(dir_exec,ss3_exec),to=tmp_dir)

        # run the model
            run(dir=tmp_dir,exe=ss3_exec,show_in_console=TRUE,skipfinished=FALSE)

        # clean-up workspace
        rm(list=c("tmp_dir","tmp_ctl"))
    }
