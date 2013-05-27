files = require('fs').readdirSync(__dirname)

pattern = new RegExp('^test-')

files = (file for file in files when file.match(pattern))

child = require('child_process')
path = require('path')

code = 0
run = (err) ->
  if err
    console.error('FAIL')
    code = err.code
  if files.length is 0 then process.exit(code)
  file = files.shift()
  ext = path.extname(file)
  console.log('Running:', file)
  cp = child.exec("coffee #{path.join(__dirname, file)}", run)
  cp.stdout.pipe(process.stdout)
  cp.stderr.pipe(process.stderr)

run()
