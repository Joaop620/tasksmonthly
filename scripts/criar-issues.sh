#!/usr/bin/env bash
# Cria labels, milestones (semanas) e uma issue por dia a partir do PLANO.md (API REST via `gh api`).
# Uso: ./scripts/criar-issues.sh owner/repo
set -euo pipefail
cd "$(dirname "$0")/.."
repo=${1:?uso: $0 owner/repo}

semanas=("Semana 1: API em Go" "Semana 2: CLI em Python" "Semana 3: Frontend Angular" "Semana 4: .NET, JS e entrega")
for par in go:00ADD8 python:3776AB angular:DD0031 dotnet:512BD4 javascript:F7DF1E infra:6E7781; do
  gh api "repos/$repo/labels" -f name="${par%%:*}" -f color="${par##*:}" >/dev/null 2>&1 || true
done

marcos=()
for s in "${semanas[@]}"; do
  n=$(gh api "repos/$repo/milestones?state=all" --jq ".[] | select(.title==\"$s\") | .number")
  [[ -z $n ]] && n=$(gh api "repos/$repo/milestones" -f title="$s" --jq .number)
  marcos+=("$n")
done

labels=(go python angular dotnet)
awk -F'|' '$2 ~ /^ *[0-9]+ *$/ {for(i=2;i<=4;i++){gsub(/^ +| +$/,"",$i)}; print $2 "\t" $3 "\t" $4}' PLANO.md |
while IFS=$'\t' read -r dia tarefa pronto; do
  s=$(( (dia - 1) / 7 )); (( s > 3 )) && s=3
  label=${labels[$s]}
  case $dia in 14|27|28|29|30) label=infra;; 25|26) label=javascript;; esac
  titulo=$(printf 'Dia %02d: %s' "$dia" "$(sed -E 's/\. .*//; s/`//g' <<<"$tarefa" | cut -c1-120 | sed -E 's/\.$//')")
  corpo=$(printf '## Tarefa\n%s\n\n## Pronto quando\n- [ ] %s\n\n_Tempo-alvo: 30 minutos. Feche com `closes #N` no commit._' "$tarefa" "$pronto")
  gh api "repos/$repo/issues" -f title="$titulo" -f body="$corpo" -f "labels[]=$label" -F milestone="${marcos[$s]}" --jq '"#\(.number) \(.title)"'
done
