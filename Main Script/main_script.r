library(rgeoboundaries)
library(sf)
library(raster)
library(rivnet)
library(OCNet)
library(elevatr)
library(terra)
library(rgdal)
Sys.setenv(TAUDEM_PATH = "/usr/local/taudem")
Sys.setenv(TAUDEM_MPI = "mpich")
Sys.setenv(PATH = paste0("/opt/homebrew/bin:", Sys.getenv("PATH")))


#Step 1:

x <- c(-3.722283741, -1.7150597578)
y <- c(55.089218751, 55.9647141155)
d <- data.frame(lon = x, lat = y)

elevation_data <- get_elev_raster(locations = d, z = 6,
                                prj = "EPSG:4326", src = "aws",
                                verbose = TRUE)
                            
river_tweed <- extract_river(outlet = c(-1.9906393249046541, 55.76440860578569),
                            DEM = elevation_data)
plot(river_tweed) #This creates river_tweed_plot.jpg 
saveRDS(river_tweed, file = "river_tweed.rds")

thr <- find_area_threshold_OCN(river_tweed)

par(mai = c(1, 1, 1, 1))
plot(thr$thrValues[thr$nNodesAG > 0] / river_tweed $CM$A,
thr$nNodesAG[thr$nNodesAG > 0], log = "xy",
xlab = "Relative area threshold", ylab = "Number of AG nodes")
par(old.par)

river_tweed_ag <- aggregate_OCN(river_tweed, thrA = 0.005,
                    streamOrderType = "Shreve",
                    maxReachLength = Inf,
                    breakpoints = NULL, displayUpdates = TRUE)
plot(river_tweed_ag) #Likewise, this creates tweed_agg.png.

#Step 2:
data <- c(130.06679, 150)
type <- c("Q", "w")
node <- c(5, 5)
num <- "3" #1,2,3 or 4

csv_data <- read.csv(paste0("/Users/seb/R_rivers/Tweed data/Scenario ", num, "/scenario", num, "_yearly.csv"))


for (i in 1:nrow(csv_data)) {
  data[1] <- csv_data$new_data[i]

  x <- data.frame(data = data, type = type, node = node)

  river <- hydro_river(x, river_tweed_ag)

  filename <- paste0("scen", num, "river_", i, ".rds")
  saveRDS(river, filename)
}



#Step 3:
dir <- paste0("/Users/seb/R_rivers/Scenario ", num, " rivers")

files <- list.files(path = dir, pattern = paste0("scen", num, "river_\\d+\\.rds")) # nolint

values1 <- numeric(length = length(files))

#Step 4:
for (i in 1:length(files)) {
  
  river <- readRDS(paste0(dir, "/", files[i]))

  value <- river$AG$discharge[53]

  values1[i] <- value
}

plot(1:length(files), values1, type = "o", xlab = "years", ylab = "Yearly mean discharge at node 53")

#Failed attempt to overlay all nodes discharge, did not work
dir <- paste0("/Users/seb/R_rivers/DATA/Scenario ", num, " rivers")

files <- list.files(path = dir, pattern = paste0("scen", num, "river_\\d+\\.rds")) # nolint

values <- matrix(nrow = length(files), ncol = 72)

for (i in 1:length(files)) {
  river <- readRDS(paste0(dir, "/", files[i]))

  values[i, ] <- river$AG$discharge[1:72]
}

plot(1:72, values[1,], type = "o", xlab = "Index", ylab = "Yearly mean discharge at node")

for (i in 2:length(files)) {
  lines(1:72, values[i,], type = "o", col = i)
}
