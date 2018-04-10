

install.packages("RSQLite")
library("RSQLite")

dbDisconnect(con)
file.remove("liens.db")

con<-dbConnect(SQLite(),dbname="liens.db")

#Cr?ation des trois tables
etudiants <- "
CREATE TABLE etudiants(
  prenomnom VARCHAR,
  Programme VARCHAR,
  Coop BOLEAN,
  Tech BOLEAN,
  Session_depart CHAR(3),
  PRIMARY KEY (prenomnom)
);"
dbSendQuery(con, etudiants)


cours <- "
CREATE TABLE cours(
  Sigle CHAR,
  Ponderation VARCHAR,
  Nb_credits CHAR(1),
  Faculte VARCHAR,
  Departement VARCHAR,
  Labo BOLEAN,
  Terrain BOLEAN,
  Redaction BOLEAN,
  PRIMARY KEY (Sigle)
);"
dbSendQuery(con, cours)


liens <-"
CREATE TABLE liens (
  id VARCHAR,
  Etudiant_1 VARCHAR, 
  Etudiant_2 VARCHAR,
  Sigle CHAR (6),
  Session CHAR(3),
PRIMARY KEY (id)
FOREIGN KEY (Etudiant_1)REFERENCES
etudiants (prenomnom)
FOREIGN KEY (Etudiant_2)REFERENCES
etudiants (prenomnom)
FOREIGN KEY (Sigle)REFERENCES
cours (Sigle)
);"
dbSendQuery(con, liens)
dbListTables(con)


#Lecture des fichiers CSV 
bd_etudiants <- read.csv2(file='etudiants.csv',stringsAsFactors=FALSE, sep = ";", header = TRUE)
bd_cours <- read.csv2(file='cours.csv',stringsAsFactors = FALSE, header = TRUE)
bd_liens <- read.csv(file='liens.csv',stringsAsFactors = FALSE, sep = ";", header = TRUE)
#Correction de la BD liens pour enlever tous les duplicatas
bd_liens <- bd_liens[!duplicated(bd_liens),]

#Enregistrement des donn?es
dbWriteTable(con,append=TRUE,name="etudiants",value=bd_etudiants, row.names=FALSE, header = TRUE)
dbWriteTable(con,append=TRUE,name="cours",value=bd_cours, row.names=FALSE, header = TRUE)
dbWriteTable(con,append=TRUE,name="liens",value=bd_liens, row.names=FALSE, header = TRUE)

#Requete 1 : nombre liens tottaux par session 
req_nb_liens <- "
SELECT count(id) As nb_liens, Session
FROM liens 
GROUP BY Session
ORDER BY 
  case Session
  when 'H16' then 1
  when 'A16' then 2
  when 'H17' then 3
  when 'E17' then 4
  when 'A17' then 5
  when 'H18' then 6
  end
;"
liens_session <- dbGetQuery(con, req_nb_liens)
liens_session
#Essai de figure (a faire)
mat_ls<-as.numeric(liens_session$nb_liens)
hist(mat_ls ~ liens_session$Session)

#Requête nb liens par étudiant 
req_nbl <- "
SELECT count(id) AS nb_liens, Etudiant_1
FROM liens
GROUP BY Etudiant_1;"
nbl_etud <- dbGetQuery(con,req_nbl)
head(nbl_etud)

#Requete pour compter le nombre de liens par paire
req_paires <- "SELECT Etudiant_1, count(paires) 
AS nb_liens FROM (
SELECT DISTINCT Etudiant_1, Etudiant_2
AS paires FROM liens)
AS nb_liens_paire
GROUP BY Etudiant_1
;"
paires <- dbGetQuery(con, req_paires)
head(paires)


# Test steve
#Requete 1 : nombre liens tottaux par session 
req_nb_liens <- "
SELECT id, Session
FROM liens;"

nb_liens <- dbGetQuery(con, req_nb_liens)
nb_liens$Session <- as.factor(nb_liens$Session)
nb_liens$Session <- factor(nb_liens$Session,levels = c("H16","A16","H17","E17","A17","H18"),labels=c(""))
table_nb_liens <- table(nb_liens$Session)
barplot(table(nb_liens$Session))
