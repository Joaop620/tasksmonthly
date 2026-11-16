#!/usr/bin/env bash
# Mostra a tarefa do dia e cria a entrada correspondente no LOG.md.
# Uso: ./scripts/dia.sh        -> próximo dia ainda não registrado
#      ./scripts/dia.sh 12     -> mostra a tarefa do dia 12 (sem registrar)
set -euo pipefail
cd "$(dirname "$0")/.."

hoje=$(date +%Y-%m-%d)

tarefa() { # imprime "tarefa|pronto quando" do dia $1
  awk -F'|' -v d="$1" '$2 ~ "^ *"d" *$" {gsub(/^ +| +$/,"",$3); gsub(/^ +| +$/,"",$4); print $3 "|" $4; exit}' PLANO.md
}

if [[ $# -ge 1 ]]; then
  IFS='|' read -r t p <<<"$(tarefa "$1")"
  printf 'Dia %s: %s\nPronto quando: %s\n' "$1" "$t" "$p"
  exit 0
fi

if grep -q "($hoje)" LOG.md; then
  dia=$(grep -o "^## Dia [0-9]*" LOG.md | tail -1 | grep -o '[0-9]*$')
  echo "Hoje já tem entrada no LOG.md (dia $dia)."
else
  ultimo=$(grep -o "^## Dia [0-9]*" LOG.md | tail -1 | grep -o '[0-9]*$' || true)
  dia=$(( ${ultimo:-0} + 1 ))
  if (( dia > 30 )); then echo "Os 30 dias acabaram! Veja 'Depois dos 30 dias' no PLANO.md."; exit 0; fi
  IFS='|' read -r t _ <<<"$(tarefa "$dia")"
  printf '\n## Dia %s (%s)\n\n**Tarefa:** %s\n\n- Feito:\n- Aprendi:\n- Pendente:\n' "$dia" "$hoje" "$t" >> LOG.md
  echo "Entrada do dia $dia criada no LOG.md."
fi

IFS='|' read -r t p <<<"$(tarefa "$dia")"
printf '\nDia %s: %s\nPronto quando: %s\nIssue: busque por "Dia %02d" nas issues do repositório.\n' "$dia" "$t" "$p" "$dia"
