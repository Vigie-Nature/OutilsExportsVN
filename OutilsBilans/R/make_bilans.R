# Render tous les bilans des exports

# Lire les variables d'environnement
readRenviron(".env")

# Appeler les fonction du package hackathon.vn
# Pour l'instant via chemin relatif en local

# Sourcer les differents scripts du directory R, dont les libraires R
invisible(lapply(file.path("../hackathon.vn/R", 
                           dir("../hackathon.vn/R")), 
                 source))

# list all export files on server 
exports_files <- list_ftp_files()

# select smallest files for test 
exports_files <- c("export_qubs_aspifaune.csv", "export_vne_alamer.csv")

setwd("OutilsBilans/R/")
# render qmd
for (i in seq_along(exports_files)){
  quarto::quarto_render("template_bilan_vn.qmd",
                        output_file = paste0("bilan_", exports_files[i], ".html"), 
                        execute_params = list(exports_name = exports_files[i]))
}

setwd("../..")
