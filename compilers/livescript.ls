require! livescript: 'LiveScript'

module.exports = (file, data) ->
  livescript.compile data,
    bare: true
    header: false
    filename: file

