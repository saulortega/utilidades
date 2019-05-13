


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

var DespuésDeObtener{{$model.UpSingular}} = func(boil.ContextExecutor, *{{$model.UpSingular}}, *http.Request) error {
	return nil
}

var AntesDeListar{{$model.UpPlural}} = func(boil.ContextExecutor, *http.Request, *[]qm.QueryMod) error {
	return nil
}

var DespuésDeListar{{$model.UpPlural}} = func(boil.ContextExecutor, []*{{$model.UpSingular}}, *http.Request) error {
	return nil
}

var AntesDeEditar{{$model.UpSingular}} = func(boil.ContextTransactor, *{{$model.UpSingular}}, *http.Request) error {
	return nil
}

var DespuésDeEditar{{$model.UpSingular}} = func(boil.ContextTransactor, *{{$model.UpSingular}}, *http.Request) error {
	return nil
}

var AntesDeCrear{{$model.UpSingular}} = func(boil.ContextTransactor, *{{$model.UpSingular}}, *http.Request) error {
	return nil
}

var DespuésDeCrear{{$model.UpSingular}} = func(boil.ContextTransactor, *{{$model.UpSingular}}, *http.Request) error {
	return nil
}

var Reconstruir{{$model.UpSingular}}AlObtener = func(exec boil.ContextExecutor, Obj *{{$model.UpSingular}}) (interface{}, error) {
	return interface{}(Obj), nil
}

func Obtener{{$model.UpSingular}}(exec boil.ContextExecutor, w http.ResponseWriter, r *http.Request) {
	var obj = new({{$model.UpSingular}})
	var Obj interface{}
	var err error
	var llave string

	err = AntesDeTodo(exec, r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	err = AntesDeObtener(exec, r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	llave, err = LlaveDesdeURL(r)
	if err != nil || llave == "" {
		responder.LlaveNoRecibida(w)
		return
	}

	obj, err = Find{{$model.UpSingular}}(context.Background(), exec, llave)
	if err != nil {
		responder.NotFoundOrInternal(w, err, llave)
		return
	}

	err = DespuésDeObtener{{$model.UpSingular}}(exec, obj, r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	Obj, err = Reconstruir{{$model.UpSingular}}AlObtener(exec, obj)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	responder.Obtención(w, Obj, llave)
}

func Crear{{$model.UpSingular}}(exec boil.ContextExecutor, w http.ResponseWriter, r *http.Request) {
	var Obj = new({{$model.UpSingular}})
	var TX = new(sql.Tx)
	var err error

	err = AntesDeTodo(exec, r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	err = AntesDeCrear(exec, r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	err = Obj.Construir(r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	TX, err = exec.(*sql.DB).Begin()
	if err != nil {
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	err = Obj.Crear(exec, TX, w, r)
	if err != nil {
		TX.Rollback()
		return
	}

	err = TX.Commit()
	if err != nil {
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	responder.Creación(w, Obj.Llave)
}

// Como el anterior, pero varios registros idénticos con uno variable.
func Crear{{$model.UpPlural}}PorCampo(exec boil.ContextExecutor, w http.ResponseWriter, r *http.Request, campo string) {
	var Obj = new({{$model.UpSingular}})
	var TX = new(sql.Tx)
	var err error

	err = AntesDeTodo(exec, r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	err = AntesDeCrear(exec, r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	var vals = requestValoresString(r, campo)
	if len(vals) == 0 {
		responder.BadRequest(w, errors.New("El campo «" + strings.Replace(campo, "_", " ", -1) + "» es obligatorio."))
		return
	}

	err = Obj.Construir(r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	TX, err = exec.(*sql.DB).Begin()
	if err != nil {
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	for _, valor := range vals {
		obj := new({{$model.UpSingular}})
		*obj = *Obj //Copia

		err = establecerValorCampo(reflect.ValueOf(obj), campo, valor)
		if err != nil {
			responder.BadRequest(w, err)
			TX.Rollback()
			return
		}

		err = obj.Crear(exec, TX, w, r)
		if err != nil {
			// Respondido en obj.Crear
			TX.Rollback()
			return
		}
	}

	err = TX.Commit()
	if err != nil {
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	responder.Creación(w, "000000") // Pendiente lo de múltiples llaves
}

func (Obj *{{$model.UpSingular}}) Crear(exec boil.ContextExecutor, TX boil.ContextTransactor, w http.ResponseWriter, r *http.Request) error {
	var llave string
	var err error

	//llave, err = llaves.L6B(exec.(*sql.DB), "{{.Table.Name}}")
	llave, err = llaves.NuevaParaBD(exec.(*sql.DB), "{{.Table.Name}}", LongitudLlave)
	if err != nil {
		responder.InternalServerError(w)
		log.Println(err)
		return err
	}

	Obj.Llave = llave

	err = AntesDeCrear{{$model.UpSingular}}(TX, Obj, r)
	if err != nil {
		responder.BadRequest(w, err)
		return err
	}

	{{if $tieneFechaCreación -}}
	Obj.FechaCreación = time.Now()
	{{- end}}
	{{if $tieneFechaModificación -}}
	Obj.FechaModificación = time.Now()
	{{- end}}

	err = Obj.Insert(context.Background(), TX, boil.Infer()) // ---------------------------- pendiente ver si agregar lista blanca en vez del Infer -----------------------------
	if err != nil {
		responder.InternalServerError(w)
		log.Println(err)
		return err
	}

	err = DespuésDeCrear{{$model.UpSingular}}(TX, Obj, r)
	if err != nil {
		responder.BadRequest(w, err)
		return err
	}

	return nil
}

func Editar{{$model.UpSingular}}(exec boil.ContextExecutor, w http.ResponseWriter, r *http.Request) {
	var Obj = new({{$model.UpSingular}})
	var TX = new(sql.Tx)
	var err error
	var llave string

	err = AntesDeTodo(exec, r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	err = AntesDeEditar(exec, r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	llave, err = LlaveDesdeURL(r)
	if err != nil || llave == "" {
		responder.LlaveNoRecibida(w)
		return
	}

	Obj, err = Find{{$model.UpSingular}}(context.Background(), exec, llave)
	if err != nil {
		responder.NotFoundOrInternal(w, err, llave)
		return
	}

	err = Obj.Construir(r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	TX, err = exec.(*sql.DB).Begin()
	if err != nil {
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	err = AntesDeEditar{{$model.UpSingular}}(TX, Obj, r)
	if err != nil {
		responder.BadRequest(w, err)
		TX.Rollback()
		return
	}

	{{if $tieneFechaModificación -}}
	Obj.FechaModificación = time.Now()
	{{- end}}

	_, err = Obj.Update(context.Background(), TX, boil.Infer()) // ---------------------------- pendiente ver si agregar lista blanca en vez del Infer -----------------------------
	if err != nil {
		responder.InternalServerError(w)
		log.Println(err)
		TX.Rollback()
		return
	}

	err = DespuésDeEditar{{$model.UpSingular}}(TX, Obj, r)
	if err != nil {
		responder.BadRequest(w, err)
		TX.Rollback()
		return
	}

	err = TX.Commit()
	if err != nil {
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	responder.Edición(w, Obj.Llave)
}

func Eliminar{{$model.UpSingular}}(exec boil.ContextExecutor, w http.ResponseWriter, r *http.Request) {
	{{if $tieneFechaEliminación -}}
		Eliminar{{$model.UpSingular}}PorBD(exec, w, r)
	{{- else -}}
		Eliminar{{$model.UpSingular}}Real(exec, w, r)
	{{- end -}}
}

{{if $tieneFechaEliminación -}}
func Eliminar{{$model.UpSingular}}PorBD(exec boil.ContextExecutor, w http.ResponseWriter, r *http.Request) {
	var Obj = new({{$model.UpSingular}})
	var err error
	var llave string

	err = AntesDeTodo(exec, r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	err = AntesDeEliminar(exec, r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	llave, err = LlaveDesdeURL(r)
	if err != nil || llave == "" {
		responder.LlaveNoRecibida(w)
		return
	}

	Obj, err = Find{{$model.UpSingular}}(context.Background(), exec, llave)
	if err != nil {
		responder.NotFoundOrInternal(w, err, llave)
		return
	}

	Obj.FechaEliminación = null.NewTime(time.Now(), true)
	_, err = Obj.Update(context.Background(), exec, boil.Whitelist("deleted_at"))
	if err != nil {
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	responder.Eliminación(w, Obj.Llave)
}
{{- end}}

func Eliminar{{$model.UpSingular}}Real(exec boil.ContextExecutor, w http.ResponseWriter, r *http.Request) {
	var Obj = new({{$model.UpSingular}})
	var err error
	var llave string

	err = AntesDeTodo(exec, r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	err = AntesDeEliminar(exec, r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	llave, err = LlaveDesdeURL(r)
	if err != nil || llave == "" {
		responder.LlaveNoRecibida(w)
		return
	}

	Obj, err = Find{{$model.UpSingular}}(context.Background(), exec, llave)
	if err != nil {
		responder.NotFoundOrInternal(w, err, llave)
		return
	}

	_, err = Obj.Delete(context.Background(), exec)
	if err != nil {
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	responder.Eliminación(w, Obj.Llave)
}

{{/*

	{{- range $column := .Table.Columns -}}
	{{- $colAlias := $alias.Column $column.Name -}}
*/}}


func (o *{{$model.UpSingular}}) Construir(r *http.Request) error {
	var err error

	{{range $column := .Table.Columns }}
	{{- $colAlias := $model.Column $column.Name -}}
	{{- if eq (titleCase $column.Name) "Llave" "FechaCreación" "FechaModificación" "FechaEliminación" "AutorCreación" "AutorModificación" "AutorEliminación" "Contraseña"}}
	{{- else -}}
	{{- if eq $column.Type "string" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{$colAlias}} = r.FormValue("{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
	}
	{{else if eq $column.Type "bool" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{$colAlias}}, err = parseBoolFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$model.DownSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "int" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{$colAlias}}, err = parseIntFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$model.DownSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "int64" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{$colAlias}}, err = parseInt64FromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$model.DownSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "float64" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{$colAlias}}, err = parseFloat64FromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$model.DownSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "time.Time" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{$colAlias}}, err = parseTimeFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$model.DownSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.String" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{$colAlias}} = parseNullStringFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
	}
	{{else if eq $column.Type "null.Bool" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{$colAlias}}, err = parseNullBoolFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.Int" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{$colAlias}}, err = parseNullIntFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.Int64" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{$colAlias}}, err = parseNullInt64FromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.Float64" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{$colAlias}}, err = parseNullFloat64FromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.Time" -}}
	if !in("{{$column.Name}}", OmitirAlConstruir{{$model.UpSingular}}){
		o.{{$colAlias}}, err = parseNullTimeFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
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


func Listar{{$model.UpPlural}}(exec boil.ContextExecutor, w http.ResponseWriter, r *http.Request) {
	err := AntesDeTodo(exec, r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	err = AntesDeListar(exec, r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	filtrosPaginación, err := paginación(r, {{$model.DownSingular}}Columns, {{$tieneFechaCreación}})
	if err != nil {
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	var Cols = []filtro.Column{}

	{{range $column := .Table.Columns }}
	{{- $colAlias := $model.Column $column.Name -}}
	{{- if eq (titleCase $column.Name) "Llave" "FechaCreación" "FechaModificación" "FechaEliminación" "AutorCreación" "AutorModificación" "AutorEliminación" "Contraseña"}}
	{{- else -}}
	{{- if eq $column.Type "string" -}}
	col_{{$column.Name}} := filtro.InString("{{$column.Name}}")
	Cols = append(Cols, col_{{$column.Name}}...)
	col_{{$column.Name}}_like := filtro.Like("{{$column.Name}}")
	Cols = append(Cols, col_{{$column.Name}}_like...)
	{{else if eq $column.Type "bool" -}}
	col_{{$column.Name}} := filtro.Boolean("{{$column.Name}}")
	Cols = append(Cols, col_{{$column.Name}}...)
	{{else if eq $column.Type "int" -}}
	col_{{$column.Name}} := filtro.InInt64("{{$column.Name}}") // int
	Cols = append(Cols, col_{{$column.Name}}...)
	{{else if eq $column.Type "int64" -}}
	col_{{$column.Name}} := filtro.InInt64("{{$column.Name}}")
	Cols = append(Cols, col_{{$column.Name}}...)
	{{else if eq $column.Type "float64" -}}
	// float64 pendiente
	{{else if eq $column.Type "time.Time" -}}
	// time pendiente
	{{else if eq $column.Type "null.String" -}}
	col_{{$column.Name}} := filtro.InString("{{$column.Name}}")
	Cols = append(Cols, col_{{$column.Name}}...)
	col_{{$column.Name}}_like := filtro.Like("{{$column.Name}}")
	Cols = append(Cols, col_{{$column.Name}}_like...)
	{{else if eq $column.Type "null.Bool" -}}
	col_{{$column.Name}} := filtro.Boolean("{{$column.Name}}")
	Cols = append(Cols, col_{{$column.Name}}...)
	{{else if eq $column.Type "null.Int" -}}
	col_{{$column.Name}} := filtro.InInt64("{{$column.Name}}") // int
	Cols = append(Cols, col_{{$column.Name}}...)
	{{else if eq $column.Type "null.Int64" -}}
	col_{{$column.Name}} := filtro.InInt64("{{$column.Name}}")
	Cols = append(Cols, col_{{$column.Name}}...)
	{{else if eq $column.Type "null.Float64" -}}
	// float64 pendiente
	{{else if eq $column.Type "null.Time" -}}
	// time pendiente
	{{end -}}
	{{end -}}
	{{end}}

	filtros, err := condiciones(r, Cols...)
	if err != nil {
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	err = AntesDeListar{{$model.UpPlural}}(exec, r, &filtros)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}

	Total, err := {{$model.UpPlural}}(filtros...).Count(context.Background(), exec)
	if err != nil {
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	filtros = append(filtros, filtrosPaginación...)

	Objs, err := {{$model.UpPlural}}(filtros...).All(context.Background(), exec)
	if err == sql.ErrNoRows {
		responder.ListadoVacío(w)
		return
	} else if err != nil {
		responder.InternalServerError(w)
		log.Println(err)
		return
	}

	err = DespuésDeListar{{$model.UpPlural}}(exec, Objs, r)
	if err != nil {
		responder.BadRequest(w, err)
		return
	}


	responder.Listado(w, Objs, Total)
}





{{- if .Table.IsJoinTable -}}
{{- else -}}
	{{- $table := .Table -}}
	{{- range $rel := .Table.ToManyRelationships -}}
		{{- $ltable := $.Aliases.Table $rel.Table -}}
		{{- $ftable := $.Aliases.Table $rel.ForeignTable -}}
		{{- $relAlias := $.Aliases.ManyRelationship $rel.ForeignTable $rel.Name $rel.JoinTable $rel.JoinLocalFKeyName -}}
		{{- $col := $ltable.Column $rel.Column -}}
		{{- $fcol := $ftable.Column $rel.ForeignColumn -}}
		{{- $usesPrimitives := usesPrimitives $.Tables $rel.Table $rel.Column $rel.ForeignTable $rel.ForeignColumn -}}
		{{- $schemaForeignTable := $rel.ForeignTable | $.SchemaTable }}
		{{- $foreignPKeyCols := (getTable $.Tables $rel.ForeignTable).PKey.Columns }}
		{{- $tieneFeCre := eq (index $ftable.Columns "fecha_creación") "FechaCreación" -}}
		{{- $tieneFeMod := eq (index $ftable.Columns "fecha_modificación") "FechaModificación" -}}


// ===================================== $ltable : {{ $ltable }} ,,,, $ftable : {{ $ftable }} ,,,, $relAlias : {{ $relAlias }}
// 0000000000000 $fcol : $col : {{ $col }} ,,,, $fcol : {{ $fcol }} ,,,, $foreignPKeyCols : {{ $foreignPKeyCols }}
// yyyyyyyyyyyyy $rel.Table : {{$rel.Table}}
// zzzzzzzzzzzzz $rel : {{$rel}}
// zzzzzzzzzzz22 $rel.ForeignTable : {{$rel.ForeignTable}}
// zzzzzzzzzzz33 $ftable.Columns : {{$ftable.Columns}}

//{{/* range $column := .Table.Columns */}}
//{{/* else if eq $column.Type "null.String" */}}
//$ftable.Column $rel.ForeignColumn
//$ftable.Column.Type:: no
//$rel.Column:: {{$rel.Column}}
//$ftable.Column:: no
//$rel.ForeignColumn.Type:: no
//$rel.Table.Columns:: {{/* $rel.Table.Columns */}}
//$rel.ForeignTable.Columns:: {{/* $rel.ForeignTable.Columns */}}
//$table.Columns:: {{$table.Columns}}
//$ftable.Columns:: {{$ftable.Columns}}
//$ltable.Columns:: {{$ltable.Columns}}

// ñññññ


//func (o *{{$model.UpSingular}}) Agregar{{$ftable.UpPlural}}(TX boil.ContextTransactor, hijos ...*{{$ftable.UpSingular}}) error {
func (o *{{$model.UpSingular}}) Agregar{{$relAlias.Local}}(TX boil.ContextTransactor, hijos ...*{{$ftable.UpSingular}}) error {
	{{if $tieneFeCre -}}
	var ahora = time.Now()
	{{- else if $tieneFeMod -}}
	var ahora = time.Now()
	{{- end}}

	for i, _ := range hijos {
		//hijos[i].{{$fcol}} = o.Llave
		{{range $clm := (getTable $.Tables $rel.ForeignTable).Columns -}}
			{{- if eq $clm.Name $rel.ForeignColumn -}}
				{{- if eq $clm.Type "null.String" -}}
				hijos[i].{{$fcol}} = null.NewString(o.Llave, true)
				{{else -}}
				hijos[i].{{$fcol}} = o.Llave
				{{end}}
			{{end}}
		{{end}}

		var llave string
		var err error

		llave, err = llaves.NuevaParaBD(BD, "{{$rel.ForeignTable}}", LongitudLlave)
		if err != nil {
			log.Println(err)
			return err
		}

		hijos[i].Llave = llave

		{{if $tieneFeCre -}}
		hijos[i].FechaCreación = ahora
		{{- end}}
		{{if $tieneFeMod -}}
		hijos[i].FechaModificación = ahora
		{{- end}}

		err = hijos[i].Insert(context.Background(), TX, boil.Infer())
		if err != nil {
			log.Println(err)
			return err
		}
	}

	return nil
}

	{{- end -}}{{- /* range relationships */ -}}
{{- end -}}{{- /* if IsJoinTable */ -}}

//
//

