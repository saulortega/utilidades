package notificación

import (
	"encoding/base64"
	"encoding/json"
	"log"
)

type Notificación struct {
	Mensajes []string
	Tiempo   int
	Tipo     string
}

func Error(msj ...string) Notificación {
	return Nueva("error", 10000, msj...)
}

func Advertencia(msj ...string) Notificación {
	return Nueva("advertencia", 8000, msj...)
}

func Información(msj ...string) Notificación {
	return Nueva("información", 6000, msj...)
}

func Correcto(msj ...string) Notificación {
	return Nueva("correcto", 6000, msj...)
}

func Nueva(tipo string, tiempo int, msj ...string) Notificación {
	var N = Notificación{}
	N.Tipo = tipo
	N.Tiempo = tiempo
	if len(msj) > 0 {
		N.Mensajes = append(N.Mensajes, msj...)
	}

	return N
}

func (n *Notificación) Agregar(t string) {
	if len(t) > 2 {
		n.Mensajes = append(n.Mensajes, t)
	}
}

func (n Notificación) Base64() string {
	JSON, err := json.Marshal(n)
	if err != nil {
		log.Println("Error codificando a JSON:", err)
	}

	return base64.StdEncoding.EncodeToString(JSON)
}

//
//
//

type Notificaciones []Notificación

func (n *Notificaciones) Agregar(ns ...Notificación) {
	*n = append(*n, ns...)
}

func (n Notificaciones) Base64() string {
	JSON, err := json.Marshal(n)
	if err != nil {
		log.Println("Error codificando a JSON:", err)
	}

	return base64.StdEncoding.EncodeToString(JSON)
}
