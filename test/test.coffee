fs = require 'fs'
path = require 'path'
async = require 'async'
rimraf = require 'rimraf'
mkdirp = require 'mkdirp'
{ expect } = require 'chai'

bust = require '../index.coffee'

originalDir = path.join(__dirname, 'original')
expectedDir = path.join(__dirname, 'expected')
generatedDir = path.join(__dirname, 'tmp')

originalPath = (filename) -> path.join(originalDir, filename)
expectedPath = (filename) -> path.join(expectedDir, filename)
generatedPath = (filename) -> path.join(generatedDir, filename)

expectFilesAreEqual = (file1, file2, done) ->

  readFile = (path, done) ->
    fs.readFile(path, encoding: 'utf8', done)

  async.map [file1, file2], readFile, (err, results) ->
    expect(err).to.not.exist
    [ data1, data2 ] = results
    expect(data1).to.equal(data2)
    done()

runTest = (file, cond, opts, done) ->

  unless done?
    done = opts
    opts = {}

  originalFile = originalPath("#{file}.html")
  generatedFile = generatedPath("#{cond}-#{file}.html")
  expectedFile = expectedPath("#{cond}-#{file}.html")

  bust originalFile, generatedFile, opts, (err) ->
    expect(err).to.not.exist
    expectFilesAreEqual(generatedFile, expectedFile, done)

describe 'html-bust', ->

  beforeEach ->
    rimraf.sync(generatedDir)
    mkdirp.sync(generatedDir)

  describe 'default options', ->

    it 'should replace all assets', (done) ->
      runTest('hint-all', 'defaults', done)

    it 'should replace some assets', (done) ->
      runTest('hint-some', 'defaults', done)

    it 'should replace no assets', (done) ->
      runTest('hint-none', 'defaults', done)

  describe 'custom tags', ->

    it 'should replace some assets', (done) ->
      runTest('hint-all', 'custom-tags', tagTypes: ['script', 'link'], done)

  describe 'custom hash algorithm', ->

    it 'should replace all assets', (done) ->
      runTest('hint-all', 'custom-algo', hashAlgorithm: 'md5', done)

  describe 'custom hash length', ->

    it 'should replace all assets', (done) ->
      runTest('hint-all', 'custom-length', hashLength: 4, done)

  describe 'custom string', ->

    it 'should replace all assets', (done) ->
      runTest('hint-all', 'custom-string', mode: 'string', fixedString: 'bazinga', done)

  describe 'no hint', ->

    it 'should replace all assets', (done) ->
      runTest('hint-none', 'no-hint', urlHint: null, done)
