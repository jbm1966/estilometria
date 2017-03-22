setwd("h:/cursoestilometria/scripts/master")
library(XML)
library(RCurl)
# Indicamos la dirección de la página "maestra" o índice
url <- "www.dominiopublico.es/autor.php?compuesto=P%C3%A9rez%20Gald%C3%B3s%2C%20Benito" ##he cambiado la cadena de búsqueda de autor para que se pueda hacer con windows
FUENTE <- getURL(url, encoding="UTF-8") # Lee la página donde están las URL que queremos extraer
ANALIZADO <- htmlParse(FUENTE) # Analiza el fichero HTML bajado y lo formatea
DIRECCION <- xpathSApply(ANALIZADO, "//td/a/@href") # Extrae la direcciones URL
DIRECCION1 <- grep("ebook.*?\\.TXT\\.zip", DIRECCION) #Averigua cuáles son los ficheros TXT.zip que son los que se quieren
# Ahora descarga los ficheros y los graba en tu ordenador
# Como son zip, los desenlatará y se quedará solo con el fichero de texto
tiempos<-sample(1:10,length(DIRECCION1),replace=TRUE)
td <- tempdir() # Crea un directorio temporal
tf <- tempfile(tmpdir = td, fileext = ".zip") # Crea un lugar donde depositarlo temporalmente. Se ha dejado el punto.
for (i in 1:length(DIRECCION1)){
  download.file(url=paste("http://www.dominiopublico.es/",DIRECCION[DIRECCION1[i]],sep = ""), tf)
  #download.file("http://www.dominiopublico.es/ebook/00/01/0001.TXT.zip",tf)
  fname <- unzip(tf,list = T)$Name[1]
  print(fname)
  unzip(tf,files = fname, exdir = "GLDS", overwrite = T)
  Sys.sleep(tiempos[i]) ## me gusta dejar un tiempo entre petición y petición para que no se
                                        ## cabree el administrador de la página
}
unlink(td) # Desconecta el directorio temporal
unlink(tf) # Desconecta los ficheros temporales

# Como los nombres de ficheros tienes "letras" raras
# lo mejor es renombrarlos eliminando las secuencias de % y 2 letras

camino<-"GLDS/" ## aquí es donde se han almacenado los ficheros de texto obtenidos

ficheros <- list.files(path=camino) # lee los nombres de los ficheros
# Este bucle elimina las secuencia
# y renombra los ficheros

for (i in 1:length(ficheros)){
#file.rename(ficheros[i],gsub("%\\w{2}", "", ficheros[i]))  ## esto no funciona
## es mejor eliminar cualquier cosa que no sea una letra o un número o un guión o un punto o un espacio
    file.rename(paste0(camino,ficheros[i]),paste0(camino,gsub("[^0-9a-zA-Z \\.\\-]", "", ficheros[i])))
}

# Otro problema era la famosa codificación
# los de Win no tendrán, seguramente, problemas
# Los de Mac y Linux seguro
ficheros <- list.files(camino) # recupera la lista de ficheros
# El bucle lee los ficheros
anterior<-setwd(camino) ##Nos situamos donde están los ficheros con los episodios y
                        ##almacenamos el camino de los ficheros inicial para volver luego 
system.time(
for (i in 1:length(ficheros)){
  texto <- readLines(ficheros[i], encoding = "latin1") #Lee el fichero
  #texto <- iconv(texto, from="latin1", to="UTF-8") #Lo convierte a UTF-8
  ## que grabe el fichero utf-8 aparte del original para no tener que volver a bajar todo.
  #  writeLines(texto, paste0("utf_8_",ficheros[i]), sep = "\n") # Lo graba en el disco
  
  ## otra forma alternativa sería. No haría falta la línea 52 con iconv()
  cat(texto, file = (con <- file(paste0("utf_8_",ficheros[i]), "w", encoding = "UTF-8")),sep="\n");           close(con)
}  
)
# 
file.remove(ficheros[1:5])
##volvemos adonde estábamos en el sistema de ficheros
setwd(anterior)
