const fs = require('fs')

if(process.argv.length>2){
  const version = process.argv[2]
  const url = `https://github.com/eugenehp/faiss-mobile/releases/download/v${version}/faiss.xcframework.zip`
  const path = `./carthage/faiss-static-xcframework.json`
  
  let json = JSON.parse(fs.readFileSync(path))
  json[version] = url
  fs.writeFileSync(path, JSON.stringify(json, null, 2), 'utf8')
}