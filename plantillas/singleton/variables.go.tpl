import (
	"database/sql"
	_ "github.com/lib/pq"
)

var (
	BD *sql.DB
	LongitudLlave int = 10
)