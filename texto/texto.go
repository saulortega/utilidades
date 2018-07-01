package texto

import (
	"fmt"
	"net/http"
	"regexp"
	"strings"
)

// Normalizar texto para comparación de búsqueda.
func NormalizarParaComparación(t string) string {
	t = strings.ToLower(t)
	t = strings.TrimSpace(t)
	t = regexp.MustCompile(`\s+`).ReplaceAllString(t, " ")
	t = regexp.MustCompile("á").ReplaceAllString(t, "a")
	t = regexp.MustCompile("é").ReplaceAllString(t, "e")
	t = regexp.MustCompile("í").ReplaceAllString(t, "i")
	t = regexp.MustCompile("ó").ReplaceAllString(t, "o")
	t = regexp.MustCompile("ú").ReplaceAllString(t, "u")
	t = regexp.MustCompile("ü").ReplaceAllString(t, "u")
	t = regexp.MustCompile("à").ReplaceAllString(t, "a")
	t = regexp.MustCompile("è").ReplaceAllString(t, "e")
	t = regexp.MustCompile("ì").ReplaceAllString(t, "i")
	t = regexp.MustCompile("ò").ReplaceAllString(t, "o")
	t = regexp.MustCompile("ù").ReplaceAllString(t, "u")
	return t
}

// Normalizar texto de una columna de BD para mayor precisión en búsqueda.
func NormalizarColumnaParaComparación(col string) string {
	return fmt.Sprintf("LOWER(TRANSLATE(%s, 'ÁÉÍÓÚÜáéíóúüÀÈÌÒÙàèìòùÑ', 'aeiouuaeiouuaeiouaeiouñ'))", col)
}

// Útil para requerimientos de servicios de salud, por ejemplo.
func RemoverTildesDiéresisEñes(T string) string {
	T = strings.Replace(T, "Ñ", "NN", -1)
	T = strings.Replace(T, "Á", "A", -1)
	T = strings.Replace(T, "É", "E", -1)
	T = strings.Replace(T, "Í", "I", -1)
	T = strings.Replace(T, "Ó", "O", -1)
	T = strings.Replace(T, "Ú", "U", -1)
	T = strings.Replace(T, "Ü", "U", -1)
	T = strings.Replace(T, "ñ", "nn", -1)
	T = strings.Replace(T, "á", "a", -1)
	T = strings.Replace(T, "é", "e", -1)
	T = strings.Replace(T, "í", "i", -1)
	T = strings.Replace(T, "ó", "o", -1)
	T = strings.Replace(T, "ú", "u", -1)
	T = strings.Replace(T, "ü", "u", -1)
	return T
}

//
//
//

func PalabrasNormalizadasFiltradas(t string) []string {
	t = NormalizarParaComparación(t)
	var palabras = []string{}

	for _, p := range strings.Split(t, " ") {
		if len(p) <= 2 || p == "las" || p == "los" || p == "les" || p == "una" || p == "por" {
			continue
		}
		palabras = append(palabras, p)
	}

	return palabras
}

func SQLBúsquedaWeb(r *http.Request, columnas []string) string {
	var t = strings.TrimSpace(r.FormValue("buscar"))
	if len(t) <= 2 {
		return ""
	}

	// Pendiente agregar condiciones para os otros dos búsquedas --------
	return SQLBúsquedaPalabrasOr(columnas, t)
}

func SQLBúsquedaPalabrasAnd(columnas []string, texto string) string {
	return SQLBúsqueda(columnas, PalabrasNormalizadasFiltradas(texto), "AND")
}

func SQLBúsquedaPalabrasOr(columnas []string, texto string) string {
	return SQLBúsqueda(columnas, PalabrasNormalizadasFiltradas(texto), "OR")
}

func SQLBúsquedaFrase(columnas []string, texto string) string {
	return SQLBúsqueda(columnas, []string{NormalizarParaComparación(texto)}, "OR")
}

// Las palabras ya deben venir normalizadas.
func SQLBúsqueda(columnas []string, palabras []string, orAnd string) string {
	orAnd = fmt.Sprintf(` %s `, strings.TrimSpace(orAnd))
	var ors = []string{}

	for _, col := range columnas {
		Col := NormalizarColumnaParaComparación(col)
		subOrs := []string{}
		for _, pal := range palabras {
			if len(pal) > 0 {
				subOrs = append(subOrs, fmt.Sprintf(`%s ILIKE '%%%s%%'`, Col, pal))
			}
		}
		if len(subOrs) > 0 {
			ors = append(ors, fmt.Sprintf(`(%s)`, strings.Join(ors, orAnd)))
		}
	}

	if len(ors) == 0 {
		return ""
	}

	return fmt.Sprintf(`(%s)`, strings.Join(ors, " OR "))
}

// ------------ por aquí voy ---------------- crear paquete nuevo "filtros". recibir tipo Filtro según los tipos de datos sql, etc ..
