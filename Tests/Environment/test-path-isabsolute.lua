local path = require("./Core/Environment/path")

_G.currentNamespace = "win32"
assertStrictEqual(path.win32.isAbsolute('/'), true);
assertStrictEqual(path.win32.isAbsolute('//'), true);
assertStrictEqual(path.win32.isAbsolute('//server'), true);
assertStrictEqual(path.win32.isAbsolute('//server/file'), true);
assertStrictEqual(path.win32.isAbsolute('\\\\server\\file'), true);
assertStrictEqual(path.win32.isAbsolute('\\\\server'), true);
assertStrictEqual(path.win32.isAbsolute('\\\\'), true);
assertStrictEqual(path.win32.isAbsolute('c'), false);
assertStrictEqual(path.win32.isAbsolute('c:'), false);
assertStrictEqual(path.win32.isAbsolute('c:\\'), true);
assertStrictEqual(path.win32.isAbsolute('c:/'), true);
assertStrictEqual(path.win32.isAbsolute('c://'), true);
assertStrictEqual(path.win32.isAbsolute('C:/Users/'), true);
assertStrictEqual(path.win32.isAbsolute('C:\\Users\\'), true);
assertStrictEqual(path.win32.isAbsolute('C:cwd/another'), false);
assertStrictEqual(path.win32.isAbsolute('C:cwd\\another'), false);
assertStrictEqual(path.win32.isAbsolute('directory/directory'), false);
assertStrictEqual(path.win32.isAbsolute('directory\\directory'), false);

_G.currentNamespace = "posix"
assertStrictEqual(path.posix.isAbsolute('/home/foo'), true);
assertStrictEqual(path.posix.isAbsolute('/home/foo/..'), true);
assertStrictEqual(path.posix.isAbsolute('bar/'), false);
assertStrictEqual(path.posix.isAbsolute('./baz'), false);

print("OK\ttest-path-isabsolute")