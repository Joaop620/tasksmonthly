package shortcode

import (
	"testing"
	"strings"
)

func TestGenerateLength(t*testing.T) {
	code, err := Generate()
	if err != nil {
		t.Fatalf("erro inesperado: %v", err)
	}
	if len(code) != Length {
		t.Errorf("tamanho = %d, esperado %d (código%q)", len(code), Length, code)
	}
}

func TestGenerateAlphabet(t *testing.T) {
	for i := 0; i < 1000; i++ {
		code, err := Generate()
		if err != nil {
			t.Fatalf("erro inesperado: %v", err)
		}
		for _, c := range code {
			if !strings.ContainsRune(Alphabet, c) {
				t.Fatalf("caractere inválido %q no código %q", c, code)
			}
		}
	}
}

func TestGenerateUnique(t *testing.T) {
	const total = 10_000
	seen := make(map[string]bool, total)

	for i := 0; i < total; i++ {
		code, err := Generate()
		if err != nil {
			t.Fatalf("erro inesperado: %v", err)
		}
		if seen[code] {
			t.Fatalf("colisão após %d códigos: %q", i, code)
		}
		seen[code] = true
	}
}