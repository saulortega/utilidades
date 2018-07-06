package filtro

import (
	//"errors"
	"fmt"
	"net/http"
	//"strconv"
	//"strings"
)

/*type TipoCndcn int

const (
	In TipoCndcn = iota
	Boolean
)*/

type Instancia struct {
	Columnas []Columna
}

type Condición struct {
	Declaración string
	Parámetros  []interface{}
}

/*
type Condición interface {
	Condición()
}

type CondiciónIn struct {
	Columna    string
	Parámetros []interface{}
}

func (c *CondiciónIn) Condición() {
	//
}

type CondiciónBoolean struct {
	Columna string
	Boolean bool
}

func (c *CondiciónBoolean) Condición() {
	//
}*/

//

//
//
//

func Nuevo(gruposColumnas ...[]Columna) *Instancia {
	var I = new(Instancia)
	I.Columnas = []Columna{}

	for _, GC := range gruposColumnas {
		for _, C := range GC {
			I.Columnas = append(I.Columnas, C)
		}
	}

	return I
}

func (I *Instancia) String(cols ...string) {
	I.Columnas = append(I.Columnas, String(cols...)...)
}

func (I *Instancia) Int64(cols ...string) {
	I.Columnas = append(I.Columnas, Int64(cols...)...)
}

func (I *Instancia) Bool(cols ...string) {
	I.Columnas = append(I.Columnas, Bool(cols...)...)
}

func (I *Instancia) Condiciones(r *http.Request /*, gruposColumnas ...[]Columna*/) ([]*Condición, error) {
	var condiciones = []*Condición{}
	/*var columnas = []Columna{}

	for _, GC := range gruposColumnas {
		for _, C := range GC {
			columnas = append(columnas, C)
		}
	}

	if len(columnas) == 0 {
		return condiciones, nil
	}*/

	for _, col := range I.Columnas {
		switch col.tipo {
		case columnaString:
			//VlrsString(r, col.nombre) //[]string
			//CndcnString(r, col.nombre) //(string, []interface{})
			/*C := CondiciónInString(r, col.nombre) //Condición*/
			C := CndcnString(r, col.nombre) //Condición
			if C != nil {
				condiciones = append(condiciones, C)
			}
		case columnaInt64:
			//VlrsInt64(r, col.nombre) //([]int64, error)
			//CndcnInt64(r, col.nombre) //(string, []interface{}, error)
			/*C, err := CondiciónInInt64(r, col.nombre) //(Condición, error)*/
			C, err := CndcnInt64(r, col.nombre) //(Condición, error)
			if err != nil {
				return condiciones, err
			} else if C != nil {
				condiciones = append(condiciones, C)
			}
		case columnaBool:
			//VlrBool(r, col.nombre) //(bool, bool, error)
			//CndcnBool(r, col.nombre) //(string, error)
			/*C, err := CondiciónBool(r, col.nombre) //(Condición, error)*/
			C, err := CndcnBool(r, col.nombre) //(Condición, error)
			if err != nil {
				return condiciones, err
			} else if C != nil {
				condiciones = append(condiciones, C)
			}
		}
	}

	return condiciones, nil
}

// clausula o condicion --- palabras a usar --

/*
func CndcnString(r *http.Request, col string) (string, []interface{}) {
	var vlrs = VlrsString(r, col)
	var prmtrs = []interface{}{}
	var ors = []string{}

	if len(vlrs) == 0 {
		return "", prmtrs
	}

	for _, vlr := range vlrs {
		or := fmt.Sprintf(`%s = ?`, col)
		ors = append(ors, or)
		prmtrs = append(prmtrs, interface{}(vlr))
	}

	return fmt.Sprintf(`(%s)`, strings.Join(ors, " OR ")), prmtrs
}

func vlrsStringPrmtrs(vlrs []string) []interface{} {
	var prmtrs = []interface{}{}

	for _, vlr := range vlrs {
		prmtrs = append(prmtrs, interface{}(vlr))
	}

	return prmtrs
}
*/

/*func CondiciónInString(r *http.Request, col string) Condición {
	var vlrs = VlrsString(r, col)
	if len(vlrs) == 0 {
		return nil
	}

	var C = CondiciónIn{}
	C.Columna = col
	C.Parámetros = []interface{}{}

	for _, vlr := range vlrs {
		C.Parámetros = append(C.Parámetros, interface{}(vlr))
	}

	return C
}

func CondiciónInInt64(r *http.Request, col string) (Condición, error) {
	var vlrs, err = VlrsInt64(r, col)
	if err != nil {
		return nil, err
	} else if len(vlrs) == 0 {
		return nil, nil
	}

	var C = CondiciónIn{}
	C.Columna = col
	C.Parámetros = []interface{}{}

	for _, vlr := range vlrs {
		C.Parámetros = append(C.Parámetros, interface{}(vlr))
	}

	return C
}

func CondiciónBool(r *http.Request, col string) (Condición, error) {
	var vlr, prsnte, err = VlrBool(r, col)
	if err != nil {
		return nil, err
	} else if !prsnte {
		return nil, nil
	}

	var C = CondiciónBoolean{}
	C.Columna = col
	C.Boolean = vlr

	return C, nil
}*/

/*func CndcnString(r *http.Request, col string) (string, []interface{}) {
	var vlrs = VlrsString(r, col)
	var prmtrs = []interface{}{}
	if len(vlrs) == 0 {
		return "", prmtrs
	}

	for _, vlr := range vlrs {
		prmtrs = append(prmtrs, interface{}(vlr))
	}

	var cndcn = fmt.Sprintf(`%s IN ?`, col)

	return cndcn, prmtrs
}

func CndcnInt64(r *http.Request, col string) (string, []interface{}, error) {
	var prmtrs = []interface{}{}
	var vlrs, err = VlrsInt64(r, col)
	if err != nil {
		return "", prmtrs, err
	} else if len(vlrs) == 0 {
		return "", prmtrs, nil
	}

	for _, vlr := range vlrs {
		prmtrs = append(prmtrs, interface{}(vlr))
	}

	var cndcn = fmt.Sprintf(`%s IN ?`, col)

	return cndcn, prmtrs, nil
}

func CndcnBool(r *http.Request, col string) (string, error) {
	var vlr, prsnte, err = VlrBool(r, col)
	if err != nil {
		return "", err
	} else if !prsnte {
		return "", nil
	}

	var cndcn = col
	if !vlr {
		cndcn = fmt.Sprintf(`NOT %s`, col)
	}

	return cndcn, nil
}*/

func CndcnString(r *http.Request, col string) *Condición {
	var C = new(Condición)
	C.Parámetros = []interface{}{}

	var vlrs = VlrsString(r, col)
	if len(vlrs) == 0 {
		return nil
	}

	for _, vlr := range vlrs {
		C.Parámetros = append(C.Parámetros, interface{}(vlr))
	}

	C.Declaración = fmt.Sprintf(`%s IN ?`, col)

	return C
}

func CndcnInt64(r *http.Request, col string) (*Condición, error) {
	var C = new(Condición)
	C.Parámetros = []interface{}{}

	var vlrs, err = VlrsInt64(r, col)
	if err != nil {
		return nil, err
	} else if len(vlrs) == 0 {
		return nil, nil
	}

	for _, vlr := range vlrs {
		C.Parámetros = append(C.Parámetros, interface{}(vlr))
	}

	C.Declaración = fmt.Sprintf(`%s IN ?`, col)

	return C, nil
}

func CndcnBool(r *http.Request, col string) (*Condición, error) {
	var vlr, prsnte, err = VlrBool(r, col)
	if err != nil {
		return nil, err
	} else if !prsnte {
		return nil, nil
	}

	var cndcn = col
	if !vlr {
		cndcn = fmt.Sprintf(`NOT %s`, col)
	}

	var C = new(Condición)
	C.Declaración = cndcn
	C.Parámetros = []interface{}{}

	return C, nil
}

//
//
//
