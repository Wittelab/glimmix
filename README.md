# Multilevel Modeling in Epidemiology with GLIMMIX

## Purpose
This page gives SAS code and a Macro for epidemiologic analysis by hierarchical modeling with the SAS Macro GLIMMIX.  This site complements the manuscript "Multilevel Modeling in Epidemiology with GLIMMIX" by Witte et al. (Epidemiology 2000;11:684-688).  In particular, we provide an electronic version of the SAS code given in the paper's appendix, and a Macro that automates some of the steps required when using GLIMMIX.

## Use
To run the Macro, one inputs first- and second-stage data, plus if semi-Bayes, pre-specified second-stage variance values.   As currently written, the Macro reproduces the application given in the corresponding manuscript (for SAS 8+).  Note that with SAS updates this may not necessarily work on your system.  Also, GLIMMIX is now a procedure in SAS 9.1+. 

To replicate our hierarchical modeling application with this Macro, follow these steps:

1. Save and unzip Hmmacros.zip to get the following files and data:
  * hmmacro.sas;
  * hm1.sas;
  * the first-stage design matrix, X_dat;
  * disease status, Y_dat;
  * the second-stage design matrix, Z_dat;
  * the second-stage variance values, tau_dat;
  *the potential confounders, W_dat; and
  * GLIMMIX, glmm612.sas.
2. Run the program "hmmacro.sas" in SAS.
