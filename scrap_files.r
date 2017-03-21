setwd("~/Desktop/GLDS")
library(XML)
library(RCurl)
# Indicamos la dirección de la página "maestra" o índice
url <- "http://www.dominiopublico.es/autor.php?compuesto=Pérez%20Galdós,%20Benito"
FUENTE <- getURL(url, encoding="UTF-8") # Lee la página donde están las URL que queremos extraer
ANALIZADO <- htmlParse(FUENTE) # Analiza el fichero HTML bajado y lo formatea
DIRECCION <- xpathSApply(ANALIZADO, "//td/a/@href") # Extrae la direcciones URL
DIRECCION1 <- grep("ebook.*?\\.TXT\\.zip", DIRECCION) #Averigua cuáles son los ficheros TXT.zip que son los que se quieren
# Ahora descarga los ficheros y los graba en tu ordenador
# Como son zip, los desenlatará y se quedará solo con el fichero de texto
td <- tempdir() # Crea un directorio temporal
tf <- tempfile(tmpdir = td, fileext = "zip") # Crea un lugar donde depositarlo temeporalmente
for (i in 1:length(DIRECCION1)){
  download.file(url=paste("http://www.dominiopublico.es/",DIRECCION[DIRECCION1[i]],sep = ""), tf)
  #download.file("http://www.dominiopublico.es/ebook/00/01/0001.TXT.zip",tf)
  fname <- unzip(tf,list = T)$Name[1]
  print(fname)
  unzip(tf,files = fname, exdir = "GLDS", overwrite = T)
}
unlink(td) # Desconecta el directorio temporal
unlink(tf) # Desconecta los ficheros temporales

# Como los nombres de ficheros tienes "letras" raras
# lo mejor es renombrarlos eliminando las secuencias de % y 2 letras
ficheros <- list.files() # lee los nombres de los ficheros
# Este bucle elimina las secuencia
# y renombra los ficheros
for (i in 1:length(ficheros)){
file.rename(ficheros[i],gsub("%\\w{2}", "", ficheros[i]))
}

# Otro problema era la famosa codificación
# los de Win no tendrán, seguramente, problemas
# Los de Mac y Linux seguro
ficheros <- list.files() # recupera la lista de ficheros
# El bucle lee los ficheros
for (i in 1:length(ficheros)){
  texto <- readLines(ficheros[i], encoding = "latin1") #Lee el fichero
  texto <- iconv(texto, from="latin1", to="UTF-8") #Lo convierte a UTF-8
  writeLines(texto, ficheros[i], sep = "\n") # Lo graba en el disco
}
# 
file.remove(ficheros[1:5])
