# Chapter 6: Time Series
# Machine Learning in Cardiology: A Practical R-Based Approach
# Runnable top to bottom. All data are simulated in the script.

# --------------------------------------------------------------------------
# Time-Series Feature Extraction from ECG Signals
# --------------------------------------------------------------------------

library(pracma)
library(ggplot2)

# Generate synthetic ECG
Fs <- 250
tbeat <- seq(0,1,length.out=Fs)
beat <- 0.15*dnorm(tbeat,0.2,0.02) - 0.15*dnorm(tbeat,0.45,0.01) +
  2*dnorm(tbeat,0.5,0.01) - 0.25*dnorm(tbeat,0.52,0.01) +
  0.3*dnorm(tbeat,0.7,0.03)

ecg <- rep(beat,5)
t <- seq(0,5,length.out=length(ecg))

# Find peaks
pks <- findpeaks(ecg, thresh=0.1, minpeakdistance=20, minpeakheight=0.5)
ix <- if(!is.null(pks)) pks[,2] else numeric(0)

ggplot(data.frame(t,ecg), aes(t,ecg)) +
  geom_line() +
  geom_point(data=data.frame(t=t[ix],ecg=ecg[ix]), aes(t,ecg), color="red") +
  theme_minimal()
