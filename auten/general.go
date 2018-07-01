package auten

import (
	"database/sql"
	"errors"
	_ "github.com/lib/pq"
	"log"
	"strings"
)

func credencialesDesdeRequest(r *http.Request) (string, string, error) {
	var cor, con string

	cor = strings.TrimSpace(strings.ToLower(r.FormValue("correo")))
	if len(cor) == 0 {
		return cor, con, CorreoNoRecibido
	}

	con = strings.TrimSpace(r.FormValue("contraseña"))
	if len(con) == 0 {
		return cor, con, ContraseñaNoRecibida
	}

	return cor, con, nil
}

func datosSegúnCorreo(BDG *sql.DB, correo string) (string, string, string, error) {
	var llaveUsuario, llaveEntidad, contraseña string

	err := BDG.QueryRow(`SELECT llave,llave_entidad,contraseña FROM usuarios WHERE correo = $1`, correo).Scan(&llaveUsuario, &llaveEntidad, &contraseña)
	if err == sql.ErrNoRows {
		return "", "", "", errors.New("Verifique sus credenciales de acceso. [5038]")
	} else if err != nil {
		return "", "", "", errors.New("Error de autenticación. [2503]")
	}

	if len(llaveUsuario) != 6 || len(llaveEntidad) != 6 {
		return "", "", "", errors.New("Error de autenticación. [1583]") //Esto no debería ocurrir
	}

	return llaveUsuario, llaveEntidad, contraseña, nil
}

func datosSegúnLlaveUsuario(BDG *sql.DB, llaveUsuario string) (string, string, string, error) {
	var llaveEntidad, contraseña string

	err := BDG.QueryRow(`SELECT llave_entidad,contraseña FROM usuarios WHERE llave = $1`, llaveUsuario).Scan(&llaveEntidad, &contraseña)
	if err == sql.ErrNoRows {
		return "", "", "", errors.New("Sesión no válida. [3593]")
	} else if err != nil {
		return "", "", "", errors.New("Sesión no válida. [4581]")
	}

	if len(llaveUsuario) != 6 || len(llaveEntidad) != 6 {
		return "", "", "", errors.New("Error de sesión. [2553]") //Esto no debería ocurrir
	}

	return llaveUsuario, llaveEntidad, contraseña, nil
}

func obtenerConexiónBD(nombreBaseBD string, llave string) (*sql.DB, error) {
	bd, err := sql.Open("postgres", "host=localhost user=postgres dbname="+nombreBaseBD+"_"+llave+" sslmode=disable password=postgres")
	if err != nil {
		log.Println(err)
		return bd, errors.New("Ocurrió un error. Intente nuevamente. [5202]")
	}

	return bd, nil
}
