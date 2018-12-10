package responder

import (
	"database/sql"
	"encoding/json"
	"github.com/saulortega/utilidades/notificación"
	"log"
	"net/http"
	"strconv"
)

func Obtención(w http.ResponseWriter, Obj interface{}, llave string) {
	ObjJSON, err := json.Marshal(Obj)
	if err != nil {
		log.Println("Error codificando a JSON ", llave)
		log.Println("\n", err)
		InternalServerError(w)
		return
	}

	w.Header().Set("X-Llave", llave)
	w.WriteHeader(http.StatusOK)
	w.Write(ObjJSON)
}

func Creación(w http.ResponseWriter, llave string) {
	w.Header().Set("X-Notificaciones", notificación.Correcto("Agregado.").Base64())
	w.Header().Set("X-Llave", llave)
	w.WriteHeader(http.StatusCreated)
}

func Edición(w http.ResponseWriter, llave string) {
	w.Header().Set("X-Notificaciones", notificación.Correcto("Guardado.").Base64())
	w.Header().Set("X-Llave", llave)
	w.WriteHeader(http.StatusOK)
}

func Eliminación(w http.ResponseWriter, llave string) {
	w.Header().Set("X-Notificaciones", notificación.Correcto("Eliminado.").Base64())
	w.Header().Set("X-Llave", llave)
	w.WriteHeader(http.StatusOK)
}

func Listado(w http.ResponseWriter, Objs interface{}, total int64) {
	ObjsJSON, err := json.Marshal(Objs)
	if err != nil {
		log.Println("Error codificando a JSON")
		log.Println("\n", err)
		InternalServerError(w)
		return
	}

	w.Header().Set("X-Total", strconv.FormatInt(total, 10))
	w.WriteHeader(http.StatusOK)
	w.Write(ObjsJSON)
}

func ListadoVacío(w http.ResponseWriter) {
	w.WriteHeader(http.StatusNoContent)
	w.Write([]byte("[]"))
}

//
//
//

func NotFoundOrInternal(w http.ResponseWriter, err error, llave string) {
	log.Println("Error obteniendo registro ", llave)
	log.Println("\n", err)
	if err == sql.ErrNoRows {
		NotFound(w, llave)
	} else {
		InternalServerError(w)
	}
}

func InternalServerError(w http.ResponseWriter) {
	w.Header().Set("X-Notificaciones", notificación.Error("Ocurrió un error. Intente nuevamente.").Base64())
	w.WriteHeader(http.StatusInternalServerError)
}

func NotFound(w http.ResponseWriter, llave string) {
	w.Header().Set("X-Llave", llave)
	w.Header().Set("X-Notificaciones", notificación.Error("Registro no encontrado.").Base64())
	w.WriteHeader(http.StatusNotFound) //404
}

func BadRequest(w http.ResponseWriter, err error) {
	w.Header().Set("X-Notificaciones", notificación.Error(err.Error()).Base64())
	w.WriteHeader(http.StatusBadRequest)
}

func MethodNotAllowed(w http.ResponseWriter) {
	w.Header().Set("X-Notificaciones", notificación.Error("Método no permitido.").Base64())
	w.WriteHeader(http.StatusMethodNotAllowed) //405
}

func LlaveNoRecibida(w http.ResponseWriter) {
	w.Header().Set("X-Notificaciones", notificación.Error("Identificador no recibido. Recargue la página e intente de nuevo.").Base64())
	w.WriteHeader(http.StatusBadRequest) //400
}
