# stack_snapshot_clean

Snapshot portátil congelado del runtime compartido ya absorbido.

## Set final de repos operativos
- `dsm00000000`
- `trader`
- `defier`
- `marketer`

## Estado
- no existe repo `stack` activo
- este árbol se conserva como snapshot portable congelado
- la implementación compartida vive en `module/stackmod`
- los wrappers locales del repo viven en `ops/bin/`

## Regla
- no usar este snapshot como centro operativo externo
- no reintroducir repos fuera del set final
- cualquier ajuste compartido debe quedar consistente entre `ops/shared/stack_runtime` y este snapshot
