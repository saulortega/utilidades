import (
	"errors"
	"net/http"
	"regexp"

	"github.com/saulortega/utilidades/responder"
)

// pendiente autenticación...

{{$raíz := .}}


func ManejadorHTTP(w http.ResponseWriter, r *http.Request) {

	//Al menos para pruebas. Probablemente se deba quitar...
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Origin, Authorization, X-Requested-With, Content-Type, Accept") //necesario para dominio cruzado. Quitar después ...
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



	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK) //200
		w.Write([]byte("GET, POST, PUT, DELETE"))
	} else if r.Method == "GET" {
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