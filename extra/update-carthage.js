const fs = require('fs')

if(process.argv.length>2){
  const version = process.argv[2]
  const urls = [
    `https://github.com/eugenehp/faiss-mobile/releases/download/v${version}/faiss.xcframework.zip`,
    `https://github.com/eugenehp/faiss-mobile/releases/download/v${version}/faiss_c.xcframework.zip`
  ]
  const paths = [
    `./carthage/faiss-static-xcframework.json`,
    `./carthage/faiss-c-static-xcframework.json`
  ]
  
  for(let i=0; i<paths.length;i++){
    const path = paths[i]
    const url = urls[i]
    let json = JSON.parse(fs.readFileSync(path))
    json[version] = url
    fs.writeFileSync(path, JSON.stringify(json, null, 2), 'utf8')
  }
}