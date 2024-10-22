#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

set -a
source .env
set +a

function helpPanel() {

  echo -e "\n\t${yellowColour}[+]${endColour}${grayColour} Panel de ayuda${endColour}\n"
  echo -e "\t${yellowColour}type)${endColour}${grayColour} Especificar recurso ${endColour}${purpleColour}(directory/database)${endColour}"
  echo -e "\t${yellowColour}path)${endColour}${grayColour} Indicar la ruta del recurso ${endColour}"
  echo -e "\n\t${purpleColour}Example:\n\t${endColour}${grayColour}./$0 ${blueColour}-type${endColour} database ${blueColour}-path${endColour} /home/user/db.sql  ${endColour}"

}

function make_backup_sql() {

  date_now=$(date +"%d-%m-%Y")
  database="$1"

  db_exists=$(mysql -u $DB_USER -p$DB_PASSWORD -e "SHOW DATABASES LIKE '$database';" 2>/dev/null)

  if [ -n "$db_exists" ]; then

    echo -ne "\n\t${yellowColour}[+]${endColour} ${grayColour}En donde quieres guardar la base de datos${endColour}"
    echo -e " (${yellowColour}aws${endColour}/${yellowColour}localhost${endColour}/${yellowColour}drive${endColour})"
    echo -ne "\t${greenColour}[-]${endColour} "
    read location

    if [ "$location" == "localhost" ]; then

      mysqldump -u "$DB_USER" -p"$DB_PASSWORD" $database 2>/dev/null 1>"$database-$date_now.sql"

      if [ "$?" -eq 0 ]; then
        echo -e "\t${yellowColour}[+]${endColour} ${grayColour}Operación exitosa! ${endColour}"
      else
        echo -e "\t${redColour}[!]${endColour} Algo malo ocurrió, revisa si tienes los permisos adecuados"
      fi

    elif [ "$location" == "drive" ]; then
      echo ""

    elif [ "$location" == "aws" ]; then
      echo ""

    else
      echo -e "\n${redColour}[!] Debes ingresar una opción valida${endColour}"
    fi

  else

    echo -e "\n${redColour}[!] No existe esa base de dato e{endColour}"

  fi
}

function make_backup_directory() {
  echo "oki"
}

function validateInput() {

  inputUser="$1"
  path_resource="$2"

  if [ "$inputUser" == "database" ]; then

    make_backup_sql $path_resource

  elif [ "$inputUser" == "directory" ]; then

    if [ -d "$path_resource" ]; then
      make_backup_directory
    else
      echo -e "\n${redColour}[!] No he encontrado el directorio${endColour}"
    fi
  else
    echo -e "\n${redColour}[!] Debes especificar una opción valida${endColour}"
  fi

}

let -i parameter_counter=0

while getopts "t:p:h" arg; do

  case $arg in

  t)
    option="$OPTARG"
    let parameter_counter+=1
    ;;

  p)
    path="$OPTARG"
    let parameter_counter+=1
    ;;

  h) helpPanel ;;

  esac

done

if [ "$parameter_counter" -eq 2 ]; then

  validateInput $option $path

else

  helpPanel

fi
