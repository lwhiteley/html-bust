fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
cheerio = require 'cheerio'
async = require 'async'
_ = require 'lodash'

cheerioOpts =
  xmlMode: false
  lowerCaseTags: true
  lowerCaseAttributeNames: true

remoteRegex = /^(?:http:|https:|\/\/|data:)/

targetAttribute =
  img: 'src'
  script: 'src'
  link: 'href'

defaultOptions =
  tagTypes: [ 'img', 'script', 'link' ]
  urlHint: '?bust'
  hashAlgorithm: 'sha1'
  hashLength: 8

# Escape special regex characters in string.
escapeRegex = (s) ->
  s.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&')

class Buster

  constructor: (@opts) ->
    _.defaults(@opts, defaultOptions)

  # Whether a path ends with the configured hint.
  hasHint: (path) ->
    hint = @opts.urlHint
    path[path.length-hint.length...] is hint

  # Return path with the hint removed.
  removeHint: (path) ->
    hintLength = @opts.urlHint.length
    path[...path.length-hintLength]

  # Whether a path is eligible for cache busting.
  isEligiblePath: (path) ->
    (not remoteRegex.test(path)) and (not @opts.urlHint? or @hasHint(path))

  # Parse HTML string.
  parseHtml: (html) ->
    cheerio.load(html, cheerioOpts)

  # Find all eligible assets in the HTML document.
  findAssets: ($) ->
    _.uniq _.compact _.flatten _.map @opts.tagTypes, (tag) =>
      _.map $(tag), (el) =>
        attr = targetAttribute[tag]
        if attr?
          val = $(el).attr(attr)
          if val? and @isEligiblePath(val)
            val

  # Compute a file's digest.
  digestFile: (path, done) ->
    fs.readFile path, (err, data) =>
      if err? then return done(err)
      hash = crypto.createHash(@opts.hashAlgorithm)
      hash.update(data)
      digest = hash.digest('hex')[0...@opts.hashLength]
      done(null, digest)

  # Transform an asset into its cache-busted version.
  transformAsset: (dir, asset, done) ->
    relativePath = if @opts.urlHint? then @removeHint(asset) else asset
    absolutePath = path.join(dir, relativePath)
    @digestFile absolutePath, (err, hash) =>
      if err? then return done(err)
      done(null, "#{relativePath}?#{hash}")

  # Replace an asset by its cache-busted version.
  replaceAsset: (dir, html, asset, done) ->
    @transformAsset dir, asset, (err, bustedAsset) =>
      if err? then return done(err)
      assetRegex = new RegExp(escapeRegex(asset), 'g')
      newHtml = html.replace(assetRegex, bustedAsset)
      done(null, newHtml)

  transformHtml: (dir, html, done) ->
    assetList = @findAssets(@parseHtml(html))

    # Mutate the `html` reference as assetList is iterated.
    # This seems to be cleaner than the alternatives.
    fn = (asset, done) =>
      @replaceAsset dir, html, asset, (err, newHtml) ->
        html = newHtml
        done(err)

    async.eachSeries assetList, fn, (err) ->
      done(err, html)

  bust: (inPath, outPath, done) ->

    read = (done) =>
      fs.readFile inPath, encoding: 'utf8', done

    transform = (html, done) =>
      @transformHtml(path.dirname(inPath), html, done)

    write = (str, done) =>
      fs.writeFile outPath, str, done

    async.waterfall([read, transform, write], done)


module.exports = (inPath, outPath, opts, done) ->

  unless opts?
    done = ->
    opts = {}

  unless done?
    done = opts
    opts = {}

  new Buster(opts).bust(inPath, outPath, done)
