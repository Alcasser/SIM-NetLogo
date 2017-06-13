# install.packages("rstudioapi") # run this if it's your first time using it to install
library(rstudioapi) # load it
# the following line is for getting the path of your current open file
current_path <- getActiveDocumentContext()$path 
# The next line set the working directory to the relevant one:
setwd(dirname(current_path ))

# Importem les dades de la prova pilot
library(readxl)
ProvaPilot <- read_excel("ProvaPilot-table.xlsx", 
col_types = c("blank", "blank", "blank", "blank", "numeric"))
ProvaPilot <- ProvaPilot$`mean-waiting-time / ticks-per-minute`

# Resum de les dades
summary(ProvaPilot)

sink("Resultat nombre de rèpliques.txt")
# Nombre de rèpliques
n <- length(ProvaPilot)
cat("Nombre de rèpliques prova pilot =", , "\n")
# Mitjana
X <- mean(ProvaPilot)
cat("Mitjana prova pilot =", X, "\n")
# Desviació
S <- sd(ProvaPilot)
cat("Desviació prova pilot =", S, "\n\n")

# Semi-amplada de l'interval de confiança de la prova pilot
h <- qt(0.975, n-1) * S/sqrt(n)
cat("Semi-amplada de l'interval de confiança de la prova pilot =", h, "\n")

# Interval de confiança del 95%
IC <- c(X - h, X + h)
cat("Interval de confiança (α = 0.05) = [", IC[1], ",", IC[2], "]", "\n")

# Semi-interval de confiança desitjat (95% de confiança)
H <- 0.05 * X
cat("Semi-amplada de l'interval de confiança desitjat (95% de confiança) =", H, "\n")

# Nombre de rèpliques necessàries
N <- n * (h/H)^2
cat("\nNombre de rèpliques necessàries =", N, "->", ceiling(N), "\n")

sink()