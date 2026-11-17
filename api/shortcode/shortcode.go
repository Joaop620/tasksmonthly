package shortcode

import (
	"crypto/rand"
	"math/big"
)

const Alphabet = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

const Length = 7

func Generate() (string, error) {
	max := big.NewInt(int64(len(Alphabet)))
	code := make ([]byte, Length)

	for i := range code {
		n, err := rand.Int(rand.Reader, max)
		if err != nil {
			return "", err
		}
		code[i] = Alphabet[n.Int64()]
	}
	return string(code), nil
}