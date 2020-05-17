import Path from 'path';
import typescript from 'rollup-plugin-typescript2';
import resolve from '@rollup/plugin-node-resolve';
import replace from '@rollup/plugin-replace';
import { terser } from 'rollup-plugin-terser';
import bundleSize from 'rollup-plugin-bundle-size';

function getPackageDirectory(packageName) {
  return Path.join(__dirname, packageName);
}

function getPackageFile(packageName, fileName) {
  return Path.join(__dirname, packageName, fileName);
}

function getPackageField(packageName, fieldName) {
  return require(Path.join(__dirname, packageName, 'package.json'))[fieldName];
}

function input(packageName) {
  return getPackageFile(packageName, 'src/index.ts');
}

function output(packageName, kind = undefined) {
  const f = (fieldName) => {
    const fileName = getPackageField(packageName, fieldName);

    return fileName ? getPackageFile(packageName, fileName) : null;
  };

  const build = getPackageField(packageName, 'build') || {};

  const outputs = [
    !kind || kind === 'main' ? { file: f('main'), format: 'cjs', sourcemap: true } : {},
    !kind || kind === 'module' ? { file: f('module'), format: 'esm', sourcemap: true } : {},
    !kind || kind === 'browser' ? { file: f('browser'), format: 'umd', name: build.name, sourcemap: true } : {},
  ].filter((output) => !!output.file);

  return outputs;
}

function getExternal(packageName) {
  const build = getPackageField(packageName, 'build') || {};

  return [
    ...Object.keys(getPackageField(packageName, 'dependencies') || {}),
    ...Object.keys(getPackageField(packageName, 'peerDependencies') || {}),
    ...(build.external || []),
  ];
}

const packages = ['database', 'app', 'pixel', 'clients/javascript'];

/** @type {import('rollup').RollupOptions[]} */
const configs = [];

export default configs;

const isProd = process.env.BUILD === 'production';
packages.forEach((packageName) => {
  const build = getPackageField(packageName, 'build') || {};
  const config = {
    plugins: [
      replace({
        __DEV__: !isProd,
      }),
      resolve(),
      typescript({
        check: true,
        tsconfig: getPackageFile(packageName, 'tsconfig.json'),
      }),
      bundleSize(),
    ],
    external: getExternal(packageName),
  };

  if (build.input) {
    const copy = {
      ...config,
      plugins: config.plugins.slice(),
    };

    if (isProd) {
      copy.plugins.push(terser());
    }

    Object.entries(build.input).forEach(([kind, entry]) => {
      configs.push({
        ...copy,
        input: getPackageFile(packageName, entry),
        output: output(packageName, kind),
      });
    });
  } else {
    configs.push({
      ...config,
      input: input(packageName),
      output: output(packageName),
    });
  }
});
