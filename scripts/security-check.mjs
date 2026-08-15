#!/usr/bin/env node
import { readFileSync } from 'node:fs'
import { join } from 'node:path'

const root = new URL('..', import.meta.url)
const source = readFileSync(new URL('./src/index.ts', root), 'utf8')
const packageJson = JSON.parse(readFileSync(new URL('./package.json', root), 'utf8'))

const checks = [
  ['dynamic JavaScript evaluation is absent', !source.includes('new Function')],
  ['author-specific absolute paths are absent', !source.includes('D:/') && !source.includes('\\\\home\\\\')],
  ['trusted roots fail closed', /trustedRoots:\s*z\.array\(z\.string\(\)\)\.default\(\[\]\)/.test(source)],
  ['unsafe build scripts default to disabled', /allowUnsafeBuildScripts:\s*z\.boolean\(\)\.default\(false\)/.test(source)],
  ['release automation defaults to disabled', /allowRelease:\s*z\.boolean\(\)\.default\(false\)/.test(source)],
  ['auto restore defaults to disabled', /autoRestore:\s*z\.boolean\(\)\.default\(false\)/.test(source)],
  ['plugin gate package identity is configured', packageJson.name === '@xypure-x/dsh-plugin-gate'],
]

let failed = false
for (const [label, ok] of checks) {
  process.stdout.write(`${ok ? 'PASS' : 'FAIL'} ${label}\n`)
  if (!ok) failed = true
}
if (failed) process.exitCode = 1
