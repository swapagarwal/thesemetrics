module.exports = {
  hooks: {
    readPackage,
  },
};

function readPackage(pkg) {
  if ('typeorm' in pkg.dependencies) {
    pkg.dependencies.typeorm = 'znck/typeorm'
  }

  return pkg;
}
