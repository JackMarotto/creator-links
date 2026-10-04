#!/usr/bin/env bash
# Limpa artefatos temporarios de desenvolvimento (testes de browser/exports).
#
# So remove o que o git IGNORA. Arquivos ja rastreados ficam intactos de
# proposito -- delete-los aqui sujaria o `git status` a cada turno.
# Rode `git rm --cached <arquivo>` antes se quiser descartar um deles de vez.
#
# Uso manual: bash scripts/clean-scratch.sh
# Chamado automaticamente pelo hook Stop (veja .claude/settings.json).

set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0

removidos=0

# -- 1) Diretorio inteiro de artefatos do Playwright MCP --
if [ -d .playwright-mcp ]; then
  # Confere que a pasta esta mesmo ignorada antes de apagar tudo dentro.
  if [ -n "$(git check-ignore -q .playwright-mcp && echo sim)" ]; then
    n=$(find .playwright-mcp -type f 2>/dev/null | wc -l | tr -d ' ')
    rm -rf .playwright-mcp
    echo "clean-scratch: .playwright-mcp/ ($n arquivos)"
    removidos=$((removidos + n))
  fi
fi

# -- 2) Exports de teste e screenshots de comparacao na raiz --
# Usa check-ignore para garantir que o padrao esta no .gitignore.
while IFS= read -r -d '' f; do
  [ -e "$f" ] || continue
  git check-ignore -q "$f" || continue
  rm -f "$f"
  echo "clean-scratch: $f"
  removidos=$((removidos + 1))
done < <(find . -maxdepth 1 -type f \( \
  -name 'export*.html' -o \
  -name 'bg-*.png'   -o \
  -name 'check-export.png' -o \
  -name 'listas-export.png' \
\) -print0 2>/dev/null)

[ "$removidos" -gt 0 ] && echo "clean-scratch: $removidos arquivo(s) removido(s)"
exit 0