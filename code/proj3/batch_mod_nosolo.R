#29392
rm(list=ls())
#require(Rmpi)
library(tidyverse)
library(statnet)
library(parallel)
library(pbapply)
library(btergm)
library(ergm.terms.contrib)
library(ergm.userterms)
library(ggmap)
library(lubridate)
require(doParallel)
require(foreach)
require(ergm)
#require(Rmpi)
library(ggmap)

source('code/proj3/boot_MPLE.R')
load('scratch/final_boot_runs.RData')
keep_nodes = lapply(net_list,function(x) which(degree(x,gmode='graph')>1 | 1:network.size(x) <= x$gal$bipartite))

net_sub_list = lapply(1:length(net_list),function(x) get.inducedSubgraph(net_list[[x]], v = keep_nodes[[x]]))





form_fin = net_list$FINANCIAL ~ edges +  offset(isolates) + #b2degree(1) + 
  gwb1degree(0.75,fixed=T) + 
  gwb2degree(0.75,fixed=T) + 
  gwb1nsp(0.25,fixed=T) + gwb2nsp(0.25,fixed=T) + 
  offset(b1mindegree(max(degree(net_list$FINANCIAL,gmode='graph')[1:net_list$FINANCIAL$gal$bipartite]) + 1)) + 
  offset(b2mindegree(max(degree(net_list$FINANCIAL,gmode='graph')[(net_list$FINANCIAL$gal$bipartite+1):network.size(net_list$FINANCIAL)]) + 1)) + 
  b1factor('Water_Type') + b1factor('Make_Buy') +
  b1cov('Log_Acreage') + 
  b1cov('AGE') + 
  b1cov('Log_Service_Pop') + 
  b1cov('Log_Bonds_Outstanding_Per_Connection') + 
  b1cov('Log_Revenue_Per_Connection') + 
  b1cov('Viol_Points_5yr') + 
  #b1absdiff('Log_Service_Pop') +
  #b1absdiff('Log_Revenue_Per_Connection') +
  #b1absdiff('Log_Bonds_Outstanding_Per_Connection') +
  #b1absdiff('Viol_Points_5yr') +
  b1nodematch('Same_GCD_GW_User',diff=F,keep = which(grepl('GW',sort(unique(net_list$FINANCIAL %v% 'Same_GCD_GW_User')))&grepl('Self',sort(unique(net_list$FINANCIAL %v% 'Same_GCD_GW_User')))) )+
  edgecov(trans_fin_mat) + edgecov(as.matrix(mat_fin_nearest_other))

nd = ifelse(degree(net_list$FINANCIAL,gmode='graph') > 40,degree(net_list$FINANCIAL,gmode='graph'),NA)

m1 = ergm(form_fin,eval.loglik = F,verbose=F,
          constraints = ~ edges, #bd(maxin=nd,maxout=nd,minin=nd,minout=nd),
          control = control.ergm(MCMC.interval = 1500,MCMC.burnin = 10000,init.method = 'CD',
                                 MCMLE.maxit = 20,,MCMC.samplesize = 20000,parallel.type="PSOCK",parallel=4,
                                 Step.MCMC.samplesize = 1000),offset.coef = c(-Inf,-Inf,-Inf))

m1B = logLik(m1, add=TRUE)
save.image('scratch/ergm_mcmc_psock_results_test.RData')

form_man = net_list$MANAGERIAL ~ edges +  offset(isolates) + #b2degree(1) +
  gwb1degree(0.75,fixed=T) + 
  gwb2degree(0.75,fixed=T) + 
  gwb1nsp(0.25,fixed=T) + gwb2nsp(0.25,fixed=T) + 
  offset(b1mindegree(max(degree(net_list$MANAGERIAL,gmode='graph')[1:net_list$MANAGERIAL$gal$bipartite]) + 1)) + 
  offset(b2mindegree(max(degree(net_list$MANAGERIAL,gmode='graph')[(net_list$MANAGERIAL$gal$bipartite+1):network.size(net_list$MANAGERIAL)]) + 1)) + 
  b1factor('Water_Type') + b1factor('Make_Buy') +
  b1cov('Log_Acreage') + 
  b1cov('AGE') + 
  b1cov('Log_Service_Pop') + 
  b1cov('Log_Bonds_Outstanding_Per_Connection') + 
  b1cov('Log_Revenue_Per_Connection') + 
  b1cov('Viol_Points_5yr') + 
  #b1absdiff('Log_Service_Pop') +
  #b1absdiff('Log_Revenue_Per_Connection') +
  #b1absdiff('Log_Bonds_Outstanding_Per_Connection') +
  #b1absdiff('Viol_Points_5yr') +
  b1nodematch('Same_GCD_GW_User',diff=F,keep = which(grepl('GW',sort(unique(net_list$MANAGERIAL %v% 'Same_GCD_GW_User')))&grepl('Self',sort(unique(net_list$MANAGERIAL %v% 'Same_GCD_GW_User')))) )+
  edgecov(trans_man_mat) + edgecov(as.matrix(mat_man_nearest_other))

m2 = ergm(form_man,eval.loglik = F,verbose=F,
          constraints = ~ edges,
          control = control.ergm(MCMC.interval = 1500,MCMC.burnin = 10000,init.method = 'CD',
                                 MCMLE.maxit = 20,MCMC.samplesize = 20000,parallel.type="PSOCK",parallel=4,
                                 Step.MCMC.samplesize = 1000),offset.coef = c(-Inf,-Inf,-Inf))
#stopImplicitCluster()
m2B = logLik(m2, add=TRUE)
save.image('scratch/ergm_mcmc_psock_results_test.RData')
# 
form_tech = net_list$TECHNICAL ~ edges +  offset(isolates) + #b2degree(1) +
  gwb1degree(0.75,fixed=T) + 
  gwb2degree(0.75,fixed=T) + 
  gwb1nsp(0.25,fixed=T) + gwb2nsp(0.25,fixed=T) + 
  offset(b1mindegree(max(degree(net_list$TECHNICAL,gmode='graph')[1:net_list$TECHNICAL$gal$bipartite]) + 1)) + 
  offset(b2mindegree(max(degree(net_list$TECHNICAL,gmode='graph')[(net_list$TECHNICAL$gal$bipartite+1):network.size(net_list$TECHNICAL)]) + 1)) + 
  b1factor('Water_Type') + b1factor('Make_Buy') +
  b1cov('Log_Acreage') + 
  b1cov('AGE') + 
  b1cov('Log_Service_Pop') + 
  b1cov('Log_Bonds_Outstanding_Per_Connection') + 
  b1cov('Log_Revenue_Per_Connection') + 
  b1cov('Viol_Points_5yr') + 
  # #b1absdiff('Log_Service_Pop') +
  # #b1absdiff('Log_Revenue_Per_Connection') +
  # #b1absdiff('Log_Bonds_Outstanding_Per_Connection') +
  # #b1absdiff('Viol_Points_5yr') +
  b1nodematch('Same_GCD_GW_User',diff=F,keep = which(grepl('GW',sort(unique(net_list$TECHNICAL %v% 'Same_GCD_GW_User')))&grepl('Self',sort(unique(net_list$TECHNICAL %v% 'Same_GCD_GW_User')))) )+
  edgecov(trans_tech_mat) + edgecov(as.matrix(mat_tech_nearest_other))
# 
m3 = ergm(form_tech,eval.loglik = F,verbose=F,constraints = ~edges,
          control = control.ergm(MCMC.interval = 1500,MCMC.burnin = 10000,
                                 MCMLE.maxit = 20,MCMC.samplesize = 20000,parallel.type="PSOCK",parallel=4,
                                 Step.MCMC.samplesize = 1000),offset.coef = c(-Inf,-Inf,-Inf))
m3B = logLik(m3, add=TRUE)
# #stopImplicitCluster()
save.image('scratch/ergm_mcmc_psock_results_test.RData')

