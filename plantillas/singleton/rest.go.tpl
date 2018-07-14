import (
	"errors"
	"fmt"
	"github.com/volatiletech/null"
	"github.com/saulortega/filtro"
	"github.com/volatiletech/sqlboiler/queries/qm"
	"net/http"
	"regexp"
	"strconv"
	"strings"
	"time"
)


func parseBoolFromForm(r *http.Request, field string, errorOnBlank bool) (bool, error) {
	var vo = strings.TrimSpace(r.FormValue(field))
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
	var vo = strings.TrimSpace(r.FormValue(field))
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
	var vo = strings.TrimSpace(r.FormValue(field))
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
	var vo = strings.TrimSpace(r.FormValue(field))
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
	var vo = strings.TrimSpace(r.FormValue(field))
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

func paginación(r *http.Request, columnas []string) ([]qm.QueryMod, error) {
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
		}
	}

	return qms, nil
}

func condiciones(r *http.Request, columnas ...filtro.Column) ([]qm.QueryMod, error) {
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

func in(S string, SS []string) bool {
	for _, s := range SS {
		if s == S {
			return true
		}
	}

	return false
}
