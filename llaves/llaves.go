package llaves

import (
	"database/sql"
	"errors"
	"fmt"
	_ "github.com/lib/pq"
	"log"
	"math/rand"
	"time"
)

var base58 = []byte("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")

func L6() string {
	return Nueva(6)
}

func L6B(BD *sql.DB, tabla string) (string, error) {
	return NuevaParaBD(BD, tabla, 6)
}

//Con 6 caracteres: 38.068'692.544
//Con 9 caracteres: 7.427'658.700'000.000
//Con 10 caracteres: 430.804'210.000'000.000
//Con 12 caracteres: 1.449'225.400'000.000'000.000
func Nueva(lgtd int) string {
	rand.Seed(time.Now().UnixNano())
	var llave = make([]byte, lgtd)
	var reps int

	for i := range llave {
		llave[i] = base58[rand.Intn(len(base58))]
	}

	for i := range llave {
		if i >= 1 {
			if llave[i] == llave[i-1] {
				reps++
			} else {
				break
			}
		}
	}

	if reps >= 4 {
		return Nueva(lgtd)
	}

	return string(llave)
}

func NuevaParaBD(BD *sql.DB, tabla string, lgtd int) (string, error) {
	var llave string
	var err error

	var q = fmt.Sprintf("SELECT COUNT(*) FROM %s WHERE llave = $1 LIMIT 1;", tabla)
	for i := 0; i <= 50; i++ {
		n := 0
		l := Nueva(lgtd)
		err = BD.QueryRow(q, l).Scan(&n)
		if err != nil {
			break
		}

		if n == 0 && len(l) == lgtd {
			llave = l
			break
		}

		if i == 10 {
			log.Println("Más de diez intentos para obtener una llave. Tabla: «" + tabla + "»")
		}
	}

	if err != nil {
		log.Println("Error generando llave: ", err)
		return "", err
	} else if len(llave) != lgtd {
		return "", errors.New("Error al generar llave.")
	}

	return llave, nil
}
