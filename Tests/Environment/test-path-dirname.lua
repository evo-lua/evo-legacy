local path = _G.path
local format = string.format

-- win32
_G.currentNamespace = "win32"
assertStrictEqual(path.win32.dirname('c:\\'), 'c:\\')
assertStrictEqual(path.win32.dirname('c:\\foo'), 'c:\\')
assertStrictEqual(path.win32.dirname('c:\\foo\\'), 'c:\\')
assertStrictEqual(path.win32.dirname('c:\\foo\\bar'), 'c:\\foo')
assertStrictEqual(path.win32.dirname('c:\\foo\\bar\\'), 'c:\\foo')
assertStrictEqual(path.win32.dirname('c:\\foo\\bar\\baz'), 'c:\\foo\\bar')
assertStrictEqual(path.win32.dirname('c:\\foo bar\\baz'), 'c:\\foo bar')
assertStrictEqual(path.win32.dirname('\\'), '\\')
assertStrictEqual(path.win32.dirname('\\foo'), '\\')
assertStrictEqual(path.win32.dirname('\\foo\\'), '\\')
assertStrictEqual(path.win32.dirname('\\foo\\bar'), '\\foo')
assertStrictEqual(path.win32.dirname('\\foo\\bar\\'), '\\foo')
assertStrictEqual(path.win32.dirname('\\foo\\bar\\baz'), '\\foo\\bar')
assertStrictEqual(path.win32.dirname('\\foo bar\\baz'), '\\foo bar')
assertStrictEqual(path.win32.dirname('c:'), 'c:')
assertStrictEqual(path.win32.dirname('c:foo'), 'c:')
assertStrictEqual(path.win32.dirname('c:foo\\'), 'c:')
assertStrictEqual(path.win32.dirname('c:foo\\bar'), 'c:foo')
assertStrictEqual(path.win32.dirname('c:foo\\bar\\'), 'c:foo')
assertStrictEqual(path.win32.dirname('c:foo\\bar\\baz'), 'c:foo\\bar')
assertStrictEqual(path.win32.dirname('c:foo bar\\baz'), 'c:foo bar')
assertStrictEqual(path.win32.dirname('file:stream'), '.')
assertStrictEqual(path.win32.dirname('dir\\file:stream'), 'dir')
assertStrictEqual(path.win32.dirname('\\\\unc\\share'),
                   '\\\\unc\\share')
assertStrictEqual(path.win32.dirname('\\\\unc\\share\\foo'),
                   '\\\\unc\\share\\')
assertStrictEqual(path.win32.dirname('\\\\unc\\share\\foo\\'),
                   '\\\\unc\\share\\')
assertStrictEqual(path.win32.dirname('\\\\unc\\share\\foo\\bar'),
                   '\\\\unc\\share\\foo')
assertStrictEqual(path.win32.dirname('\\\\unc\\share\\foo\\bar\\'),
                   '\\\\unc\\share\\foo')
assertStrictEqual(path.win32.dirname('\\\\unc\\share\\foo\\bar\\baz'),
                   '\\\\unc\\share\\foo\\bar')
assertStrictEqual(path.win32.dirname('/a/b/'), '/a')
assertStrictEqual(path.win32.dirname('/a/b'), '/a')
assertStrictEqual(path.win32.dirname('/a'), '/')
assertStrictEqual(path.win32.dirname(''), '.')
assertStrictEqual(path.win32.dirname('/'), '/')
assertStrictEqual(path.win32.dirname('////'), '/')
assertStrictEqual(path.win32.dirname('foo'), '.')

-- posix
-- TODO
_G.currentNamespace = "posix"
assertStrictEqual(path.posix.dirname('/a/b/'), '/a')
assertStrictEqual(path.posix.dirname('/a/b'), '/a')
assertStrictEqual(path.posix.dirname('/a'), '/')
assertStrictEqual(path.posix.dirname(''), '.')
assertStrictEqual(path.posix.dirname('/'), '/')
assertStrictEqual(path.posix.dirname('////'), '/')
assertStrictEqual(path.posix.dirname('//a'), '//')
assertStrictEqual(path.posix.dirname('foo'), '.')

print("OK\ttest-path-dirname")