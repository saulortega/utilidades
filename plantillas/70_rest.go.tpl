


{{- $model := .Aliases.Table .Table.Name -}}
{{- $tieneFechaCreación := setInclude "fecha_creación" (columnNames .Table.Columns) -}}
{{- $tieneFechaModificación := setInclude "fecha_modificación" (columnNames .Table.Columns) -}}
{{- $tieneFechaEliminación := setInclude "fecha_eliminación" (columnNames .Table.Columns) -}}


// Pendiente e tipo date en postgres ----------------


/*

--------- ANTES:::

{{/*

type {{$modelNameCamel}}R struct {
	{{range .Table.FKeys -}}
	{{- $txt := txtsFromFKey $dot.Tables $dot.Table . -}}
	{{$txt.Function.Name}} *{{$txt.ForeignTable.NameGo}}
	{{end -}}

	{{range .Table.ToOneRelationships -}}
	{{- $txt := txtsFromOneToOne $dot.Tables $dot.Table . -}}
	{{$txt.Function.Name}} *{{$txt.ForeignTable.NameGo}}
	{{end -}}

	{{range .Table.ToManyRelationships -}}
	{{- $txt := txtsFromToMany $dot.Tables $dot.Table . -}}
	{{$txt.Function.Name}} {{$txt.ForeignTable.Slice}}
	{{end -}}
//
}


----------- DESPUES:::



{{- $alias := .Aliases.Table .Table.Name -}}
// {{$alias.DownSingular}}R is where relationships are stored.
type {{$alias.DownSingular}}R struct {
	{{range .Table.FKeys -}}
	{{- $ftable := $.Aliases.Table .ForeignTable -}}
	{{- $relAlias := $alias.Relationship .Name -}}
	{{$relAlias.Foreign}} *{{$ftable.UpSingular}}
	{{end -}}

	{{range .Table.ToOneRelationships -}}
	{{- $ftable := $.Aliases.Table .ForeignTable -}}
	{{- $relAlias := $ftable.Relationship .Name -}}
	{{$relAlias.Local}} *{{$ftable.UpSingular}}
	{{end -}}

	{{range .Table.ToManyRelationships -}}
	{{- $ftable := $.Aliases.Table .ForeignTable -}}
	{{- $relAlias := $.Aliases.ManyRelationship .ForeignTable .Name .JoinTable .JoinLocalFKeyName -}}
	{{$relAlias.Local}} {{printf "%sSlice" $ftable.UpSingular}}
	{{end -}}
	//
}


---------------------------------------------------

MAS SIMPÑLIFICADO::::::

ANTES::::

{{range .Table.FKeys -}}
{{- $txt := txtsFromFKey $dot.Tables $dot.Table . -}}
{{$txt.Function.Name}} *{{$txt.ForeignTable.NameGo}}
{{end -}}


DESPUES:::

{{range .Table.FKeys -}}
{{- $ftable := $.Aliases.Table .ForeignTable -}}
{{- $relAlias := $alias.Relationship .Name -}}
{{$relAlias.Foreign}} *{{$ftable.UpSingular}}
{{end -}}


*/}}

*/



//
//
//

var OmitirAlConstruir{{$model.UpSingular}} = []string{}

// Los errores deben ser aptos para responder al cliente.

var AntesDeEditar{{$model.UpSingular}} = func(boil.Transactor, *{{$model.UpSingular}}, *http.Request) error {
	return nil
}

var AntesDeCrear{{$model.UpSingular}} = func(boil.Transactor, *{{$model.UpSingular}}, *http.Request) error {
	return nil
}

var DespuésDeEditar{{$model.UpSingular}} = func(boil.Transactor, *{{$model.UpSingular}}, *http.Request) error {
	return nil
}

var DespuésDeCrear{{$model.UpSingular}} = func(boil.Transactor, *{{$model.UpSingular}}, *http.Request) error {
	return nil
}

var Reconstruir{{$model.UpSingular}}AlObtener = func(exec boil.Executor, Obj *{{$model.UpSingular}}) (interface{}, error) {
	return interface{}(Obj), nil
}

func Obtener{{$model.UpSingular}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	var obj = new({{$model.UpSingular}})
	var Obj interface{}
	var err error
	var llave string

	llave, err = LlaveDesdeURL(r)
	if err != nil || llave == "" {
		//ResponseNoID(w)
		responder.LlaveNoRecibida(w)
		return
	}

	obj, err = Find{{$model.UpSingular}}(exec, llave)
	if err != nil {
		//ResponseFindError(w, llave, err)
		responder.NotFoundOrInternal(w, err, llave)
		return
	}

	Obj, err = Reconstruir{{$model.UpSingular}}AlObtener(exec, obj)
	if err != nil {
		//ResponseFindError(w, llave, err)
		responder.BadRequest(w, err)
		return
	}
	//Obj = obj

	//ResponseFindSuccess(w, llave, Obj)
	responder.Obtención(w, Obj, llave)
}

func Crear{{$model.UpSingular}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	var Obj = new({{$model.UpSingular}})
	var TX = new(sql.Tx)
	var err error
	var llave string

	llave, err = llaves.L6B(exec.(*sql.DB), "{{.Table.Name}}")
	if err != nil {
		//ResponseInternalServerError(w, err, "3844")
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	err = Obj.Construir(r)
	if err != nil {
		//ResponseBadRequest(w, err)
		responder.BadRequest(w, err)
		return
	}

	Obj.Llave = llave

	TX, err = exec.(*sql.DB).Begin()
	if err != nil {
		//ResponseInternalServerError(w, err, "6120")
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	err = AntesDeCrear{{$model.UpSingular}}(TX, Obj, r)
	if err != nil {
		//ResponseBadRequest(w, err)
		responder.BadRequest(w, err)
		TX.Rollback()
		return
	}

	{{if $tieneFechaCreación -}}
	Obj.FechaCreación = time.Now()
	{{- end}}
	{{if $tieneFechaModificación -}}
	Obj.FechaModificación = time.Now()
	{{- end}}

	err = Obj.Insert(TX, boil.Infer()) // ---------------------------- pendiente ver si agregar lista blanca en vez del Infer -----------------------------
	if err != nil {
		//ResponseInternalServerError(w, err, "3984")
		responder.InternalServerError(w)
		log.Println(err)
		TX.Rollback()
		return
	}

	err = DespuésDeCrear{{$model.UpSingular}}(TX, Obj, r)
	if err != nil {
		//ResponseInternalServerError(w, err, "9172")
		responder.BadRequest(w, err)
		TX.Rollback()
		return
	}

	err = TX.Commit()
	if err != nil {
		//ResponseInternalServerError(w, err, "2074")
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	//w.Header().Set("X-Llave", Obj.Llave)
	//w.WriteHeader(http.StatusCreated)
	responder.Creación(w, Obj.Llave)
}

func Editar{{$model.UpSingular}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	var Obj = new({{$model.UpSingular}})
	var TX = new(sql.Tx)
	var err error
	var llave string


	llave, err = LlaveDesdeURL(r)
	if err != nil || llave == "" {
		//ResponseNoID(w)
		responder.LlaveNoRecibida(w)
		return
	}

	Obj, err = Find{{$model.UpSingular}}(exec, llave)
	if err != nil {
		//ResponseFindError(w, llave, err)
		responder.NotFoundOrInternal(w, err, llave)
		return
	}

	err = Obj.Construir(r)
	if err != nil {
		//ResponseBadRequest(w, err)
		responder.BadRequest(w, err)
		return
	}

	TX, err = exec.(*sql.DB).Begin()
	if err != nil {
		//ResponseInternalServerError(w, err, "2926")
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	err = AntesDeEditar{{$model.UpSingular}}(TX, Obj, r)
	if err != nil {
		//ResponseBadRequest(w, err)
		responder.BadRequest(w, err)
		TX.Rollback()
		return
	}

	{{if $tieneFechaModificación -}}
	Obj.FechaModificación = time.Now()
	{{- end}}

	_, err = Obj.Update(TX, boil.Infer()) // ---------------------------- pendiente ver si agregar lista blanca en vez del Infer -----------------------------
	if err != nil {
		//ResponseInternalServerError(w, err, "8252")
		responder.InternalServerError(w)
		log.Println(err)
		TX.Rollback()
		return
	}

	err = DespuésDeEditar{{$model.UpSingular}}(TX, Obj, r)
	if err != nil {
		//ResponseInternalServerError(w, err, "3076")
		responder.BadRequest(w, err)
		TX.Rollback()
		return
	}

	err = TX.Commit()
	if err != nil {
		//ResponseInternalServerError(w, err, "0363")
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	//w.Header().Set("X-Llave", Obj.Llave)
	//w.WriteHeader(http.StatusOK)
	responder.Edición(w, Obj.Llave)
}

func Eliminar{{$model.UpSingular}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	{{if $tieneFechaEliminación -}}
		Eliminar{{$model.UpSingular}}PorBD(exec, w, r)
	{{- else -}}
		Eliminar{{$model.UpSingular}}Real(exec, w, r)
	{{- end -}}
}

{{if $tieneFechaEliminación -}}
func Eliminar{{$model.UpSingular}}PorBD(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	var Obj = new({{$model.UpSingular}})
	var err error
	var llave string


	llave, err = LlaveDesdeURL(r)
	if err != nil || llave == "" {
		//ResponseNoID(w)
		responder.LlaveNoRecibida(w)
		return
	}

	Obj, err = Find{{$model.UpSingular}}(exec, llave)
	if err != nil {
		//ResponseFindError(w, llave, err)
		responder.NotFoundOrInternal(w, err, llave)
		return
	}

	Obj.FechaEliminación = null.NewTime(time.Now(), true)
	_, err = Obj.Update(exec, boil.Whitelist("deleted_at"))
	if err != nil {
		//ResponseInternalServerError(w, err, "4872")
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	//w.Header().Set("X-Llave", Obj.Llave)
	//w.WriteHeader(http.StatusOK)
	responder.Eliminación(w, Obj.Llave)
}
{{- end}}

func Eliminar{{$model.UpSingular}}Real(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	var Obj = new({{$model.UpSingular}})
	var err error
	var llave string

	llave, err = LlaveDesdeURL(r)
	if err != nil || llave == "" {
		//ResponseNoID(w)
		responder.LlaveNoRecibida(w)
		return
	}

	Obj, err = Find{{$model.UpSingular}}(exec, llave)
	if err != nil {
		//ResponseFindError(w, llave, err)
		responder.NotFoundOrInternal(w, err, llave)
		return
	}

	_, err = Obj.Delete(exec)
	if err != nil {
		//ResponseInternalServerError(w, err, "6921")
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	//w.Header().Set("X-Llave", Obj.Llave)
	//w.WriteHeader(http.StatusOK)
	responder.Eliminación(w, Obj.Llave)
}

func (o *{{$model.UpSingular}}) Construir(r *http.Request) error {
	var err error

	{{range $column := .Table.Columns }}
	{{- if eq (titleCase $column.Name) "Llave" "FechaCreación" "FechaModificación" "FechaEliminación" "Contraseña"}}
	{{- else -}}
	{{- if eq $column.Type "string" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{titleCase $column.Name}} = r.FormValue("{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
	}
	{{else if eq $column.Type "bool" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseBoolFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$model.DownSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "int" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseIntFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$model.DownSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "int64" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseInt64FromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$model.DownSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "float64" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseFloat64FromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$model.DownSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "time.Time" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseTimeFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$model.DownSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.String" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{titleCase $column.Name}} = parseNullStringFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
	}
	{{else if eq $column.Type "null.Bool" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseNullBoolFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.Int" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseNullIntFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.Int64" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseNullInt64FromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.Float64" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseNullFloat64FromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.Time" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseNullTimeFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{end -}}
	{{end -}}
	{{end}}

	return err
}

/*
{{range .Table.FKeys -}}

func Build{{$model.UpPlural}}With{{titleCase .Column}}sFromPostForm(r *http.Request, keys ...string) ([]*{{$model.UpSingular}}, error) {
	var objs = []*{{$model.UpSingular}}{}
	var key = "{{.Column}}"
	if len(keys) > 0 {
		key = keys[0]
	}

	{{if .Nullable -}}
	ids, err := NullIDsFromPostForm(r, key)
	{{- else -}}
	ids, err := IDsFromPostForm(r, key)
	{{- end}}
	if err != nil {
		return objs, err
	}

	objs = Build{{$model.UpPlural}}With{{titleCase .Column}}s(ids)

	return objs, nil
}

func Build{{$model.UpPlural}}With{{titleCase .Column}}s(ids []{{if .Nullable}}null.Int64{{else}}int64{{end}}) []*{{$model.UpSingular}} {
	var objs = []*{{$model.UpSingular}}{}

	for _, id := range ids {
		obj := new({{$model.UpSingular}})
		obj.{{titleCase .Column}} = id
		objs = append(objs, obj)
	}

	return objs
}

{{- end}}

*/


func Listar{{$model.UpPlural}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {

	//{{$model.UpPlural}}(mods ...qm.QueryMod).All()
	Objs, err := {{$model.UpPlural}}().All(exec)
	if err == sql.ErrNoRows {
		//w.WriteHeader(http.StatusNoContent)
		//w.Write([]byte("[]"))
		responder.ListadoVacío(w)
		return
	} else if err != nil {
		//ResponseInternalServerError(w, err, "3583")
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	/*ObjsJSON, err := MarshalAndResponseOnError(w, Objs)
	if err != nil {
		//ResponseInternalServerError(w, err, "5292")
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write(ObjsJSON)*/

	responder.Listado(w, Objs)
}



/*




//
//
// Empieza plantilla genérica vacía...
//
//


<template>

	<div>
		<div class="row">
			<div class="col-xs-12 col-xs-12">
				<div class="form-group">
					<label> ooooooooooooooooooooo: </label>
					<select class="form-control" v-model="Data.ooooooooooooooooooooo">
						<option></option>
						<option v-for="{{`e in $root.Recursos.ooooooooooooooooooooo`}}" v-if="{{`e.enabled`}}" :value="{{`e.id`}}">{{`{{e.description}}`}}</option>
					</select>
				</div>
			</div>
			<div class="col-xs-12 col-xs-12">
				<div class="form-group">
					<label> ooooooooooooooooooooo </label>
					<input type="text" class="form-control" v-model="Data.ooooooooooooooooooooo" maxlength="100" placeholder="ooooooooooooooooooooo" required>
				</div>
			</div>
		</div>
	</div>

</template>


<script>
	var opcns = {
		data: function () {
			return {}
		},
		mixins: [Mixin{{$model.UpSingular}}],
		mounted: function(){
			//
		},
		methods: {
			//
		},
	}

</script>




*/

