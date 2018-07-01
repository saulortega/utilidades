// Autenticación web mediante parmámetros "correo" y "contraseña"
package auten

import (
	"crypto/rsa"
	"database/sql"
	"errors"
	"net/http"
	"time"
)

type Datos struct {
	LlaveUsuario string
	LlaveEntidad string
	Token        string
	BD           *sql.DB
}

/*func Abc() string {
	connStr := "host=localhost user=postgres dbname=servicios_salud sslmode=disable password=postgres"
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal(err)
	}

	var llave string
	err = db.QueryRow("SELECT llave FROM personas WHERE tipo_identificación = $1 limit 1", "CC").Scan(&llave)
	if err != nil {
		log.Fatal(err)
	}

	log.Println("\n SIPPPPPPPPPPPP::: ", llave)

	log.Println(usuarioPorCorreo(db, "saulortega.co@gmail.com"))

	return llave
}*/

var (
	CorreoNoRecibido     = errors.New("No se recibió la dirección de correo electrónico.")
	ContraseñaNoRecibida = errors.New("No se recibió la contraseña.")
	ContraseñaErrónea    = errors.New("Contraseña errónea.")
)

func Ingreso(nombreBaseBD string, r *http.Request, BDG *sql.DB, RSAPrivateKey *rsa.PrivateKey, tiempo time.Duration) (*Datos, error) {
	var datos = new(Datos)
	var hash string

	cor, con, err := credencialesDesdeRequest(r)
	if err != nil {
		return datos, err
	}

	datos.LlaveUsuario, datos.LlaveEntidad, hash, err = datosSegúnCorreo(BDG, cor)
	if err != nil {
		return datos, err
	}

	err = ComprobarContraseña(hash, con)
	if err != nil {
		return datos, err
	}

	datos.Token, err = CrearToken(RSAPrivateKey, datos.LlaveUsuario, tiempo)
	if err != nil {
		return datos, err
	}

	datos.BD, err = obtenerConexiónBD(nombreBaseBD, datos.LlaveEntidad)
	if err != nil {
		return datos, err
	}

	return datos, nil
}

func Sesión(nombreBaseBD string, r *http.Request, BD *sql.DB, RSAPublicKey *rsa.PublicKey) (*Datos, error) {
	var datos = new(Datos)
	//var hash string

	_, claims, err := ComprobarToken(r, RSAPublicKey)
	if err != nil {
		return datos, err
	}

	datos.LlaveUsuario, datos.LlaveEntidad, _, err = datosSegúnLlaveUsuario(BD, claims.Iden)
	if err != nil {
		return datos, err
	}

	datos.BD, err = obtenerConexiónBD(nombreBaseBD, datos.LlaveEntidad)
	if err != nil {
		return datos, err
	}

	return datos, nil
}
