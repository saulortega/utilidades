import (
	"errors"
	"net/http"
	"regexp"
	"strings"

	"github.com/saulortega/utilidades/responder"
	"github.com/saulortega/utilidades/auten"
	"github.com/saulortega/utilidades/notificación"
)

// pendiente autenticación...

{{$raíz := .}}


var AllowHeaders = []string{}

func allowedHeaders() string {
	var H = []string{"Origin", "Authorization", "X-Requested-With", "Content-Type", "Accept"}
	for _, h := range AllowHeaders {
		H = append(H, h)
	}

	return strings.Join(H, ", ")
}


func ManejadorHTTP(w http.ResponseWriter, r *http.Request) {

	//Al menos para pruebas. Probablemente se deba quitar...
	w.Header().Set("Access-Control-Allow-Origin", "*")
	//w.Header().Set("Access-Control-Allow-Headers", "Origin, Authorization, X-Requested-With, Content-Type, Accept") //necesario para dominio cruzado. Quitar después ...
	w.Header().Set("Access-Control-Allow-Headers", allowedHeaders())
	w.Header().Set("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE")                                  //No necesario para dominio cruzado. Plantearse ponerlo siempre...
	w.Header().Set("Access-Control-Expose-Headers", "X-Msj")                                               //Necesario en CORS para poder ver este header desde axios
	w.Header().Add("Access-Control-Expose-Headers", "X-Llave")
	w.Header().Add("Access-Control-Expose-Headers", "X-Total")
	w.Header().Add("Access-Control-Expose-Headers", "X-Notificaciones")


	{{range $table := .Tables -}}
	//var {{$table.Name}} = regexp.MustCompile(`^/{{$table.Name}}$`)
	var {{$table.Name}}_N = regexp.MustCompile(`^/{{$table.Name}}/(.+)?`)
	
	//
	{{end -}}


	switch r.Method {
	case "OPTIONS":
		//
		w.WriteHeader(http.StatusOK) //200
		w.Write([]byte("GET, POST, PUT, DELETE"))
		return
		//
	case "GET", "POST", "PUT", "DELETE":
		//
		err, cod := auten.VerificarTokenDesdeRequest(r)
		if err != nil {
			w.Header().Set("X-Notificaciones", notificación.Error(err.Error()).Base64())
			//w.Header().Set("X-Auten", "ERROR")
			w.WriteHeader(cod)
			return
		}
		//
	default:
		//
		responder.MethodNotAllowed(w)
		return
		//
	}

	/*
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK) //200
		w.Write([]byte("GET, POST, PUT, DELETE"))
		return
	} else if r.Method == "GET" || r.Method == "PUT" || r.Method == "POST" || r.Method == "DELETE" {
		//
	} else {
		responder.MethodNotAllowed(w)
		return
	}
	*/


	/*
	if r.Method == "POST" && r.URL.Path == "/autenticación" {
		var err, cod = auten.VerificarTokenDesdeRequest(r)
		if err != nil {
			w.Header().Set("X-Notificaciones", notificación.Error(err.Error()).Base64())
			w.WriteHeader(cod)
			return
		}

		//Pendiente comprobar en BD acceso a la aplicación, permisos, datos de usuarios, etc.
		w.WriteHeader(http.StatusOK)
		return
	}
	*/


	/*if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK) //200
		w.Write([]byte("GET, POST, PUT, DELETE"))
	} else*/ if r.Method == "GET" {
		{{range $table := .Tables -}}
		{{$alias := index $raíz.Aliases.Tables $table.Name}}
		if r.URL.Path == "/{{$table.Name}}" {
			Listar{{$alias.UpPlural}}(BD, w, r)
			return
		} else if {{$table.Name}}_N.MatchString(r.URL.Path){
			Obtener{{$alias.UpSingular}}(BD, w, r)
			return
		}
		{{- end}}

		responder.BadRequest(w, errors.New("Recurso desconocido."))

	} else if r.Method == "PUT" {
		{{range $table := .Tables -}}
		{{$alias := index $raíz.Aliases.Tables $table.Name}}
		if {{$table.Name}}_N.MatchString(r.URL.Path){
			Editar{{$alias.UpSingular}}(BD, w, r)
			return
		}
		{{- end}}

		responder.BadRequest(w, errors.New("Recurso desconocido."))

	} else if r.Method == "POST" {
		if r.URL.Path == "/autenticar" {
			w.WriteHeader(http.StatusOK) //Se autenticó antes de entrar aquí
			//Pendiente comprobar en BD datos de acceso, datos personales, etc.
			// El acceso a BD se haría dentro de auten. los datos de usuario aquí....
			// ------------------------- pendiente -------------------------------------
			return
		}

		{{range $table := .Tables -}}
		{{$alias := index $raíz.Aliases.Tables $table.Name}}
		if r.URL.Path == "/{{$table.Name}}" {
			Crear{{$alias.UpSingular}}(BD, w, r)
			return
		}
		{{- end}}

		responder.BadRequest(w, errors.New("Recurso desconocido."))

	} else {
		responder.MethodNotAllowed(w)
	}
}