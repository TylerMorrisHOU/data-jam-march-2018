library('ggmap')

# reads the dataset into a series of R tables

alldata <- readRDS('txdot_cris_crashdata_201601_201802.rds')

crashes <- alldata$crashes
units <- alldata$units
persons <- alldata$persons

rm(alldata)

# identifies transit bus crashes in the list of crashes

buscrashes <- subset(crashes, 
                     crashes$Crash.ID %in% units$Crash.ID[(units$Bus.Type == 'Transit') == TRUE])

# builds coordinate map of transit bus crashes

qmap('houston') +
  geom_density2d(data = buscrashes,
                 aes(Longitude, Latitude))

# separates out weekday crashes

crashes$weekday <- (crashes$Day.of.Week != 'Saturday' & crashes$Day.of.Week != 'Sunday')

# builds coordinate maps of crashes on weekdays and weekends

qmap('houston') + 
  geom_density2d(data = crashes[crashes$weekday == TRUE,],
                 aes(Longitude, Latitude)) + 
  stat_density2d(data = crashes[crashes$weekday == TRUE,], 
                 aes(Longitude, Latitude, 
                     fill = ..level..,
                     alpha = ..level..),
                 size = 0.3,
                 geom = 'polygon') +
  scale_fill_gradient(low = 'green',
                      high = 'red') +
  scale_alpha(range = c(0.25, 0.5),
              guide = FALSE) +
  ggtitle("Weekday Crashes")


qmap('houston') + 
  geom_density2d(data = crashes[crashes$weekday == FALSE,],
                 aes(Longitude, Latitude)) + 
  stat_density2d(data = crashes[crashes$weekday == FALSE,], 
                 aes(Longitude, Latitude, 
                     fill = ..level..,
                     alpha = ..level..),
                 size = 0.9,
                 geom = 'polygon') +
  scale_fill_gradient(low = 'green',
                      high = 'red') +
  scale_alpha(range = c(0.25, 0.5),
              guide = FALSE) + 
  ggtitle("Weekend Crashes")

# map of fatal crashes

qmap('houston') + 
  geom_density2d(data = crashes[crashes$Crash.Death.Count > 0,],
                 aes(Longitude, Latitude)) + 
  stat_density2d(data = crashes[crashes$Crash.Death.Count > 0,], 
                 aes(Longitude, Latitude, 
                     fill = ..level..,
                     alpha = ..level..),
                 geom = 'polygon') +
  scale_fill_gradient(low = 'green',
                      high = 'red') +
  scale_alpha(range = c(0.25, 0.5),
              guide = FALSE) + 
  ggtitle("fatal Crashes")

# plot of crash severity

qmap('houston') +
  geom_point(data = crashes[crashes$Crash.Severity != 'Unknown' & 
                              crashes$Crash.Severity != 'Not Injured',],
             aes(Longitude, Latitude,
                 colour = Crash.Severity),
             size = 0.1)

# plot of crash severity based on weekend status


qmap('houston') +
  geom_point(data = crashes[crashes$Crash.Severity != 'Unknown' & 
                              crashes$Crash.Severity != 'Not Injured' &
                              crashes$weekday == TRUE,],
             aes(Longitude, Latitude,
                 colour = Crash.Severity),
             size = 0.1) +
  ggtitle("Weekday Crash Severity Where Injuries Happened")


qmap('houston') +
  geom_point(data = crashes[crashes$Crash.Severity != 'Unknown' & 
                              crashes$Crash.Severity != 'Not Injured' &
                              crashes$weekday == FALSE,],
             aes(Longitude, Latitude,
                 colour = Crash.Severity),
             size = 0.1) + 
  ggtitle('Weekend Crash Severity Where Injuries Happened')


# regression model that predicts the probability that a crash will be fatal
# based on crash factors

model <- glm(formula = (Crash.Death.Count > 0) ~ 
               Adjusted.Average.Daily.Traffic.Amount + 
               Construction.Zone.Flag + 
               (Adjusted.Percentage.of.Average.Daily.Traffic.For.Trucks * Adjusted.Average.Daily.Traffic.Amount) +
               Median.Width.plus.Both.Inside.Shoulders +
               Speed.Limit +
               Toll.Road.Flag,
             family = "binomial",
             data = crashes)

crashes$predict <- predict(model, crashes, type = "response")

qmap('houston') + 
  geom_point(data = crashes[crashes$predict > 0,],
             aes(Longitude, Latitude,
                 colour = predict),
             size = predict) +
  scale_colour_gradient(low = 'green',
                      high = 'red') +
  ggtitle('Roadways with Highest Fatality Probability')

summary(model)