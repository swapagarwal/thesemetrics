import Path from 'path'
import typescript from '@rollup/plugin-typescript'
import dts from 'rollup-plugin-dts'

export default configs

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

function output(packageName) {
  const f = (fieldName) => {
    const fileName = getPackageField(packageName, fieldName)

    return fileName ? getPackageFile(packageName, fileName) : null
  }

  return [
    { file: f('main'), format: 'cjs' },
    { file: f('module'), format: 'esm' },
  ].filter((output) => !!output.file)
}

const packages = ['database']

/** @type {import('rollup').RollupOptions[]} */
const configs = [
  ...packages.map((packageName) => ({
    input: input(packageName),
    output: output(packageName),
    plugins: [
      typescript({ tsconfig: getPackageFile(packageName, 'tsconfig.json') }),
      dts(),
    ],
    external: Object.keys(getPackageField(packageName, 'dependencies')),
  })),
]
