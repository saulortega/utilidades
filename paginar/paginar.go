package paginar

import (
	"errors"
	"net/http"
	"strconv"
)

// Parámetros predeterminados.
var Params = struct {
	RowsPerPage string
	Descending  string
	SortBy      string
	Page        string
}{
	RowsPerPage: "rowsPerPage",
	Descending:  "descending",
	SortBy:      "sortBy",
	Page:        "page",
}

// Si SortingColumns es nil se asumirá cualquier parámetro recibido,
// lo cual es susceptible a inyección SQL.
// Si SortingColumns está vacío se ignorará el parámetro de ordenamiento.
type Instance struct {
	SortingColumns []string
	RowsPerPage    string
	Descending     string
	SortBy         string
	Page           string
}

// Datos de paginación.
type Pagination struct {
	Order  string
	Limit  int
	Offset int
}

// Crea una nueva instancia con los parámetros predeterminados.
func New() *Instance {
	var I = new(Instance)
	I.SortingColumns = []string{}
	I.RowsPerPage = Params.RowsPerPage
	I.Descending = Params.Descending
	I.SortBy = Params.SortBy
	I.Page = Params.Page
	return I
}

// Crea una nueva instancia con los parámetros predeterminados asignando columnas de ordenamiento posibles.
func NewWithSortingColumns(cols ...string) *Instance {
	var I = New()
	I.SortingColumns = cols
	return I
}

// Obtiene los datos de paginación de la solicitud web.
func (I *Instance) Paginar(r *http.Request) (*Pagination, error) {
	var P = new(Pagination)
	var err error

	lmt := r.FormValue(I.RowsPerPage)
	if lmt == "" {
		return P, errors.New("No rows per page received.")
	}

	P.Limit, err = strconv.Atoi(lmt)
	if err != nil {
		return P, err
	}

	pge := r.FormValue(I.Page)
	if len(pge) > 0 {
		pgn, err := strconv.Atoi(pge)
		if err != nil {
			return P, err
		}
		if pgn == 0 {
			pgn = 1
		}
		if pgn < 1 {
			return P, errors.New("Wrong page.")
		}

		P.Offset = (P.Limit * pgn) - pgn
	}

	srt := r.FormValue(I.SortBy)
	if len(srt) > 0 {
		sort := I.SortingColumns == nil || in(srt, I.SortingColumns)
		if sort {
			P.Order = srt

			var desc bool
			des := r.FormValue(I.Descending)
			if des != "" {
				desc, err = strconv.ParseBool(des)
				if err != nil {
					return P, err
				}
			}

			if desc {
				P.Order += " DESC"
			} else {
				P.Order += " ASC"
			}
		}
	}

	return P, nil
}

func in(col string, arr []string) bool {
	for _, c := range arr {
		if c == col {
			return true
		}
	}

	return false
}
