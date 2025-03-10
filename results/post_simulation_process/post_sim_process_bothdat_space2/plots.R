library(plyr)
library(tidyverse)
library(here)
library(data.table)
library(scales)
library(RColorBrewer) 
library("cowplot")
library(rPref)
library(ggrepel)


#### NO REMOVAL ####
ncpath <- 'D:\\Chapter3\\results\\noremoval'
file_name = paste(ncpath, 'states_fin_truth.csv',sep = '/')
noremoval <- fread(file_name)
noremoval <- data.frame(noremoval)

nc.val <- mean(noremoval$state) -1 

noremoval$inv <- noremoval$state
noremoval$inv[noremoval$inv <= 2 ] <- 0
noremoval$inv[noremoval$inv > 2 ] <- 1
nc.inv <- mean(noremoval$inv)

#### States fin truth ####
##### States Fin truth A+C ####
path <- 'D:\\Chapter3\\results-datboth-space2'
file_name = paste(path, 'states_fin_truth.csv',sep = '/')
finstate_truth <- fread(file_name)
finstate_truth <- data.frame(finstate_truth)

finstate_truth$rates <- paste0('(p = )', finstate_truth$detection, ',  \u03F5 = ', finstate_truth$eradication)
finstate_truth$rates2 <- paste0('(', finstate_truth$detection, ', ', finstate_truth$eradication, ")")

finstate_truth$state <- finstate_truth$state - 1

finstate_truth <- aggregate(state ~ sim + location + detection + eradication + budget + rates + rates2, 
                            data = as.data.frame(finstate_truth), 
                            FUN = mean)

colnames(finstate_truth)[5] <- 'Budget'
finstate_truth$loc2 <- paste0(finstate_truth$location, finstate_truth$detection, finstate_truth$eradication)

finstate_truthAC <- finstate_truth 
finstate_truthAC$data <- 'AC' 

#finstate_truth <- rbind(finstate_truthA, finstate_truthAC)

finstate_truth$loc2 <- paste0(finstate_truth$location, finstate_truth$detection, finstate_truth$eradication, finstate_truth$data )

detach(package:plyr)

budget20_suppress <- finstate_truthAC %>% 
  filter(Budget == 20) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(state),
            max_c = max(state),
            lower = quantile(state, 0.1),
            upper = quantile(state, 0.9))

budget20_suppress

budget40_suppress <- finstate_truthAC %>% 
  filter(Budget == 40) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(state),
            max_c = max(state),
            lower = quantile(state, 0.1),
            upper = quantile(state, 0.9))

budget40_suppress

budget60_suppress <- finstate_truthAC %>% 
  filter(Budget == 60) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(state),
            max_c = max(state),
            lower = quantile(state, 0.1),
            upper = quantile(state, 0.9))

budget60_suppress

cols <- brewer.pal(12, "Paired") 
colors <- c(cols[1:4], cols[9:10])
colors <- c(colors[c(2,4)],'white')

colors2 <- c('grey50', 'purple')

finstate_truth <- finstate_truth %>% filter(Budget == 20)

finstate_truth %>% 
  ggplot(aes(x = loc2, y = state, fill = rates2, color =data,
             group = interaction(location, rates2, data)))+
  geom_boxplot() +
  geom_hline(yintercept = nc.val, linetype = 2) + 
  stat_summary(fun.y = mean, geom = "errorbar",
               aes(ymax = after_stat(y), ymin = after_stat(y),
                   group = interaction(location, rates)),
               width = .75, color = "black", linewidth = 1)+ 
  scale_x_discrete(breaks = c("smartepicenter0.50.75A",
                              "linear0.50.75A"),
                   labels=c(
                     "smartepicenter0.50.75A" = "smartepicenter",
                     "linear0.50.75A" = "Linear"))+
  
  scale_fill_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                    values = colors) +
  scale_color_manual(name = "Data",
                     values = colors2, 
                     labels = c('A', 'A + C'))+
  
  xlab("Site prioritization")+
  ylab("Average final invasion")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget, nrow = 3, labeller = label_both)

#### Bias state ####
##### Bias state A+ C ####
path <- 'D:\\Chapter3\\results-datboth-space2'
file_name = paste(path, 'bias_state.csv',sep = '/')
bias_state <- fread(file_name)
bias_state <- data.frame(bias_state)

bias_state$rates <- paste0('p = ', bias_state$detection, ', e = ', bias_state$eradication)


bias_state$loc2 <- paste0(bias_state$location, bias_state$detection, bias_state$eradication)
bias_state$rates2 <- paste0('(', bias_state$detection, ', ', bias_state$eradication, ")")

colnames(bias_state)[8] <- 'Budget'

bias_state$data <- 'AC'
bias_state$loc2 <- paste0(bias_state$location, bias_state$detection, bias_state$eradication, bias_state$data)
bias_stateAC <- bias_state

budget20_biasstate <- bias_stateAC %>% 
  filter(Budget == 20) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias),
            max_c = max(rel.bias),
            upper = quantile(rel.bias, 0.9))

budget20_biasstate

budget40_biasstate <- bias_stateAC %>% 
  filter(Budget == 40) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias),
            max_c = max(rel.bias))

budget40_biasstate

budget60_biasstate <- bias_stateAC %>% 
  filter(Budget == 60) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias),
            max_c = max(rel.bias))

budget60_biasstate

##### comparison Rel. bias ####
path <- 'D:\\Chapter3\\results-space2\\smartepicenter\\S5_R75_20'
file_name = paste(path, 'bias_states.csv',sep = '/')
smartepicenter_biasstate_S5_R75_20 <- fread(file_name)
smartepicenter_biasstate_S5_R75_20 <- data.frame(smartepicenter_biasstate_S5_R75_20)[-1]

smartepicenter_biasstate_S5_R75_20$location <- 'smartepicenter'
smartepicenter_biasstate_S5_R75_20$detection <- 0.5
smartepicenter_biasstate_S5_R75_20$eradication <- 0.75
smartepicenter_biasstate_S5_R75_20$budget <- 20

path <- 'D:\\Chapter3\\results-space2\\smartepicenter\\S5_R75_20_b'
file_name = paste(path, 'bias_states.csv',sep = '/')
smartepicenter_biasstate_S5_R75_20b <- fread(file_name)
smartepicenter_biasstate_S5_R75_20b <- data.frame(smartepicenter_biasstate_S5_R75_20b)[-1]

smartepicenter_biasstate_S5_R75_20b$location <- 'smartepicenter'
smartepicenter_biasstate_S5_R75_20b$detection <- 0.5
smartepicenter_biasstate_S5_R75_20b$eradication <- 0.75
smartepicenter_biasstate_S5_R75_20b$budget <- 20

path <- 'D:\\Chapter3\\results-space2\\smartepicenter\\S5_R75_40'
file_name = paste(path, 'bias_states.csv',sep = '/')
smartepicenter_biasstate_S5_R75_40 <- fread(file_name)
smartepicenter_biasstate_S5_R75_40 <- data.frame(smartepicenter_biasstate_S5_R75_40)[-1]

smartepicenter_biasstate_S5_R75_40$location <- 'smartepicenter'
smartepicenter_biasstate_S5_R75_40$detection <- 0.5
smartepicenter_biasstate_S5_R75_40$eradication <- 0.75
smartepicenter_biasstate_S5_R75_40$budget <- 40

path <- 'D:\\Chapter3\\results-space2\\smartepicenter\\S5_R75_40_b'
file_name = paste(path, 'bias_states.csv',sep = '/')
smartepicenter_biasstate_S5_R75_40b <- fread(file_name)
smartepicenter_biasstate_S5_R75_40b <- data.frame(smartepicenter_biasstate_S5_R75_40b)[-1]

smartepicenter_biasstate_S5_R75_40b$location <- 'smartepicenter'
smartepicenter_biasstate_S5_R75_40b$detection <- 0.5
smartepicenter_biasstate_S5_R75_40b$eradication <- 0.75
smartepicenter_biasstate_S5_R75_40b$budget <- 40

#
path <- 'D:\\Chapter3\\results-space2\\smartepicenter\\S5_R75_60'
file_name = paste(path, 'bias_states.csv',sep = '/')
smartepicenter_biasstate_S5_R75_60 <- fread(file_name)
smartepicenter_biasstate_S5_R75_60 <- data.frame(smartepicenter_biasstate_S5_R75_60)[-1]

smartepicenter_biasstate_S5_R75_60$location <- 'smartepicenter'
smartepicenter_biasstate_S5_R75_60$detection <- 0.5
smartepicenter_biasstate_S5_R75_60$eradication <- 0.75
smartepicenter_biasstate_S5_R75_60$budget <- 60

path <- 'D:\\Chapter3\\results-space2\\smartepicenter\\S5_R75_60_b'
file_name = paste(path, 'bias_states.csv',sep = '/')
smartepicenter_biasstate_S5_R75_60b <- fread(file_name)
smartepicenter_biasstate_S5_R75_60b <- data.frame(smartepicenter_biasstate_S5_R75_60b)[-1]

smartepicenter_biasstate_S5_R75_60b$location <- 'smartepicenter'
smartepicenter_biasstate_S5_R75_60b$detection <- 0.5
smartepicenter_biasstate_S5_R75_60b$eradication <- 0.75
smartepicenter_biasstate_S5_R75_60b$budget <- 60

bias_stateA_eps <- rbind(smartepicenter_biasstate_S5_R75_20, smartepicenter_biasstate_S5_R75_20b,
                         smartepicenter_biasstate_S5_R75_40,smartepicenter_biasstate_S5_R75_40b,
                         smartepicenter_biasstate_S5_R75_60,smartepicenter_biasstate_S5_R75_60b)


bias_stateA_eps$rates <- paste0('p = ', bias_stateA_eps$detection, ', e = ', bias_stateA_eps$eradication)
bias_stateA_eps$loc2 <- paste0(bias_stateA_eps$location, bias_stateA_eps$detection, bias_stateA_eps$eradication)
bias_stateA_eps$rates2 <- paste0('(', bias_stateA_eps$detection, ', ', bias_stateA_eps$eradication, ")")

colnames(bias_stateA_eps)[8] <- 'Budget'

bias_stateA_eps$data <- 'A'
bias_stateA_eps$loc2 <- paste0(bias_stateA_eps$location, bias_stateA_eps$detection, bias_stateA_eps$eradication, bias_stateA_eps$data)

#----------------
path <- 'D:\\Chapter3\\results-space2\\hstatebins\\S5_R75_20'
file_name = paste(path, 'bias_states.csv',sep = '/')
hstatebins_biasstate_S5_R75_20 <- fread(file_name)
hstatebins_biasstate_S5_R75_20 <- data.frame(hstatebins_biasstate_S5_R75_20)[-1]

hstatebins_biasstate_S5_R75_20$location <- 'hstatebins'
hstatebins_biasstate_S5_R75_20$detection <- 0.5
hstatebins_biasstate_S5_R75_20$eradication <- 0.75
hstatebins_biasstate_S5_R75_20$budget <- 20

path <- 'D:\\Chapter3\\results-space2\\hstatebins\\S5_R75_20_b'
file_name = paste(path, 'bias_states.csv',sep = '/')
hstatebins_biasstate_S5_R75_20b <- fread(file_name)
hstatebins_biasstate_S5_R75_20b <- data.frame(hstatebins_biasstate_S5_R75_20b)[-1]

hstatebins_biasstate_S5_R75_20b$location <- 'hstatebins'
hstatebins_biasstate_S5_R75_20b$detection <- 0.5
hstatebins_biasstate_S5_R75_20b$eradication <- 0.75
hstatebins_biasstate_S5_R75_20b$budget <- 20

path <- 'D:\\Chapter3\\results-space2\\hstatebins\\S5_R75_40'
file_name = paste(path, 'bias_states.csv',sep = '/')
hstatebins_biasstate_S5_R75_40 <- fread(file_name)
hstatebins_biasstate_S5_R75_40 <- data.frame(hstatebins_biasstate_S5_R75_40)[-1]

hstatebins_biasstate_S5_R75_40$location <- 'hstatebins'
hstatebins_biasstate_S5_R75_40$detection <- 0.5
hstatebins_biasstate_S5_R75_40$eradication <- 0.75
hstatebins_biasstate_S5_R75_40$budget <- 40

path <- 'D:\\Chapter3\\results-space2\\hstatebins\\S5_R75_40_b'
file_name = paste(path, 'bias_states.csv',sep = '/')
hstatebins_biasstate_S5_R75_40b <- fread(file_name)
hstatebins_biasstate_S5_R75_40b <- data.frame(hstatebins_biasstate_S5_R75_40b)[-1]

hstatebins_biasstate_S5_R75_40b$location <- 'hstatebins'
hstatebins_biasstate_S5_R75_40b$detection <- 0.5
hstatebins_biasstate_S5_R75_40b$eradication <- 0.75
hstatebins_biasstate_S5_R75_40b$budget <- 40

#
path <- 'D:\\Chapter3\\results-space2\\hstatebins\\S5_R75_60'
file_name = paste(path, 'bias_states.csv',sep = '/')
hstatebins_biasstate_S5_R75_60 <- fread(file_name)
hstatebins_biasstate_S5_R75_60 <- data.frame(hstatebins_biasstate_S5_R75_60)[-1]

hstatebins_biasstate_S5_R75_60$location <- 'hstatebins'
hstatebins_biasstate_S5_R75_60$detection <- 0.5
hstatebins_biasstate_S5_R75_60$eradication <- 0.75
hstatebins_biasstate_S5_R75_60$budget <- 60

path <- 'D:\\Chapter3\\results-space2\\hstatebins\\S5_R75_60_b'
file_name = paste(path, 'bias_states.csv',sep = '/')
hstatebins_biasstate_S5_R75_60b <- fread(file_name)
hstatebins_biasstate_S5_R75_60b <- data.frame(hstatebins_biasstate_S5_R75_60b)[-1]

hstatebins_biasstate_S5_R75_60b$location <- 'hstatebins'
hstatebins_biasstate_S5_R75_60b$detection <- 0.5
hstatebins_biasstate_S5_R75_60b$eradication <- 0.75
hstatebins_biasstate_S5_R75_60b$budget <- 60

bias_stateA_hstate <- rbind(hstatebins_biasstate_S5_R75_20, hstatebins_biasstate_S5_R75_20b,
                         hstatebins_biasstate_S5_R75_40,hstatebins_biasstate_S5_R75_40b,
                         hstatebins_biasstate_S5_R75_60,hstatebins_biasstate_S5_R75_60b)

bias_stateA_hstate$rates <- paste0('p = ', bias_stateA_hstate$detection, ', e = ', bias_stateA_hstate$eradication)
bias_stateA_hstate$loc2 <- paste0(bias_stateA_hstate$location, bias_stateA_hstate$detection, bias_stateA_hstate$eradication)
bias_stateA_hstate$rates2 <- paste0('(', bias_stateA_hstate$detection, ', ', bias_stateA_hstate$eradication, ")")

colnames(bias_stateA_hstate)[8] <- 'Budget'

bias_stateA_hstate$data <- 'A'
bias_stateA_hstate$loc2 <- paste0(bias_stateA_hstate$location, bias_stateA_hstate$detection, bias_stateA_hstate$eradication, bias_stateA_hstate$data)

#----------------
path <- 'D:\\Chapter3\\results-space2\\linear\\S5_R75_20'
file_name = paste(path, 'bias_states.csv',sep = '/')
linear_biasstate_S5_R75_20 <- fread(file_name)
linear_biasstate_S5_R75_20 <- data.frame(linear_biasstate_S5_R75_20)[-1]

linear_biasstate_S5_R75_20$location <- 'linear'
linear_biasstate_S5_R75_20$detection <- 0.5
linear_biasstate_S5_R75_20$eradication <- 0.75
linear_biasstate_S5_R75_20$budget <- 20

path <- 'D:\\Chapter3\\results-space2\\linear\\S5_R75_20_b'
file_name = paste(path, 'bias_states.csv',sep = '/')
linear_biasstate_S5_R75_20b <- fread(file_name)
linear_biasstate_S5_R75_20b <- data.frame(linear_biasstate_S5_R75_20b)[-1]

linear_biasstate_S5_R75_20b$location <- 'linear'
linear_biasstate_S5_R75_20b$detection <- 0.5
linear_biasstate_S5_R75_20b$eradication <- 0.75
linear_biasstate_S5_R75_20b$budget <- 20

path <- 'D:\\Chapter3\\results-space2\\linear\\S5_R75_40'
file_name = paste(path, 'bias_states.csv',sep = '/')
linear_biasstate_S5_R75_40 <- fread(file_name)
linear_biasstate_S5_R75_40 <- data.frame(linear_biasstate_S5_R75_40)[-1]

linear_biasstate_S5_R75_40$location <- 'linear'
linear_biasstate_S5_R75_40$detection <- 0.5
linear_biasstate_S5_R75_40$eradication <- 0.75
linear_biasstate_S5_R75_40$budget <- 40

path <- 'D:\\Chapter3\\results-space2\\linear\\S5_R75_40_b'
file_name = paste(path, 'bias_states.csv',sep = '/')
linear_biasstate_S5_R75_40b <- fread(file_name)
linear_biasstate_S5_R75_40b <- data.frame(linear_biasstate_S5_R75_40b)[-1]

linear_biasstate_S5_R75_40b$location <- 'linear'
linear_biasstate_S5_R75_40b$detection <- 0.5
linear_biasstate_S5_R75_40b$eradication <- 0.75
linear_biasstate_S5_R75_40b$budget <- 40

#
path <- 'D:\\Chapter3\\results-space2\\linear\\S5_R75_60'
file_name = paste(path, 'bias_states.csv',sep = '/')
linear_biasstate_S5_R75_60 <- fread(file_name)
linear_biasstate_S5_R75_60 <- data.frame(linear_biasstate_S5_R75_60)[-1]

linear_biasstate_S5_R75_60$location <- 'linear'
linear_biasstate_S5_R75_60$detection <- 0.5
linear_biasstate_S5_R75_60$eradication <- 0.75
linear_biasstate_S5_R75_60$budget <- 60

path <- 'D:\\Chapter3\\results-space2\\linear\\S5_R75_60_b'
file_name = paste(path, 'bias_states.csv',sep = '/')
linear_biasstate_S5_R75_60b <- fread(file_name)
linear_biasstate_S5_R75_60b <- data.frame(linear_biasstate_S5_R75_60b)[-1]

linear_biasstate_S5_R75_60b$location <- 'linear'
linear_biasstate_S5_R75_60b$detection <- 0.5
linear_biasstate_S5_R75_60b$eradication <- 0.75
linear_biasstate_S5_R75_60b$budget <- 60

bias_stateA_lin <- rbind(linear_biasstate_S5_R75_20, linear_biasstate_S5_R75_20b,
                         linear_biasstate_S5_R75_40,linear_biasstate_S5_R75_40b,
                         linear_biasstate_S5_R75_60,linear_biasstate_S5_R75_60b)

bias_stateA_lin$rates <- paste0('p = ', bias_stateA_lin$detection, ', e = ', bias_stateA_lin$eradication)
bias_stateA_lin$loc2 <- paste0(bias_stateA_lin$location, bias_stateA_lin$detection, bias_stateA_lin$eradication)
bias_stateA_lin$rates2 <- paste0('(', bias_stateA_lin$detection, ', ', bias_stateA_lin$eradication, ")")

colnames(bias_stateA_lin)[8] <- 'Budget'

bias_stateA_lin$data <- 'A'
bias_stateA_lin$loc2 <- paste0(bias_stateA_lin$location, bias_stateA_lin$detection, bias_stateA_lin$eradication, bias_stateA_lin$data)


#----------------

bias_stateAC <- bias_stateAC 

bias_stateA <- rbind(bias_stateA_eps, bias_stateA_hstate, bias_stateA_lin)
bias_states<- rbind(bias_stateAC, bias_stateA)

bias_states %>% 
  ggplot(aes(x = loc2, y = rel.bias, fill = rates2, color =data,
             group = interaction(location, rates2, data)))+
  geom_boxplot() +
  geom_hline(yintercept = 0, linetype = 2) + 
  stat_summary(fun.y = mean, geom = "errorbar",
               aes(ymax = after_stat(y), ymin = after_stat(y),
                   group = interaction(location, rates)),
               width = .75, color = "black", linewidth = 1)+ 
  scale_x_discrete(breaks = c("smartepicenter0.50.75A",
                              "smartepicenter0.50.75AC",
                              "hstate0.50.75A",
                              "hstate0.50.75AC",
                              "linear0.50.75A",
                              "linear0.50.75AC"),
                   labels=c(
                     "smartepicenter0.50.75A" = "Epicenter",
                     "smartepicenter0.50.75AC" = "Epicenter A + C",
                     "hstate0.50.75A" = "High invasion",
                     "hstate0.50.75AC" = "High invasion A + C",
                     "linear0.50.75A" = "Linear",
                     "linear0.50.75AC" = "Linear A + C"))+
  
  scale_fill_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                    values = colors) +
  scale_color_manual(name = "Data",
                     values = colors2, 
                     labels = c('A', 'A + C'))+
  
  xlab("Site prioritization")+
  ylab("State relative bias")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget, nrow = 3, labeller = label_both)

budget20_comp <- bias_states %>% 
  filter(Budget == 20) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias),
            max_c = max(rel.bias),
            upper = quantile(rel.bias, 0.95),
            low = quantile(rel.bias, 0.05),
            min = min(rel.bias))

budget20_comp

budget40_comp <- bias_states %>% 
  filter(Budget == 40) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias),
            max_c = max(rel.bias),
            upper = quantile(rel.bias, 0.95),
            low = quantile(rel.bias, 0.05),
            min = min(rel.bias))

budget40_comp

budget60_comp <- bias_states %>% 
  filter(Budget == 60) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias),
            max_c = max(rel.bias),
            upper = quantile(rel.bias, 0.95),
            low = quantile(rel.bias, 0.01),
            min = round(min(rel.bias),4))

budget60_comp

#### BIAS RMSE ####
path <- 'D:\\Chapter3\\results-datboth-space2'
file_name = paste(path, 'rmse_state.csv',sep = '/')
rmse_state <- fread(file_name)
rmse_state <- data.frame(rmse_state)

rmse_state$rates <- paste0('p = ', rmse_state$detection, ', e = ', rmse_state$eradication)


rmse_state$loc2 <- paste0(rmse_state$location, rmse_state$detection, rmse_state$eradication)
rmse_state$rates2 <- paste0('(', rmse_state$detection, ', ', rmse_state$eradication, ")")

colnames(rmse_state)[8] <- 'Budget'

rmse_state$data <- 'AC'
rmse_state$loc2 <- paste0(rmse_state$location, rmse_state$detection, rmse_state$eradication, rmse_state$data)
rmse_stateAC <- rmse_state

##### Smart epicenter comparison Rel. bias ####
path <- 'D:\\Chapter3\\results-space2\\smartepicenter\\S5_R75_20'
file_name = paste(path, 'states.csv',sep = '/')
state_S5_R75_20 <- fread(file_name)
state_S5_R75_20 <- data.frame(state_S5_R75_20)[-1]

state_S5_R75_20$location <- 'smartepicenter'
state_S5_R75_20$detection <- 0.5
state_S5_R75_20$eradication <- 0.75
state_S5_R75_20$budget <- 20

path <- 'D:\\Chapter3\\results-space2\\smartepicenter\\S5_R75_20_b'
file_name = paste(path, 'states.csv',sep = '/')
state_S5_R75_20b <- fread(file_name)
state_S5_R75_20b <- data.frame(state_S5_R75_20b)[-1]

state_S5_R75_20b$location <- 'smartepicenter'
state_S5_R75_20b$detection <- 0.5
state_S5_R75_20b$eradication <- 0.75
state_S5_R75_20b$budget <- 20

path <- 'D:\\Chapter3\\results-space2\\smartepicenter\\S5_R75_40'
file_name = paste(path, 'states.csv',sep = '/')
state_S5_R75_40 <- fread(file_name)
state_S5_R75_40 <- data.frame(state_S5_R75_40)[-1]

state_S5_R75_40$location <- 'smartepicenter'
state_S5_R75_40$detection <- 0.5
state_S5_R75_40$eradication <- 0.75
state_S5_R75_40$budget <- 40

path <- 'D:\\Chapter3\\results-space2\\smartepicenter\\S5_R75_40_b'
file_name = paste(path, 'states.csv',sep = '/')
state_S5_R75_40b <- fread(file_name)
state_S5_R75_40b <- data.frame(state_S5_R75_40b)[-1]

state_S5_R75_40b$location <- 'smartepicenter'
state_S5_R75_40b$detection <- 0.5
state_S5_R75_40b$eradication <- 0.75
state_S5_R75_40b$budget <- 40

path <- 'D:\\Chapter3\\results-space2\\smartepicenter\\S5_R75_60'
file_name = paste(path, 'states.csv',sep = '/')
state_S5_R75_60 <- fread(file_name)
state_S5_R75_60 <- data.frame(state_S5_R75_60)[-1]

state_S5_R75_60$location <- 'smartepicenter'
state_S5_R75_60$detection <- 0.5
state_S5_R75_60$eradication <- 0.75
state_S5_R75_60$budget <- 60

path <- 'D:\\Chapter3\\results-space2\\smartepicenter\\S5_R75_60_b'
file_name = paste(path, 'states.csv',sep = '/')
state_S5_R75_60b <- fread(file_name)
state_S5_R75_60b <- data.frame(state_S5_R75_60b)[-1]

state_S5_R75_60b$location <- 'smartepicenter'
state_S5_R75_60b$detection <- 0.5
state_S5_R75_60b$eradication <- 0.75
state_S5_R75_60b$budget <- 60

state <- rbind(state_S5_R75_20, state_S5_R75_20b, state_S5_R75_40, state_S5_R75_40b,
               state_S5_R75_60,state_S5_R75_60b)

state_est_week5 <- state
state_est_week5$rmse <- sqrt((state_est_week5$mean - state_est_week5$truth)^2)


rmse_stateA_eps <- state_est_week5


rmse_stateA_eps$rates <- paste0('p = ', rmse_stateA_eps$detection, ', e = ', rmse_stateA_eps$eradication)


rmse_stateA_eps$loc2 <- paste0(rmse_stateA_eps$location, rmse_stateA_eps$detection, rmse_stateA_eps$eradication)
rmse_stateA_eps$rates2 <- paste0('(', rmse_stateA_eps$detection, ', ', rmse_stateA_eps$eradication, ")")

colnames(rmse_stateA_eps)[8] <- 'Budget'

rmse_stateA_eps$data <- 'A'
rmse_stateA_eps$loc2 <- paste0(rmse_stateA_eps$location, rmse_stateA_eps$detection, rmse_stateA_eps$eradication, rmse_stateA_eps$data)

#----------------

rmse_stateAC_eps <- rmse_stateAC %>% filter(location == 'smartepicenter')

rmse_state_eps <- rbind(rmse_stateAC_eps, rmse_stateA_eps)

rmse_state_eps %>% 
  ggplot(aes(x = loc2, y = rmse, fill = rates2, color =data,
             group = interaction(location, rates2, data)))+
  geom_boxplot() +
  geom_hline(yintercept = 0, linetype = 2) + 
  stat_summary(fun.y = mean, geom = "errorbar",
               aes(ymax = after_stat(y), ymin = after_stat(y),
                   group = interaction(location, rates)),
               width = .75, color = "black", linewidth = 1)+ 
  scale_x_discrete(breaks = c("smartepicenter0.50.75A",
                              "smartepicenter0.50.75AC"),
                   labels=c(
                     "smartepicenter0.50.75A" = "Epicenter",
                     "smartepicenter0.50.75AC" = "Epicenter A + C"))+
  
  scale_fill_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                    values = colors) +
  scale_color_manual(name = "Data",
                     values = colors2, 
                     labels = c('A', 'A + C'))+
  
  xlab("Site prioritization")+
  ylab("State relative bias")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~budget, nrow = 3, labeller = label_both)

budget20_epscomp <- rmse_state_eps %>% 
  filter(budget == 20) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rmse),
            max_c = max(rmse),
            upper = quantile(rmse, 0.95))

budget20_epscomp

budget40_epscomp <- rmse_state_eps %>% 
  filter(budget == 40) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rmse),
            max_c = max(rmse),
            upper = quantile(rmse, 0.97))

budget40_epscomp

budget60_epscomp <- rmse_state_eps %>% 
  filter(budget == 60) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rmse),
            max_c = max(rmse),
            upper = quantile(rmse, 0.95),
            min = quantile(rmse, 0.05))

budget60_epscomp


####################################################
##### Bias state- time ####
bias_state_years <- bias_state %>%
  group_by(location, year, rates, rates2, Budget) %>%
  summarise(mean_b = mean(rel.bias),
            lower = quantile(rel.bias, 0.05),
            upper = quantile(rel.bias, 0.95))

colnames(bias_state_years)[c(1,5)] <- c("Prioritization", "Budget")

bias_state_years$Prioritization[bias_state_years$Prioritization == "smartepicenter"] <- 'smartepicenter'
bias_state_years$Prioritization[bias_state_years$Prioritization == "linear"] <- 'Linear'
bias_state_years$Prioritization[bias_state_years$Prioritization == "hstate"] <- 'High invasion'

ggplot(bias_state_years, aes(x = year, y = mean_b, ymin = lower, ymax = upper, color = rates2))+
  geom_point()+
  geom_errorbar()+
  geom_hline(yintercept = 0, linetype = 2) + 
  scale_x_continuous(breaks = c(2,4,6,8,10)) +
  scale_color_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                     values = colors) +
  ylab("State relative bias ")+
  xlab("Year")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget + Prioritization, nrow = 3, labeller = label_both)

#---- SUBSET ----#

bias_state_yearssub <- bias_state_years %>% filter(rates == "p = 0.75, e = 0.5" | rates == "p = 0.25, e = 0.75"|
                                                   rates == "p = 0.75, e = 0.75" | rates == "p = 0.5, e = 0.75")



colors_sub <- colors[c(2,4,5,6)]

ggplot(bias_state_yearssub, aes(x = year, y = mean_b, ymin = lower, ymax = upper, color = rates2))+
  geom_point()+
  geom_errorbar()+
  geom_hline(yintercept = 0, linetype = 2) + 
  scale_x_continuous(breaks = c(2,4,6,8,10)) +
  scale_color_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                    values = colors_sub) +
  ylab("State relative bias ")+
  xlab("Year")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget + Prioritization, nrow = 3, labeller = label_both)


#### Bias params ####
file_name = paste(path, 'bias_params.csv',sep = '/')
bias_param <- fread(file_name)
bias_param <- data.frame(bias_param)

bias_param$rates <- paste0('p = ', bias_param$detection, ', e = ', bias_param$eradication)


bias_param$loc2 <- paste0(bias_param$location, bias_param$detection, bias_param$eradication)

###### Detection bias ####
bias_param_detect  <- bias_param %>% filter(param %in% c("B0.p.h", "B0.p.h", "B1.p.l", "B1.p.h"))

budget20_bias_param_detect <- bias_param_detect %>% 
  filter(budget == 20) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias))

budget20_bias_param_detect

budget40_bias_param_detect <- bias_param_detect %>% 
  filter(budget == 40) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias))

budget40_bias_param_detect

budget60_bias_param_detect <- bias_param_detect %>% 
  filter(budget == 60) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias))

budget60_bias_param_detect

###### Time #######
bias_param_detect$rates2 <- paste0('(', bias_param_detect$detection, ', ', bias_param_detect$eradication, ")")

bias_param_detect_years <- bias_param_detect %>%
  group_by(location, year, rates, rates2, budget) %>%
  summarise(mean_b = mean(rel.bias),
            lower = quantile(rel.bias, 0.05),
            upper = quantile(rel.bias, 0.95))

colnames(bias_param_detect_years)[c(1,5)] <- c("Prioritization", "Budget")

bias_param_detect_years$Prioritization[bias_param_detect_years$Prioritization == 'smartepicenter'] <- 'smartepicenter'
bias_param_detect_years$Prioritization[bias_param_detect_years$Prioritization == 'hstate'] <- 'High invasion'
bias_param_detect_years$Prioritization[bias_param_detect_years$Prioritization == 'linear'] <- 'Linear'

ggplot(bias_param_detect_years, 
       aes(x = year, y = mean_b, ymin = lower, ymax = upper, color = rates2))+
  geom_point()+
  geom_errorbar()+
  geom_hline(yintercept = 0, linetype = 2) + 
  scale_x_continuous(breaks = c(2,4,6,8, 10)) +
  scale_color_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                     values = colors) +
  ylab(paste0('p parameters relative bias'))+
  xlab("Year")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget + Prioritization, nrow = 3, labeller = label_both, scales = "free")

#----- SUBSET ----#

bias_param_detect_yearssub <- bias_param_detect_years %>% filter(rates == "p = 0.5, e = 0.75" | 
                                                                   rates == "p = 0.25, e = 0.5"|
                                                                   rates == "p = 0.75, e = 0.5"|
                                                                   rates == "p = 0.25, e = 0.75")

colors_sub <- colors[c(1,2,4,5)]

ggplot(bias_param_detect_yearssub, 
       aes(x = year, y = mean_b, ymin = lower, ymax = upper, color = rates2))+
  geom_point()+
  geom_errorbar()+
  geom_hline(yintercept = 0, linetype = 2) + 
  scale_x_continuous(breaks = c(2,4,6,8, 10)) +
  scale_color_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                     values = colors_sub) +
  ylab(paste0('p parameters relative bias'))+
  xlab("Year")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget + Prioritization, nrow = 3, labeller = label_both, scales = "free")

###### Eradication bias ####
bias_param_eps  <- bias_param %>% filter(param %in% c("B0.eps.h", "B0.eps.h", "B1.eps.l", "B1.eps.h"))

budget20_bias_param_eps <- bias_param_eps %>% 
  filter(budget == 20) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias))

budget20_bias_param_eps

budget40_bias_param_eps <- bias_param_eps %>% 
  filter(budget == 40) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias))

budget40_bias_param_eps

budget60_bias_param_eps <- bias_param_eps %>% 
  filter(budget == 60) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias))

budget60_bias_param_eps

###### Time #######
bias_param_eps$rates2 <- paste0('(', bias_param_eps$detection, ', ', bias_param_eps$eradication, ")")

bias_param_eps_years <- bias_param_eps %>%
  group_by(location, year, rates, rates2, budget) %>%
  summarise(mean_b = mean(rel.bias),
            lower = quantile(rel.bias, 0.05),
            upper = quantile(rel.bias, 0.95))

colnames(bias_param_eps_years)[c(1,5)] <- c("Prioritization", "Budget")

bias_param_eps_years$Prioritization[bias_param_eps_years$Prioritization == 'smartepicenter'] <- 'smartepicenter'
bias_param_eps_years$Prioritization[bias_param_eps_years$Prioritization == 'hstate'] <- 'High invasion'
bias_param_eps_years$Prioritization[bias_param_eps_years$Prioritization == 'linear'] <- 'Linear'

ggplot(bias_param_eps_years, 
       aes(x = year, y = mean_b, ymin = lower, ymax = upper, color = rates2))+
  geom_point()+
  geom_errorbar()+
  geom_hline(yintercept = 0, linetype = 2) + 
  scale_x_continuous(breaks = c(2,4,6,8, 10)) +
  scale_color_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                     values = colors) +
  ylab(paste0('\u03F5 parameters relative bias'))+
  xlab("Year")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget + Prioritization, nrow = 3, labeller = label_both, scales = "free")

#----- SUBSET ----#

bias_param_eps_yearssub <- bias_param_eps_years %>% filter(rates == "p = 0.5, e = 0.75" | rates == "p = 0.25, e = 0.75" |
                                                             rates == "p = 0.75, e = 0.75")

colors_sub <- colors[c(2,4,6)]

ggplot(bias_param_eps_yearssub, 
       aes(x = year, y = mean_b, ymin = lower, ymax = upper, color = rates2))+
  geom_point()+
  geom_errorbar()+
  geom_hline(yintercept = 0, linetype = 2) + 
  scale_x_continuous(breaks = c(2,4,6,8, 10)) +
  scale_color_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                     values = colors_sub) +
  ylab(paste0('\u03F5 parameters relative bias'))+
  xlab("Year")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget + Prioritization, nrow = 3, labeller = label_both, scales = "free")

