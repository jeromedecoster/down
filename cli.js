#!/usr/bin/env node --harmony

const path = require('path')
const fs = require('fs')
const opn = require('opn')



const FILE = path.join(process.env.USERPROFILE, 'urls.txt')
const FOLDER = path.join(process.env.USERPROFILE, 'Downloads')
const DELAY = 5000



function getUrls () {
  if (!fs.existsSync(FILE)) {
    fs.writeFileSync(FILE, '')
    return []
  }
  return fs.readFileSync(FILE, 'utf-8')
    .split(/\r?\n/)
    .filter(e => /^http/.test(e))
}

function isRunning () {
  const name = fs.readdirSync(FOLDER)
    .filter(e => /crdownload$/.test(e))
    .sort(function(a, b) {
      return  fs.statSync(path.join(FOLDER, b)).mtime.getTime() -
              fs.statSync(path.join(FOLDER, a)).mtime.getTime()
    })
    .shift()
  // no current .crdownload file
  if (!name) return false
  var ms = Date.now() - fs.statSync(path.join(FOLDER, name)).mtime.getTime()
  // the more recent .crdownload file was created less than 1 hour ago ?
  return (ms / 1000 / 60 / 60) <= 1
}

function check() {
  if (!isRunning()) {
    var url = urls.shift()
    console.log('open ' + url)
    opn(url, {app: 'chrome'})
    comment(url)
  }

  if (urls.length) setTimeout(check, DELAY)
  else console.log('done')
}

function comment (line) {
  var str = fs.readFileSync(FILE, 'utf-8').replace(line, '-' + line)
  fs.writeFileSync(FILE, str)
}



var urls = getUrls()

if (!urls.length) opn(FILE, {app: 'notepad'})
else check()
