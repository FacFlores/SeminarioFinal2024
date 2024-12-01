package utils

import (
	"math/rand"
)

func GenerateRandomPercentagesDeterministic(n int, seed int64) []float64 {
	r := rand.New(rand.NewSource(seed))
	values := make([]float64, n)
	total := 0.0
	for i := 0; i < n; i++ {
		values[i] = r.Float64()
		total += values[i]
	}
	for i := range values {
		values[i] = (values[i] / total) * 100
	}

	return values
}
