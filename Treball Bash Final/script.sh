#!/bin/bash
if [ -z "$1" ]; then
	if [ $(id -u) -eq 0 ]; then
		if ! [ -d /var/log/gestioUsuarisMarcFabregat/log.txt ]; then
			if ! [ -d /var/log/gestioUsuarisMarcFabregat ]; then
				mkdir /var/log/gestioUsuarisMarcFabregat
			fi
			echo "Logs de l'aplicació de gestio d'usuaris" > /var/log/gestioUsuarisMarcFabregat/log.txt
			echo "------------------------------------------" >> /var/log/gestioUsuarisMarcFabregat/log.txt
		fi
		
		#Organitzacio de la app
		#Menu Principal
		Titol="Gestio d'usuari"
		Pregunta="Tria l'opcio que vols realitzar :"

		Opcions=( 
		"Crear"
		"Borrar"
		"Modificar"
		"Llistar"
		"Sortir"
		)
		Opcions=( ${Opcions[@]/#/"FALSE "} )

		#Menu Crear Usuari
		Titol2="Crear Usuari"
		Pregunta2="Tria l'opcio que vols realitzar :"

		Opcions2=( 
		"CSV"
		"UnicUsuari"
		"Sortir"
		)
		Opcions2=( ${Opcions2[@]/#/"FALSE "} )

		#Menu Borrar Usuari
		Titol3="Borrar Usuari"
		Pregunta3="Tria l'opcio que vols realitzar :"

		Opcions3=( 
		"CSV"
		"UnicUsuari"
		"Sortir"
		)
		Opcions3=( ${Opcions3[@]/#/"FALSE "} )

		#Menu Modificar Usuari
		Titol4="Modificar Usuari"
		Pregunta4="Tria l'opcio que vols realitzar :"

		Opcions4=( 
		"CSV"
		"UnicUsuari"
		"Sortir"
		)
		Opcions4=( ${Opcions4[@]/#/"FALSE "} )
	
		#Fi dels menus

		while Opcion="$(zenity --width 309 --height 240 --title="$Titol" --text="$Pregunta" --list --radiolist  --column "Opcio Nª" --column="Opcions" "${Opcions[@]}")"; do
			if   [ "$Opcion" = "Crear" ]; then
				while OpcionC="$(zenity --width 309 --height 240 --title="$Titol2" --text="$Pregunta2" --list --radiolist  --column "Opcio Nª" --column="Opcions" "${Opcions2[@]}")"; do
					if   [ "$OpcionC" = "CSV" ]; then
						fitxer=`zenity --file-selection --text "Seleccioneu l'arxiu CSV"`
						while IFS=, read usuari contrassenya
						do
							if [[ $usuari && $contrassenya ]]; then
								# encripto la contrassenya i afegeixo l'usuari
								contraEncriptada=$(perl -e 'print crypt($ARGV[0],"password")' $contrassenya)
								useradd -m -p $contraEncriptada $usuari
								mkdir /home/${usuari}/CarpetaPersonal
								chown ${usuari} /home/${usuari}/CarpetaPersonal
								chmod 700 /home/${usuari}/CarpetaPersonal
								echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
								echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
								echo "- S'ha afegit l'usuari ${usuari} amb contrassenya: ${contrassenya} utilitzant l'opcio CSV" >> /var/log/gestioUsuarisMarcFabregat/log.txt
							else
								echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
								echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
								echo "- Error al crear: Falta un camp, o els dos, al fitxer csv importat" >> /var/log/gestioUsuarisMarcFabregat/log.txt
							fi

						done < $fitxer 
					elif [ "$OpcionC" = "UnicUsuari" ]; then
						FORM=`zenity --forms --title "Crear Usuari" --text  "Info de l'usuari" \
						--add-entry="Nom de l'usuari (si esta vuit sera 'usuari')" \
						--add-entry="Contrassenya (si esta vuit sera '123456')"`

						# extreure els valors usuari i contrassenya del formulari
						USUARI=$(awk -F'|' '{print $1}' <<<$FORM);    
						CONTRA=$(awk -F'|' '{print $2}' <<<$FORM);

						# li diem que si els camps estan vuis, tindran un valor per defecte
						[[ -z $USUARI ]] && USUARI="usuari";
						[[ -z $CONTRA ]] && CONTRA="123456";
					
						# encripto la contrassenya i afegeixo l'usuari
						contraEncriptada=$(perl -e 'print crypt($ARGV[0],"password")' $CONTRA)
						useradd -m -p $contraEncriptada $USUARI
						mkdir /home/$USUARI/CarpetaPersonal
						chown $USUARI /home/$USUARI/CarpetaPersonal
						chmod 700 /home/$USUARI/CarpetaPersonal
						echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo "- S'ha afegit l'usuari $USUARI amb contrassenya: $CONTRA" >> /var/log/gestioUsuarisMarcFabregat/log.txt

					elif [ "$OpcionC" = "Sortir" ]; then
						echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo "- S'han sortit de l'aplicació" >> /var/log/gestioUsuarisMarcFabregat/log.txt
						exit 1
					else
						echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo "- Error al triar una opcio del Menu Crear" >> /var/log/gestioUsuarisMarcFabregat/log.txt
						zenity --error --text="Has triat $Opcion, Opcio Invalida"
					fi
				done	
			elif [ "$Opcion" = "Borrar" ]; then
				while OpcionB="$(zenity --width 309 --height 240 --title="$Titol3" --text="$Pregunta3" --list --radiolist  --column "Opcio Nª" --column="Opcions" "${Opcions3[@]}")"; do
					if   [ "$OpcionB" = "CSV" ]; then
						fitxer=`zenity --file-selection --text "Seleccioneu l'arxiu CSV"`
						while IFS=, read usuari contrassenya
						do
							if [[ $usuari && $contrassenya ]]; then
								# elimino l'usuari						
								userdel -r -f $usuari
								echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
								echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
								echo "- S'ha borrat l'usuari ${usuari} utilitzant l'opcio CSV" >> /var/log/gestioUsuarisMarcFabregat/log.txt
							else
								echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
								echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
								echo "- Error al borrar: Falta un camp, o els dos, al fitxer csv importat" >> /var/log/gestioUsuarisMarcFabregat/log.txt
							fi

						done < $fitxer 
					elif [ "$OpcionB" = "UnicUsuari" ]; then
						FORM=`zenity --forms --title "Borrar Usuari" --text  "Usuari a eliminar" \
						--add-entry="Nom de l'usuari a borrar"`

						# extreure el valors usuari del formulari
						USUARI=$(awk -F'|' '{print $1}' <<<$FORM); 

						# elimino l'usuari
						userdel -r -f $USUARI
						echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo "- S'ha borrat l'usuari ${USUARI}" >> /var/log/gestioUsuarisMarcFabregat/log.txt

					elif [ "$OpcionB" = "Sortir" ]; then
						echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo "- S'han sortit de l'aplicació" >> /var/log/gestioUsuarisMarcFabregat/log.txt
						exit 1
					else
						echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo "- Error al triar una opcio del Menu Borrar" >> /var/log/gestioUsuarisMarcFabregat/log.txt
						zenity --error --text="Has triat $Opcion, Opcio Invalida"
					fi
				done
			elif [ "$Opcion" = "Modificar" ]; then
				while OpcionM="$(zenity --width 309 --height 240 --title="$Titol4" --text="$Pregunta4" --list --radiolist  --column "Opcio Nª" --column="Opcions" "${Opcions4[@]}")"; do
					if   [ "$OpcionM" = "CSV" ]; then
						fitxer=`zenity --file-selection --text "Seleccioneu l'arxiu CSV"`
						while IFS=, read usuari contrassenya
						do
							if [[ $usuari && $contrassenya ]]; then
								# encripto la contrassenya i la actualitzo
								contraEncriptadaNova=$(perl -e 'print crypt($ARGV[0],"password")' ${contrassenya})
								printf "$contraEncriptadaNova\n$contraEncriptadaNova\n" | sudo passwd ${usuari}
								echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
								echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
								echo "- S'ha modificat l'usuari ${usuari}, ara te la contrassenya: ${contrassenya} utilitzant l'opcio CSV" >> /var/log/gestioUsuarisMarcFabregat/log.txt
							else
								echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
								echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
								echo "- Error al modificar: Falta un camp, o els dos, al fitxer csv importat" >> /var/log/gestioUsuarisMarcFabregat/log.txt
							fi
						done < $fitxer 
					elif [ "$OpcionM" = "UnicUsuari" ]; then
						FORM=`zenity --forms --title "Crear Usuari" --text  "Info de l'usuari" \
						--add-entry="Nom de l'usuari a modificar" \
						--add-entry="Contrassenya nova (si esta buit sera '123456')"`

						# extreure els valors usuari i contrassenya
						USUARI=$(awk -F'|' '{print $1}' <<<$FORM);    
						CONTRA=$(awk -F'|' '{print $2}' <<<$FORM);

						# li diem que si el camp contrassenya esta vuit, tindra un valor per defecte
						[[ -z $CONTRA ]] && CONTRA="123456";

						# encripto la contrassenya i la actualitzo
						contraEncriptadaNova=$(perl -e 'print crypt($ARGV[0],"password")' $CONTRA)
						printf "$contraEncriptadaNova\n$contraEncriptadaNova\n" | sudo passwd $USUARI
						echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo "- S'ha modificat l'usuari $USUARI, ara te la contrassenya: $CONTRA" >> /var/log/gestioUsuarisMarcFabregat/log.txt

					elif [ "$OpcionM" = "Sortir" ]; then
						echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo "- S'han sortit de l'aplicació" >> /var/log/gestioUsuarisMarcFabregat/log.txt
						exit 1
					else
						echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
						echo "- Error al triar una opcio del Menu Modificar" >> /var/log/gestioUsuarisMarcFabregat/log.txt
						zenity --error --text="Has triat $Opcion, Opcio Invalida"
					fi
				done
			elif [ "$Opcion" = "Llistar" ]; then
				zenity --info --text "$(getent passwd | grep bin/*sh)"
				echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
				echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
				echo "- S'han llistat tots els usuaris del sistema" >> /var/log/gestioUsuarisMarcFabregat/log.txt
			elif [ "$Opcion" = "Sortir" ]; then
				echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
				echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
				echo "- S'han sortit de l'aplicació" >> /var/log/gestioUsuarisMarcFabregat/log.txt
				exit 1
			else
				echo " " >> /var/log/gestioUsuarisMarcFabregat/log.txt	
				echo `date` >> /var/log/gestioUsuarisMarcFabregat/log.txt	
				echo "- Error al triar una opcio del Menu Principal" >> /var/log/gestioUsuarisMarcFabregat/log.txt				
				zenity --error --text="Has triat $Opcion, Opcio Invalida"
				exit 1
			fi
		done
	else
		echo "Sol l'usuari root pot afegir o eliminar usuaris al sistema"
		exit 1
	fi
else
	echo "Es un programa bastant intuitiu, si necessites ajuda obra el fitxer README."
fi
