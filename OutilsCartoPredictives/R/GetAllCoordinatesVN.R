readRenviron(".env") #recup des variables d'environnement, notamment accès ftp
lapply(file.path("../hackathon.vn/R",dir("../hackathon.vn/R")),source) #source les fonctions du protopackage VN
Sys.getenv("FTP_USER") #lit les variables d'environnement

liste_fichiers <- list_ftp_files() #recup la liste des fichiers exports présents sur le ftpo=
print(liste_fichiers)

# Initialise une liste pour stocker les coordonnées de chaque fichier
CoordsList=list()
for (t in 1:length(liste_fichiers)){
  print(liste_fichiers[t])
  Df_vn=download_from_ftp(nom_fichier=liste_fichiers[t])
  
  if("session_date" %in% colnames(Df_vn)){
    #on garde seulement une donnée par session pour alléger le process
    Df_vn=unique(as.data.table(Df_vn,by="session_id"))
    #a faire plus tard éventuellement, retirer les colonnes inutiles pour aussi alléger le process 
    #(mais pour l'instant on garde pour éventuel debug d'export foireux sur les dates ou les coordonnées)
    # Trie les données par date croissante
    Df_vn=Df_vn[order(as.Date(Df_vn$session_date)),]
    # plot(as.Date(Df_vn$session_date))
    # plot(year(as.Date(Df_vn$session_date)))
    # plot(year((Df_vn$session_date)))
    
    # Extrait les coordonnées uniques et calcule l'année minimale d'observation
    DataCoord=unique(as.data.table(Df_vn),by=c("longitude","latitude"))
    DataCoord$Annee_min=year(DataCoord$session_date)
    #plot(DataCoord$Annee_min)
    # Garde seulement les colonnes utiles
    DataCoord=subset(DataCoord,select=c("longitude","latitude","Annee_min"))
    
    # Trie les données par date décroissante pour calculer l'année maximale
    Df_vn=Df_vn[order(Df_vn$session_date,decreasing=T),]
    DataCoord2=unique(as.data.table(Df_vn),by=c("longitude","latitude"))
    # Associe les coordonnées pour calculer l'année maximale
    matchCoord=match(paste(DataCoord$longitude,DataCoord$latitude),paste(DataCoord2$longitude,DataCoord2$latitude))
    DataCoord$Annee_max=year(DataCoord2$session_date[matchCoord])
    print(summary(DataCoord$Annee_max-DataCoord$Annee_min)) #check pour debug
  }else{ # Si pas de colonne session_date, extrait juste les coordonnées
    DataCoord=unique(as.data.table(Df_vn),by=c("longitude","latitude"))
    DataCoord=subset(DataCoord,select=c("longitude","latitude"))
    DataCoord$Annee_min=NA
    DataCoord$Annee_max=NA
  }
  
  # Extrait le nom de l'observatoire à partir du nom de fichier
  Observatoire=gsub("export_","",liste_fichiers[t])
  Observatoire=gsub(".csv","",Observatoire)
  print(Observatoire)
  print(nrow(DataCoord))
  
  # Ajoute le nom de l'observatoire et stocke le résultat
  DataCoord$Observatoire=Observatoire
  CoordsList[[t]]=DataCoord
}

AllCoords=rbindlist(CoordsList) #convertit la liste en data.table
fwrite(AllCoords,"OutilsCartoPredictives/output/AllCoordinates.csv",sep=";")

