module.exports = {
  hooks: {
    readPackage,
  },
};

function readPackage(pkg) {
  if ('typeorm' in pkg.dependencies) {
    return {
      ...pkg,
      dependencies: {
        ...pkg.dependencies,
        typeorm: 'znck/typeorm',
      },
    };
  }

  return pkg;
}
