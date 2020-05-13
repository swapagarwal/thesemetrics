import Path from 'path'
import typescript from 'rollup-plugin-typescript2'
import resolve from '@rollup/plugin-node-resolve'
import replace from '@rollup/plugin-replace'

function getPackageDirectory(packageName) {
  return Path.join(__dirname, packageName)
}

function getPackageFile(packageName, fileName) {
  return Path.join(__dirname, packageName, fileName)
}

function getPackageField(packageName, fieldName) {
  return require(Path.join(__dirname, packageName, 'package.json'))[fieldName]
}

function input(packageName) {
  return getPackageFile(packageName, 'src/index.ts')
}

function output(packageName, kind = undefined) {
  const f = (fieldName) => {
    const fileName = getPackageField(packageName, fieldName)

    return fileName ? getPackageFile(packageName, fileName) : null
  }

  const build = getPackageField(packageName, 'build') || {}

  const outputs = [
    !kind || kind === 'main' ? { file: f('main'), format: 'cjs' } : {},
    !kind || kind === 'module' ? { file: f('module'), format: 'esm' } : {},
    !kind || kind === 'browser'
      ? { file: f('browser'), format: 'umd', name: build.name }
      : {},
  ].filter((output) => !!output.file)

  return outputs
}

function getExternal(packageName) {
  return [
    ...Object.keys(getPackageField(packageName, 'dependencies') || {}),
    ...Object.keys(getPackageField(packageName, 'peerDependencies') || {}),
  ]
}

const packages = ['database', 'app', 'pixel', 'clients/javascript']

/** @type {import('rollup').RollupOptions[]} */
const configs = []

export default configs

packages.forEach((packageName) => {
  const build = getPackageField(packageName, 'build') || {}
  const config = {
    plugins: [
      replace({
        __DEV__: process.env.BUILD !== 'production',
      }),
      resolve(),
      typescript({
        check: true,
        tsconfig: getPackageFile(packageName, 'tsconfig.json'),
      }),
    ],
    external: getExternal(packageName),
  }

  if (build.input) {
    Object.entries(build.input).forEach(([kind, entry]) => {
      configs.push({
        ...config,
        input: getPackageFile(packageName, entry),
        output: output(packageName, kind),
      })
    })
  } else {
    configs.push({
      ...config,
      input: input(packageName),
      output: output(packageName),
    })
  }
})
