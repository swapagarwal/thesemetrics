module.exports = {
  hooks: {
    readPackage,
  },
};

function readPackage(pkg, context) {
  if (process.env.INSTALL_TARGET === 'docker') return pkg;
  
  if ('typeorm' in pkg.dependencies) {
    pkg.dependencies.typeorm = 'znck/typeorm'
  }

  return pkg;
}
