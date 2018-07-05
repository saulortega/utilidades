{{- $model := .Aliases.Table .Table.Name -}}

var Mixin{{$model.UpSingular}} = {
	data: function () {
		return {
			recurso: '/{{.Table.Name}}',
			datos: {
				{{- range $column := .Table.Columns -}}
				{{- if eq (titleCase $column.Name) "FechaEliminación" -}}
				{{- else}}
				{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}: '',
				{{- end}}
				{{- end}}
			},
			{{range .Table.FKeys -}}
			{{- $ftable := $.Aliases.Table .ForeignTable -}}
			{{$ftable.UpSingular}}: {},
			{{end -}}

			{{range .Table.ToManyRelationships -}}
			{{- $ftable := $.Aliases.Table .ForeignTable -}}
			{{$ftable.UpPlural}}: [],
			{{end}}
		}
	},
	mixins: [MixinSingular],
	methods: {
		{{range .Table.FKeys -}}
		{{- $ftable := $.Aliases.Table .ForeignTable -}}
		obtener{{$ftable.UpSingular}}: function(){
			return new Promise( (resolve, reject) => {
				if(!this.datos.{{.Column}}){
					this.{{$ftable.UpSingular}} = {}
					resolve()
					return
				}

				{{$ftable.UpSingular}}.Get(this.datos.{{.Column}}).then( res => {
					console.log('resssssssssss sing vue ', res)
					this.{{$ftable.UpSingular}} = res.data || {}
					resolve()
				}).catch( res => {
					reject()
				})
			})
		},
		{{end -}}

		{{range .Table.ToManyRelationships -}}
		{{- $ftable := $.Aliases.Table .ForeignTable -}}
		obtener{{$ftable.UpPlural}}: function(){
			return new Promise( (resolve, reject) => {
				if(!this.datos.id){
					this.{{$ftable.UpPlural}} = []
					resolve()
					return
				}

				{{$ftable.UpPlural}}.Get({'{{.ForeignColumn}}': this.datos.id}).then( res => {
					console.log('resssssssssss plur vue ', res)
					this.{{$ftable.UpPlural}} = res.data || []
					resolve()
				}).catch( res => {
					reject()
				})
			})
		},
		{{end}}
	},
}

