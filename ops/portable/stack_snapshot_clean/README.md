# stack

`stack` está retirado del flujo diario.

No es un centro operativo activo.
Se conserva solo como repo mínimo para:

- exponer wrappers públicos en `bin/`
- mantener `module/stackmod` como subtree portable
- conservar el contrato final del estado retirado

## Repos operativos reales

- `dsm00000000`
- `freelancer`
- `trader`
- `defier`

## Entrada pública

- `bin/stackdoctor`
- `bin/stackctl repos ls`
- `bin/stackall`
- `bin/stacktree`
- `run.sh`

## Regla

- no añadir nuevas features aquí
- no usar `stack/` como mando diario
- no reabrir crecimiento estructural
- cualquier primitiva compartida real vive en `module/stackmod`

Ver `contracts/final_state.md`.
