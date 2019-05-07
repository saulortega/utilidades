package auten

import (
	"context"
	"errors"
	"log"
	"net/http"
	"strings"

	firebase "firebase.google.com/go"
	"google.golang.org/api/option"
)

var (
	CredencialesAuten string
)

func VerificarTokenDesdeRequest(r *http.Request) (error, int) {
	hdr := r.Header.Get("Authorization")
	if hdr == "" || strings.TrimSpace(strings.ToLower(hdr)) == "bearer" {
		return errors.New("No se recibió el token de autenticación."), http.StatusUnauthorized
	}

	pdzs := strings.Split(hdr, "Bearer ")
	if len(pdzs) != 2 || pdzs[0] != "" || pdzs[1] == "" {
		return errors.New("Encabezado de autenticación erróneo."), http.StatusBadRequest
	}

	return VerificarToken(pdzs[1])
}

func VerificarToken(tkn string) (error, int) {
	return VerificarTokenFirebase(tkn)
}

func VerificarTokenFirebase(tkn string) (error, int) {
	if CredencialesAuten == "" {
		log.Println("[683862] Falta especificar el archivo de credenciales del proyecto de autenticación de Firebase en la variable auten.CredencialesAuten")
		return errors.New("Ocurrió un error. [683862]"), http.StatusInternalServerError
	}

	opt := option.WithCredentialsFile(CredencialesAuten)
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Println("[642023]", err)
		return errors.New("Ocurrió un error. [642023]"), http.StatusInternalServerError
	}

	client, err := app.Auth(context.Background())
	if err != nil {
		log.Println("[491533]", err)
		return errors.New("Ocurrió un error. [491533]"), http.StatusInternalServerError
	}

	_, err = client.VerifyIDToken(context.Background(), tkn)
	if err != nil {
		log.Println("[368432]", err)
		var te string
		if strings.Contains(err.Error(), "ID token has expired") {
			te = "Su sesión caducó. Ingrese nuevamente."
		} else {
			te = "No se pudo comprobar la autenticación."
		}

		return errors.New(te), http.StatusUnauthorized
	}

	return nil, http.StatusOK
}

// Falta verificar usuario registrado en BD local
