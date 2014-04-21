#!/bin/bash
#SencryptDropbox v0.1

##CONFIG##

pub="" #id de la llave publica
pri="" #id de la llave privada
dpx="Dropbox" #Directorio de dropbox

##CONFIG##

valida(){
  if [ "$(gpg -k |grep -o $pub)" != $pub ]; then
    echo "La llave publica no se encuentra en el sistema"
  elif [ "$(gpg -k |grep -o $pri)" != $pri ]; then
    echo "La llave privada no se encuentra en el sistema"
  fi
}
empaqueta() {
  cd $HOME/$dpx/; tar czvf /tmp/dpxcontent.tar.gz *
}
desempaqueta() {
  cd $HOME/$dpx/; tar -xzvf $HOME/$dpx/dpxcontent.tar.gz
  rm $HOME/$dpx/dpxcontent.tar.gz
}
encripta() {
  gpg --encrypt --recipient $pub $HOME/$dpx/dpxcontent.tar.gz
  rm $HOME/$dpx/dpxcontent.tar.gz
}
desencripta() {
  gpg -d $HOME/$dpx/dpxcontent.tar.gz.gpg > $HOME/$dpx/dpxcontent.tar.gz
  rm $HOME/$dpx/dpxcontent.tar.gz.gpg
}
espera() {
  while [[ "$(dropbox status)" != "Idle" ]] 
  do
    echo "Dropbox esta trabajando..."
    sleep 10
  done
}

#MAIN
valida;
dropbox start &
wait
espera;
while [[ "$(dropbox status)" != "Dropbox isn't running!" ]] 
do
  if [ -f $HOME/$dpx/dpxcontent.tar.gz.gpg ]; then
    desencripta;
    desempaqueta;
    rm -R $HOME/.Dropbox_bkp/*
  fi
  echo "."
  sleep 5
done
if [ ! -d $HOME/.Dropbox_bkp/ ]; then
  mkdir $HOME/.Dropbox_bkp
fi
cp -R $HOME/$dpx/* $HOME/.Dropbox_bkp/
empaqueta;
rm -R $HOME/$dpx/*
mv /tmp/dpxcontent.tar.gz $HOME/$dpx 
encripta;
dropbox start &
wait
espera;
dropbox stop
