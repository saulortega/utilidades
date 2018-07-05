package filtro

import (
	"net/http"
	"strconv"
	"strings"
)

const (
	columnaString int = iota
	columnaInt64
	columnaBool
)

type Columna struct {
	tipo   int
	nombre string
}

func String(cols ...string) []Columna {
	return columnasTipo(columnaString, cols)
}

func Int64(cols ...string) []Columna {
	return columnasTipo(columnaInt64, cols)
}

func Bool(cols ...string) []Columna {
	return columnasTipo(columnaBool, cols)
}

func columnasTipo(tipo int, cols ...string) []Columna {
	var Cols = []Columna{}

	for _, c := range cols {
		col := strings.TrimSpace(c)
		if col == "" {
			continue
		}

		Col := Columna{tipo, col}
		Cols = append(Cols, Col)
	}

	return Cols
}

//
//
//

func VlrsString(r *http.Request, col string) []string {
	var vlrs = []string{}

	if _, exte := r.Form[col]; !exte {
		col = col + "[]"
	}

	for _, v := range r.Form[col] {
		val := strings.TrimSpace(v)
		if val == "" {
			continue
		}

		vlrs = append(vlrs, val)
	}

	return vlrs, nil
}

func VlrsInt64(r *http.Request, col string) ([]int64, error) {
	var vlrsStr = VlrsString(r, col)
	var vlrs = []int64{}

	for _, v := range vlrsStr {
		i, err := strconv.ParseInt(v, 10, 64)
		if err != nil {
			return vlrs, errors.New("Valores no válidos para el parámetro «" + col + "»")
		}

		vlrs = append(vlrs, i)
	}

	return vlrs, nil
}

// El segundo Bool indica si hay un valor presente.
// Se debe evaluar primero el error, y luego el segundo bool.
func VlrBool(r *http.Request, col string) (bool, bool, error) {
	var val = r.FormValue(col)
	if val == "" {
		return false, false, nil
	}

	var vlr, err = strconv.ParseBool(val)
	if err != nil {
		return false, true, errors.New("Valores no válidos para el parámetro «" + col + "»")
	}

	return vlr, true, nil
}

// Sólo valores mayores o iguales a cero.
func VlrsInt64P(r *http.Request, col string) ([]int64, error) {
	return int64Restringido(r, col, 0)
}

// Sólo valores mayores a cero.
func VlrsInt64PNZ(r *http.Request, col string) ([]int64, error) {
	return int64Restringido(r, col, 1)
}

func vlrsInt64Restringido(r *http.Request, col string, min int) ([]int64, error) {
	var vlrs, err = VlrsInt64(r, col)
	if err != nil {
		return vlrs, err
	}

	for _, in := range vlrs {
		if in < min {
			return vlrs, errors.New("Valores no válidos para el parámetro «" + col + "»")
		}
	}

	return vlrs, nil
}
