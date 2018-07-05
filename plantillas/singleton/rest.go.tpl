import (
	//"database/sql"
	//"encoding/json"
	"errors"
	//"fmt"
	"gopkg.in/volatiletech/null.v7"
	"log"
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
		if errorOnBlank {
			err = errors.New("field «"+field+"» can not be blank")
		}
		return vc, err
	}

	vc, err = strconv.ParseBool(vo)
	if err != nil {
		err = errors.New("field «"+field+"» has a wrong value")
	}

	return vc, err
}

func parseIntFromForm(r *http.Request, field string, errorOnBlank bool) (int, error) {
	var vo = strings.TrimSpace(r.FormValue(field))
	var err error
	var vc int

	if vo == "" {
		if errorOnBlank {
			err = errors.New("field «"+field+"» can not be blank")
		}
		return vc, err
	}

	vc, err = strconv.Atoi(vo)
	if err != nil {
		err = errors.New("field «"+field+"» has a wrong value")
	}

	return vc, err
}

func parseInt64FromForm(r *http.Request, field string, errorOnBlank bool) (int64, error) {
	var vo = strings.TrimSpace(r.FormValue(field))
	var err error
	var vc int64

	if vo == "" {
		if errorOnBlank {
			err = errors.New("field «"+field+"» can not be blank")
		}
		return vc, err
	}

	vc, err = strconv.ParseInt(vo, 10, 64)
	if err != nil {
		err = errors.New("field «"+field+"» has a wrong value")
	}

	return vc, err
}

func parseFloat64FromForm(r *http.Request, field string, errorOnBlank bool) (float64, error) {
	var vo = strings.TrimSpace(r.FormValue(field))
	var err error
	var vc float64

	if vo == "" {
		if errorOnBlank {
			err = errors.New("field «"+field+"» can not be blank")
		}
		return vc, err
	}

	vc, err = strconv.ParseFloat(vo, 64)
	if err != nil {
		err = errors.New("field «"+field+"» has a wrong value")
	}

	return vc, err
}

func parseTimeFromForm(r *http.Request, field string, errorOnBlank bool) (time.Time, error) {
	var vo = strings.TrimSpace(r.FormValue(field))
	var err error
	var vc time.Time

	if vo == "" {
		if errorOnBlank {
			err = errors.New("field «"+field+"» can not be blank")
		}
		return vc, err
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
		err = errors.New("field «"+field+"» has a wrong value")
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
//
//
//

/*
//func ResponseFindError(w http.ResponseWriter, id int64, err error) {
func ResponseFindError(w http.ResponseWriter, pk interface{}, err error) {
	w.Header().Set("X-Id", fmt.Sprintf("%v", pk))
	if err == sql.ErrNoRows {
		w.WriteHeader(http.StatusNotFound) //404
		w.Write([]byte("Not found"))
	} else {
		w.WriteHeader(http.StatusInternalServerError) //500
		w.Write([]byte("It could not be obtained. Try again later. [2892]"))
	}

	log.Println(err)
}

//func ResponseFindSuccess(w http.ResponseWriter, id int64, Obj interface{}) {
func ResponseFindSuccess(w http.ResponseWriter, pk interface{}, Obj interface{}) {
	ObjJSON, err := MarshalAndResponseOnError(w, Obj)
	if err != nil {
		return
	}

	w.Header().Set("X-Id", fmt.Sprintf("%v", pk))
	w.WriteHeader(http.StatusOK)
	w.Write(ObjJSON)
}


//
//
//

func MarshalAndResponseOnError(w http.ResponseWriter, Obj interface{}) ([]byte, error) {
	JSON, err := json.Marshal(Obj)
	if err != nil {
		ResponseInternalServerError(w, err, "5289")
		return JSON, err
	}

	return JSON, nil
}
*/

//
//
//

/*
func ResponseInternalServerError(w http.ResponseWriter, err error, cod string) {
	w.WriteHeader(http.StatusInternalServerError)
	w.Write([]byte("An error happened. Try again. ["+cod+"]"))
	log.Println(err)
}

func ResponseBadRequest(w http.ResponseWriter, err error) {
	w.WriteHeader(http.StatusBadRequest)
	w.Write([]byte(err.Error()))
}

func ResponseNoID(w http.ResponseWriter) {
	w.WriteHeader(http.StatusBadRequest) //400
	w.Write([]byte("ID not received or invalid"))
}
*/

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

/*func GetIDFromURL(r *http.Request) (int64, error) {
	p := strings.Split(r.URL.Path, "/")
	s := strings.TrimSpace(p[len(p)-1])
	return strconv.ParseInt(s, 10, 64)
}*/

func IDsFromPostForm(r *http.Request, key string) ([]int64, error) {
	var ids = []int64{}

	for _, i := range r.PostForm[key] {
		if i == "" {
			continue
		}

		id, er := strconv.ParseInt(i, 10, 64)
		if er != nil {
			log.Println(er)
			return ids, errors.New("wrong id [9347]")
		} else if id == 0 {
			return ids, errors.New("wrong id [3962]")
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