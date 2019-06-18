import (
	"errors"
	"fmt"
	"github.com/volatiletech/null"
	"github.com/saulortega/filtro"
	"github.com/volatiletech/sqlboiler/queries/qm"
	"net/http"
	"reflect"
	"regexp"
	"strconv"
	"strings"
	"time"
)


func parseBoolFromForm(r *http.Request, field string, errorOnBlank bool) (bool, error) {
	var vo = requestValStr(r, field)
	var err error
	var vc bool

	if vo == "" {
		return vc, errorCampoVacíoSiNoNulo(field, errorOnBlank)
	}

	vc, err = strconv.ParseBool(vo)
	if err != nil {
		err = errorValorErróneo(field)
	}

	return vc, err
}

func parseIntFromForm(r *http.Request, field string, errorOnBlank bool) (int, error) {
	var vo = requestValStr(r, field)
	var err error
	var vc int

	if vo == "" {
		return vc, errorCampoVacíoSiNoNulo(field, errorOnBlank)
	}

	vc, err = strconv.Atoi(vo)
	if err != nil {
		err = errorValorErróneo(field)
	}

	return vc, err
}

func parseInt64FromForm(r *http.Request, field string, errorOnBlank bool) (int64, error) {
	var vo = requestValStr(r, field)
	var err error
	var vc int64

	if vo == "" {
		return vc, errorCampoVacíoSiNoNulo(field, errorOnBlank)
	}

	vc, err = strconv.ParseInt(vo, 10, 64)
	if err != nil {
		err = errorValorErróneo(field)
	}

	return vc, err
}

func parseFloat64FromForm(r *http.Request, field string, errorOnBlank bool) (float64, error) {
	var vo = requestValStr(r, field)
	var err error
	var vc float64

	if vo == "" {
		return vc, errorCampoVacíoSiNoNulo(field, errorOnBlank)
	}

	vc, err = strconv.ParseFloat(vo, 64)
	if err != nil {
		err = errorValorErróneo(field)
	}

	return vc, err
}

func parseTimeFromForm(r *http.Request, field string, errorOnBlank bool) (time.Time, error) {
	var vo = requestValStr(r, field)
	var err error
	var vc time.Time

	if vo == "" {
		return vc, errorCampoVacíoSiNoNulo(field, errorOnBlank)
	}

	if regexp.MustCompile("^[012][0-9]:[0-5][0-9]$").MatchString(vo) {
		vc, err = time.Parse("15:04", vo)
	} else if regexp.MustCompile("^[012][0-9]:[0-5][0-9]:[0-5][0-9]$").MatchString(vo) {
		vc, err = time.Parse("15:04:05", vo)
	} else if regexp.MustCompile("^[012][0-9]:[0-5][0-9] [AP]M$").MatchString(vo) {
		vc, err = time.Parse("15:04 PM", vo)
	} else if regexp.MustCompile("^[012][0-9]:[0-5][0-9]:[0-5][0-9] [AP]M$").MatchString(vo) {
		vc, err = time.Parse("15:04:05 PM", vo)
	} else if regexp.MustCompile("^[0-9]{4}-[01][0-9]-[0-3][0-9]$").MatchString(vo) { // aaaa-mm-dd
		vc, err = time.Parse("2006-01-02", vo)
	} else if regexp.MustCompile("^[0-3][0-9]/[01][0-9]/[0-9]{4}$").MatchString(vo) { // dd/mm/aaaa
		vc, err = time.Parse("02/01/2006", vo)
	} else if regexp.MustCompile("^[0-9]{4}-[01][0-9]-[0-3][0-9] [012][0-9]:[0-5][0-9]:[0-5][0-9]$").MatchString(vo) { // aaaa-mm-dd HH:MM:SS
		vc, err = time.Parse("2006-01-02 15:04:05", vo)
	} else if regexp.MustCompile("^[0-3][0-9]/[01][0-9]/[0-9]{4} [012][0-9]:[0-5][0-9]:[0-5][0-9]$").MatchString(vo) { // dd/mm/aaaa HH:MM:SS
		vc, err = time.Parse("02/01/2006 15:04:05", vo)
	} else if regexp.MustCompile("^[0-9]{4}-[01][0-9]-[0-3][0-9]T[012][0-9]:[0-5][0-9]$").MatchString(vo) { // aaaa-mm-ddTHH:MM
		vc, err = time.Parse("2006-01-02T15:04", vo)
	} else if regexp.MustCompile("^[0-9]{4}-[01][0-9]-[0-3][0-9]T[012][0-9]:[0-5][0-9]:[0-5][0-9].").MatchString(vo) {
		pdzs := strings.Split(vo, ".")
		vc, err = time.Parse("2006-01-02T15:04:05", pdzs[0])
	} else {
		err = errorValorErróneo(field)
	}

	return vc, err
}

func parseNullStringFromForm(r *http.Request, field string) null.String {
	v := strings.TrimSpace(r.FormValue(field))
	return null.NewString(v, v != "")
}

func parseNullBoolFromForm(r *http.Request, field string) (null.Bool, error) {
	v, err := parseBoolFromForm(r, field, false)
	return null.NewBool(v, (err == nil && strings.TrimSpace(r.FormValue(field)) != "")), err
}

func parseNullIntFromForm(r *http.Request, field string) (null.Int, error) {
	v, err := parseIntFromForm(r, field, false)
	return null.NewInt(v, (err == nil && strings.TrimSpace(r.FormValue(field)) != "")), err
}

func parseNullInt64FromForm(r *http.Request, field string) (null.Int64, error) {
	v, err := parseInt64FromForm(r, field, false)
	return null.NewInt64(v, (err == nil && strings.TrimSpace(r.FormValue(field)) != "")), err
}

func parseNullFloat64FromForm(r *http.Request, field string) (null.Float64, error) {
	v, err := parseFloat64FromForm(r, field, false)
	return null.NewFloat64(v, (err == nil && strings.TrimSpace(r.FormValue(field)) != "")), err
}

func parseNullTimeFromForm(r *http.Request, field string) (null.Time, error) {
	v, err := parseTimeFromForm(r, field, false)
	return null.NewTime(v, (err == nil && strings.TrimSpace(r.FormValue(field)) != "")), err
}

//
//
//

func LlaveDesdeURL(r *http.Request) (string, error) {
	p := strings.Split(r.URL.Path, "/")
	s := strings.TrimSpace(p[len(p)-1])
	if s == "" {
		return s, errors.New("No se recibió el identificador.")
	}

	return s, nil
}

func requestValoresString(r *http.Request, ll string) []string {
	var vals = []string{}

	for _, v := range r.PostForm[ll] {
		val := strings.TrimSpace(v)
		if val == "" {
			continue
		}

		vals = append(vals, val)
	}

	return vals
}

func requestValStr(r *http.Request, field string) string {
	var vo = strings.TrimSpace(r.FormValue(field))
	if vo == "null" {
		vo = ""
	}

	return vo
}

/*
func requestValoresInt64(r *http.Request, ll string) ([]int64, error) {
	var valsString = requestValoresString(r, ll)
	var vals = []int64{}

	for _, v := range valsString {
		val, err := strconv.ParseInt(v, 10, 64)
		if err != nil || val == 0 {
			return vals, errors.New("Número erróneo. [4568]")
		}

		vals = append(vals, val)
	}

	return vals, nil
}

func requestValoresInt(r *http.Request, ll string) ([]int, error) {
	var valsString = requestValoresString(r, ll)
	var vals = []int{}

	for _, v := range valsString {
		val, err := strconv.Atoi(v)
		if err != nil || val == 0 {
			return vals, errors.New("Número erróneo. [2974]")
		}

		vals = append(vals, val)
	}

	return vals, nil
}

func requestValoresFloat64(r *http.Request, ll string) ([]float64, error) {
	var valsString = requestValoresString(r, ll)
	var vals = []float64{}

	for _, v := range valsString {
		val, err := strconv.ParseFloat(v, 64)
		if err != nil || val == 0 {
			return vals, errors.New("Número erróneo. [2974]")
		}

		vals = append(vals, val)
	}

	return vals, nil
}
*/

/*func StringKeyFromURL(r *http.Request) (string, error) {
	p := strings.Split(r.URL.Path, "/")
	s := strings.TrimSpace(p[len(p)-1])
	if s == "" {
		return s, errors.New("Key no received")
	}

	return s, nil
}

func Int64KeyFromURL(r *http.Request) (int64, error) {
	s, err := StringKeyFromURL(r)
	if err != nil  {
		return 0, err
	}

	return strconv.ParseInt(s, 10, 64)
}*/

/*
func IDsFromPostForm(r *http.Request, key string) ([]int64, error) {
	var ids = []int64{}

	for _, i := range r.PostForm[key] {
		if i == "" {
			continue
		}

		id, er := strconv.ParseInt(i, 10, 64)
		if er != nil {
			return ids, errors.New("Número erróneo. [9347]")
		} else if id == 0 {
			return ids, errors.New("Número erróneo. [3962]")
		}

		ids = append(ids, id)
	}

	return ids, nil
}

func NullIDsFromPostForm(r *http.Request, key string) ([]null.Int64, error) {
	var nullIds = []null.Int64{}

	ids, err := IDsFromPostForm(r, key)
	if err != nil {
		return nullIds, err
	}

	for _, id := range ids {
		nullIds = append(nullIds, null.NewInt64(id, true))
	}

	return nullIds, nil
}
*/

//
//
//

func errorValorErróneo(col string) error {
	return errors.New("El campo «"+strings.Replace(col, "_", " ", -1)+"» tiene un valor erróneo.")
}

func errorCampoVacío(col string) error {
	return errors.New("El campo «"+strings.Replace(col, "_", " ", -1)+"» no puede estar vacío.")
}

func errorCampoVacíoSiNoNulo(col string, noNulo bool) error {
	if noNulo {
		return errorCampoVacío(col)
	}

	return nil
}

//
//
//

func FiltroPaginación(r *http.Request, columnas []string, hayFechaCreación bool) ([]qm.QueryMod, error) {
	var qms = []qm.QueryMod{}

	I := filtro.NewPagingAndSorting(columnas...)

	pgncn, err := I.Parse(r)
	if err != nil {
		return qms, err
	}

	if pgncn != nil {
		qms = append(qms, qm.Limit(pgncn.Limit))

		if pgncn.Offset > 0 {
			qms = append(qms, qm.Offset(pgncn.Offset))
		}

		if len(pgncn.Order) > 0 {
			qms = append(qms, qm.OrderBy(pgncn.Order))
		} else if hayFechaCreación {
			qms = append(qms, qm.OrderBy("fecha_creación DESC"))
		}
	}

	return qms, nil
}

func FiltroCondiciones(r *http.Request, columnas ...filtro.Column) ([]qm.QueryMod, error) {
	var qms = []qm.QueryMod{}

	F := filtro.NewSearching(columnas)

	condcns, err := F.Parse(r)
	if err != nil {
		return qms, err
	}

	var likesClauses = []string{}
	var likesArgs = []interface{}{}
	for _, c := range condcns {
		switch c.SearchType() {
		case filtro.SearchTypeIn:
			qms = append(qms, qm.WhereIn(c.Clause, c.Args...))
		case filtro.SearchTypeBoolean:
			qms = append(qms, qm.Where(c.Clause))
		case filtro.SearchTypeLike:
			likesClauses = append(likesClauses, c.Clause)
			likesArgs = append(likesArgs, c.Args...)
		}
	}

	if len(likesArgs) > 0 {
		qms = append(qms, qm.Where(fmt.Sprintf(`(%s)`, strings.Join(likesClauses, " OR ")), likesArgs...))
	}

	return qms, nil
}

func init() {
	filtro.Params.Search = "buscar"
}

//
//
//

// Establecer un campo a una estructura. Sólo string, int, int64, float64.
func establecerValorCampo(value reflect.Value, campo string, valor string) error {
	campo = columnaCampo(campo)
	var elem = value.Elem()

	var field = elem.FieldByName(campo)
	if !field.IsValid() || !field.CanSet() {
		return errors.New("Ocurrió un error. Intente de nuevo más tarde. [6392]")
	}

	switch field.Kind() {
	case reflect.String:
		field.SetString(valor)
	case reflect.Int64:
		vInt64, err := strconv.ParseInt(valor, 10, 64)
		if err != nil || vInt64 == 0 {
			return errors.New("Valor erróneo. [8352]")
		}
		field.SetInt(vInt64)
	case reflect.Int:
		vInt, err := strconv.Atoi(valor)
		if err != nil || vInt == 0 {
			return errors.New("Valor erróneo. [3963]")
		}
		field.SetInt(int64(vInt))
	case reflect.Float64:
		vFloat64, err := strconv.ParseFloat(valor, 64)
		if err != nil || vFloat64 == 0 {
			return errors.New("Valor erróneo. [8522]")
		}
		field.SetFloat(vFloat64)
	default:
		return errors.New("Ocurrió un error. Intente de nuevo más tarde. [2641]")
	}

	return nil
}

func columnaCampo(c string) string {
	var pdzs = []string{}
	for _, pdz := range strings.Split(strings.TrimSpace(c), "_") {
		pdzs = append(pdzs, strings.Title(pdz))
	}

	return strings.Join(pdzs, "")
}

//
//
//

func in(S string, SS []string) bool {
	for _, s := range SS {
		if s == S {
			return true
		}
	}

	return false
}
