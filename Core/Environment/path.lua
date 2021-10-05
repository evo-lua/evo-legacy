-- Originally ported from the NodeJS source code @ 0d2b6aca60 (latest HEAD on 2021/10/05); Copyright Joyent, Inc. and other Node contributors.

-- TODO
-- local {
--   FunctionPrototypeBind,
--   StringPrototypeCharCodeAt,
--   StringPrototypeIndexOf,
--   StringPrototypeLastIndexOf,
--   StringPrototypeReplace,
--   StringPrototypeSlice,
--   StringPrototypeToLowerCase,
-- } = primordials;

-- Character codes
CHAR_UPPERCASE_A = 65
CHAR_LOWERCASE_A = 97
CHAR_UPPERCASE_Z = 90
CHAR_LOWERCASE_Z = 122
CHAR_DOT = 46
CHAR_FORWARD_SLASH = 47
CHAR_BACKWARD_SLASH = 92
CHAR_COLON = 58
CHAR_QUESTION_MARK = 63

-- TODO
-- local {
--   validateObject,
--   validateString,
-- } = require('internal/validators');

local ffi = require("ffi")
local platformIsWin32 = (ffi.os == 'Windows')

function isPathSeparator(code)
  return code == CHAR_FORWARD_SLASH or code == CHAR_BACKWARD_SLASH
end

function isPosixPathSeparator(code)
  return code == CHAR_FORWARD_SLASH;
end

function isWindowsDeviceRoot(code)
  -- isSingleLetterCharacter
  return (code >= CHAR_UPPERCASE_A and code <= CHAR_UPPERCASE_Z) or
         (code >= CHAR_LOWERCASE_A and code <= CHAR_LOWERCASE_Z);
end

-- Resolves . and .. elements in a path with directory names
function normalizeString(path, allowAboveRoot, separator, isPathSeparator)
  local res = '';
  local lastSegmentLength = 0;
  local lastSlash = -1;
  local dots = 0;
  local code = 0;
  for i = 0, path.length do

    if (i < path.length) then
      code = StringPrototypeCharCodeAt(path, i);
    else if (isPathSeparator(code)) then
      break;
    else
      code = CHAR_FORWARD_SLASH;
	end

    if (isPathSeparator(code)) then
      if (lastSlash == i - 1 or dots == 1) then
        -- NOOP
      else if (dots == 2) then

        if (res.length < 2 or lastSegmentLength ~= 2 or
            StringPrototypeCharCodeAt(res, res.length - 1) ~= CHAR_DOT or
            StringPrototypeCharCodeAt(res, res.length - 2) ~= CHAR_DOT) then
          if (res.length > 2) then
            local lastSlashIndex = StringPrototypeLastIndexOf(res, separator);
            if (lastSlashIndex == -1) then
              res = '';
              lastSegmentLength = 0;
            else
              res = StringPrototypeSlice(res, 0, lastSlashIndex);
              lastSegmentLength =
                res.length - 1 - StringPrototypeLastIndexOf(res, separator);
			end
            lastSlash = i;
            dots = 0;
            -- continue; -- TODO
          else if (res.length ~= 0) then
            res = '';
            lastSegmentLength = 0;
            lastSlash = i;
            dots = 0;
            -- continue; -- TODO
		  end
        end
        if (allowAboveRoot) then
        --   res += res.length > 0 ? `${separator}..` : '..'; -- TODO
          lastSegmentLength = 2;
		end
      else
        if (res.length > 0) then
        --   res += `${separator}${StringPrototypeSlice(path, lastSlash + 1, i)}`; -- TODO
        else
          res = StringPrototypeSlice(path, lastSlash + 1, i);
        lastSegmentLength = i - lastSlash - 1;
		end
      lastSlash = i;
      dots = 0;
	end
    else if (code == CHAR_DOT and dots ~= -1) then
    --   ++dots; -- TODO
    else
      dots = -1;
	end
end
  return res;
end

--[[
 * @param {string} sep
 * @param {{
 *  dir?: string;
 *  root?: string;
 *  base?: string;
 *  name?: string;
 *  ext?: string;
 *  }} pathObject
 * @returns {string}
 ]]--
function _format(sep, pathObject)
  validateObject(pathObject, 'pathObject');
  local dir = pathObject.dir or pathObject.root;
--   local base = pathObject.base or  `${pathObject.name or ''}${pathObject.ext or ''}`; -- TODO
  if (not dir) then
    return base;
  end
--   return dir == pathObject.root ? `${dir}${base}` : `${dir}${sep}${base}`; -- TODO
end

local uv = require("uv")

  --[[
   * path.resolve([from ...], to)
   * @param {...string} args
   * @returns {string}
   ]]--
local function resolve(...)
	local args = { ... }

    local resolvedDevice = '';
    local resolvedTail = '';
    local resolvedAbsolute = false;

    for i = #args, i >= -1, -1 do
      local path;
      if (i >= 0) then
        path = args[i];
        validateString(path, 'path');

        -- Skip empty entries
        if (#path == 0) then
        --   continue; -- TODO
		end
      else if (#resolvedDevice == 0) then
        path = uv.cwd()
      else
        -- Windows has the concept of drive-specific current working
        -- directories. If we've resolved a drive letter but not yet an
        -- absolute path, get cwd for that drive, or the process cwd if
        -- the drive cwd is not available. We're sure the device is not
        -- a UNC path at this points, because UNC paths are always absolute.
        -- path = process.env[`=${resolvedDevice}`] or uv.cwd(); -- TODO

        -- Verify that a cwd was found and that it actually points
        -- to our drive. If not, default to the drive's root.
        if (path == nil or
            (StringPrototypeToLowerCase(StringPrototypeSlice(path, 0, 2)) ~=
            StringPrototypeToLowerCase(resolvedDevice) and
            StringPrototypeCharCodeAt(path, 2) == CHAR_BACKWARD_SLASH)) then
        --   path = `${resolvedDevice}\\`; -- TODO
			end
		end

      local len = #path;
      local rootEnd = 0;
      local device = '';
      local isAbsolute = false;
      local code = StringPrototypeCharCodeAt(path, 0);

      -- Try to match a root
      if (len == 1) then
        if (isPathSeparator(code)) then
          -- `path` contains just a path separator
          rootEnd = 1;
          isAbsolute = true;
		end
      else if (isPathSeparator(code)) then
        -- Possible UNC root

        -- If we started with a separator, we know we at least have an
        -- absolute path of some kind (UNC or otherwise)
        isAbsolute = true;

        if (isPathSeparator(StringPrototypeCharCodeAt(path, 1))) then
          -- Matched double path separator at beginning
          local j = 2;
          local last = j;
          -- Match 1 or more non-path separators
          while (j < len and
                 not isPathSeparator(StringPrototypeCharCodeAt(path, j))) do
            j = j + 1;
				 end
          if (j < len and j ~= last) then
            local firstPart = StringPrototypeSlice(path, last, j);
            -- Matchednot
            last = j;
            -- Match 1 or more path separators
            while (j < len and
                   isPathSeparator(StringPrototypeCharCodeAt(path, j))) do
              j = j + 1;
			end

            if (j < len and j ~= last) then
              -- Matchednot
              last = j;
              -- Match 1 or more non-path separators
              while (j < len and
                     not isPathSeparator(StringPrototypeCharCodeAt(path, j))) do
                j = j + 1
					 end
              if (j == len or j ~= last) then
                -- We matched a UNC root
                -- device =                `\\\\${firstPart}\\${StringPrototypeSlice(path, last, j)}`; -- TODO
                rootEnd = j;
			  end
            end
		end
        else
          rootEnd = 1;
		end
      else if (isWindowsDeviceRoot(code) and
                  StringPrototypeCharCodeAt(path, 1) == CHAR_COLON) then
        -- Possible device root
        device = StringPrototypeSlice(path, 0, 2);
        rootEnd = 2;
        if (len > 2 and isPathSeparator(StringPrototypeCharCodeAt(path, 2))) then
          -- Treat separator following drive name as an absolute path
          -- indicator
          isAbsolute = true;
          rootEnd = 3;
		end
	end

      if (#device > 0) then
        if (#resolvedDevice > 0) then
          if (StringPrototypeToLowerCase(device) ~=
              StringPrototypeToLowerCase(resolvedDevice)) then
            -- This path points to another device so it is not applicable
            -- continue; -- TODO
        else
          resolvedDevice = device;
		end
	end
-- TODO: Eliminate .length everywhere
      if (resolvedAbsolute) then
        if (#resolvedDevice > 0) then
          break;
      else
        -- resolvedTail =          `${StringPrototypeSlice(path, rootEnd)}\\${resolvedTail}`; -- TODO
		      resolvedAbsolute = isAbsolute;
        if (isAbsolute and resolvedDevice.length > 0) then
          break;
		end
	end
end

    -- At this point the path should be resolved to a full absolute path,
    -- but handle relative paths to be safe (might happen when uv.cwd()
    -- fails)

    -- Normalize the tail path
    resolvedTail = normalizeString(resolvedTail, not resolvedAbsolute, '\\',                                isPathSeparator);

    -- return resolvedAbsolute ?      `${resolvedDevice}\\${resolvedTail}` :      `${resolvedDevice}${resolvedTail}` or '.'; 00 TODO
end


  --[[
   * @param {string} path
   * @returns {string}
   ]]--
   local function normalizePath(path)
    validateString(path, 'path');
    local len = #path;
    if (len == 0) then      return '.'; end
    local rootEnd = 0;
    local device;
    local isAbsolute = false;
    local code = StringPrototypeCharCodeAt(path, 0);

    -- Try to match a root
    if (len == 1) then
      -- `path` contains just a single char, exit early to avoid
      -- unnecessary work
    --   return isPosixPathSeparator(code) ? '\\' : path; -- TODO
	end
    if (isPathSeparator(code)) then
      -- Possible UNC root

      -- If we started with a separator, we know we at least have an absolute
      -- path of some kind (UNC or otherwise)
      isAbsolute = true;

      if (isPathSeparator(StringPrototypeCharCodeAt(path, 1))) then
        -- Matched double path separator at beginning
        local j = 2;
        local last = j;
        -- Match 1 or more non-path separators
        while (j < len and
               not isPathSeparator(StringPrototypeCharCodeAt(path, j))) do
          j = j + 1
			   end
        if (j < len and j ~= last) then
          local firstPart = StringPrototypeSlice(path, last, j);
          -- Matchednot
          last = j;
          -- Match 1 or more path separators
          while (j < len and
                 isPathSeparator(StringPrototypeCharCodeAt(path, j))) do
            j = j + 1
				 end
          if (j < len and j ~= last) then
            -- Matchednot
            last = j;
            -- Match 1 or more non-path separators
            while (j < len and
                   not isPathSeparator(StringPrototypeCharCodeAt(path, j))) do
					j = j + 1
				   end
            if (j == len) then
              -- We matched a UNC root only
              -- Return the normalized version of the UNC root since there
              -- is nothing left to process
            --   return `\\\\${firstPart}\\${StringPrototypeSlice(path, last)}\\`; -- TODO
			end
            if (j ~= last) then
              -- We matched a UNC root with leftovers
            --   device =                `\\\\${firstPart}\\${StringPrototypeSlice(path, last, j)}`; -- TODO
              rootEnd = j;
			end
		end
	end
      else
        rootEnd = 1;
	  end
    else if (isWindowsDeviceRoot(code) and
               StringPrototypeCharCodeAt(path, 1) == CHAR_COLON) then
      -- Possible device root
      device = StringPrototypeSlice(path, 0, 2);
      rootEnd = 2;
      if (len > 2 and isPathSeparator(StringPrototypeCharCodeAt(path, 2))) then
        -- Treat separator following drive name as an absolute path
        -- indicator
        isAbsolute = true;
        rootEnd = 3;
	  end
    end

    -- local tail = rootEnd < len ?      normalizeString(StringPrototypeSlice(path, rootEnd),                     not isAbsolute, '\\', isPathSeparator) :      ''; -- TODO
    if (tail.length == 0 and not isAbsolute) then
      tail = '.'; end
    if (tail.length > 0 and
        isPathSeparator(StringPrototypeCharCodeAt(path, len - 1))) then
      tail = tail .. '\\';
		end
    if (device == nil) then
    --   return isAbsolute ? `\\${tail}` : tail; -- TODO
	end
    return isAbsolute ? `${device}\\${tail}` : `${device}${tail}`;
  },


local win32 = {
	resolve = resolveRelativePath,
	normalize = normalizePath,
	isAbsolute = isAbsolutePath,
	join = joinPath,
	relative = convertRelativePath,


  --[[
   * @param {string} path
   * @returns {boolean}
   ]]--
  isAbsolute(path) {
    validateString(path, 'path');
    local len = path.length;
    if (len == 0)
      return false;

    local code = StringPrototypeCharCodeAt(path, 0);
    return isPathSeparator(code) or
      -- Possible device root
      (len > 2 and
      isWindowsDeviceRoot(code) and
      StringPrototypeCharCodeAt(path, 1) == CHAR_COLON and
      isPathSeparator(StringPrototypeCharCodeAt(path, 2)));
  },

  --[[
   * @param {...string} args
   * @returns {string}
   ]]--
  join(...args) {
    if (args.length == 0)
      return '.';

    local joined;
    local firstPart;
    for (local i = 0; i < args.length; ++i) {
      local arg = args[i];
      validateString(arg, 'path');
      if (arg.length > 0) {
        if (joined == nil)
          joined = firstPart = arg;
        else
          joined += `\\${arg}`;
      }
    }

    if (joined == nil)
      return '.';

    -- Make sure that the joined path doesn't start with two slashes, because
    -- normalize() will mistake it for a UNC path then.
    //
    -- This step is skipped when it is very clear that the user actually
    -- intended to point at a UNC path. This is assumed when the first
    -- non-empty string arguments starts with exactly two slashes followed by
    -- at least one more non-slash character.
    //
    -- Note that for normalize() to treat a path as a UNC path it needs to
    -- have at least 2 components, so we don't filter for that here.
    -- This means that the user can use join to construct UNC paths from
    -- a server name and a share name; for example:
    --   path.join('//server', 'share') -> '\\\\server\\share\\')
    local needsReplace = true;
    local slashCount = 0;
    if (isPathSeparator(StringPrototypeCharCodeAt(firstPart, 0))) {
      ++slashCount;
      local firstLen = firstPart.length;
      if (firstLen > 1 and
          isPathSeparator(StringPrototypeCharCodeAt(firstPart, 1))) {
        ++slashCount;
        if (firstLen > 2) {
          if (isPathSeparator(StringPrototypeCharCodeAt(firstPart, 2)))
            ++slashCount;
          else {
            -- We matched a UNC path in the first part
            needsReplace = false;
          }
        }
      }
    }
    if (needsReplace) {
      -- Find any more consecutive slashes we need to replace
      while (slashCount < joined.length and
             isPathSeparator(StringPrototypeCharCodeAt(joined, slashCount))) {
        slashCount++;
      }

      -- Replace the slashes if needed
      if (slashCount >= 2)
        joined = `\\${StringPrototypeSlice(joined, slashCount)}`;
    }

    return win32.normalize(joined);
  },

  --[[
   * It will solve the relative path from `from` to `to`, for instancee
   * from = 'C:\\orandea\\test\\aaa'
   * to = 'C:\\orandea\\impl\\bbb'
   * The output of the function should be: '..\\..\\impl\\bbb'
   * @param {string} from
   * @param {string} to
   * @returns {string}
   ]]--
  relative(from, to) {
    validateString(from, 'from');
    validateString(to, 'to');

    if (from == to)
      return '';

    local fromOrig = win32.resolve(from);
    local toOrig = win32.resolve(to);

    if (fromOrig == toOrig)
      return '';

    from = StringPrototypeToLowerCase(fromOrig);
    to = StringPrototypeToLowerCase(toOrig);

    if (from == to)
      return '';

    -- Trim any leading backslashes
    local fromStart = 0;
    while (fromStart < from.length and
           StringPrototypeCharCodeAt(from, fromStart) == CHAR_BACKWARD_SLASH) {
      fromStart++;
    }
    -- Trim trailing backslashes (applicable to UNC paths only)
    local fromEnd = from.length;
    while (
      fromEnd - 1 > fromStart and
      StringPrototypeCharCodeAt(from, fromEnd - 1) == CHAR_BACKWARD_SLASH
    ) {
      fromEnd--;
    }
    local fromLen = fromEnd - fromStart;

    -- Trim any leading backslashes
    local toStart = 0;
    while (toStart < to.length and
           StringPrototypeCharCodeAt(to, toStart) == CHAR_BACKWARD_SLASH) {
      toStart++;
    }
    -- Trim trailing backslashes (applicable to UNC paths only)
    local toEnd = to.length;
    while (toEnd - 1 > toStart and
           StringPrototypeCharCodeAt(to, toEnd - 1) == CHAR_BACKWARD_SLASH) {
      toEnd--;
    }
    local toLen = toEnd - toStart;

    -- Compare paths to find the longest common path from root
    local length = fromLen < toLen ? fromLen : toLen;
    local lastCommonSep = -1;
    local i = 0;
    for (; i < length; i++) {
      local fromCode = StringPrototypeCharCodeAt(from, fromStart + i);
      if (fromCode ~= StringPrototypeCharCodeAt(to, toStart + i))
        break;
      else if (fromCode == CHAR_BACKWARD_SLASH)
        lastCommonSep = i;
    }

    -- We found a mismatch before the first common path separator was seen, so
    -- return the original `to`.
    if (i ~= length) {
      if (lastCommonSep == -1)
        return toOrig;
    } else {
      if (toLen > length) {
        if (StringPrototypeCharCodeAt(to, toStart + i) ==
            CHAR_BACKWARD_SLASH) {
          -- We get here if `from` is the exact base path for `to`.
          -- For example: from='C:\\foo\\bar'; to='C:\\foo\\bar\\baz'
          return StringPrototypeSlice(toOrig, toStart + i + 1);
        }
        if (i == 2) {
          -- We get here if `from` is the device root.
          -- For example: from='C:\\'; to='C:\\foo'
          return StringPrototypeSlice(toOrig, toStart + i);
        }
      }
      if (fromLen > length) {
        if (StringPrototypeCharCodeAt(from, fromStart + i) ==
            CHAR_BACKWARD_SLASH) {
          -- We get here if `to` is the exact base path for `from`.
          -- For example: from='C:\\foo\\bar'; to='C:\\foo'
          lastCommonSep = i;
        } else if (i == 2) {
          -- We get here if `to` is the device root.
          -- For example: from='C:\\foo\\bar'; to='C:\\'
          lastCommonSep = 3;
        }
      }
      if (lastCommonSep == -1)
        lastCommonSep = 0;
    }

    local out = '';
    -- Generate the relative path based on the path difference between `to` and
    -- `from`
    for (i = fromStart + lastCommonSep + 1; i <= fromEnd; ++i) {
      if (i == fromEnd or
          StringPrototypeCharCodeAt(from, i) == CHAR_BACKWARD_SLASH) {
        out += out.length == 0 ? '..' : '\\..';
      }
    }

    toStart += lastCommonSep;

    -- Lastly, append the rest of the destination (`to`) path that comes after
    -- the common path parts
    if (out.length > 0)
      return `${out}${StringPrototypeSlice(toOrig, toStart, toEnd)}`;

    if (StringPrototypeCharCodeAt(toOrig, toStart) == CHAR_BACKWARD_SLASH)
      ++toStart;
    return StringPrototypeSlice(toOrig, toStart, toEnd);
  },

  --[[
   * @param {string} path
   * @returns {string}
   ]]--
  toNamespacedPath(path) {
    -- Note: this will *probably* throw somewhere.
    if (typeof path ~= 'string' or path.length == 0)
      return path;

    local resolvedPath = win32.resolve(path);

    if (resolvedPath.length <= 2)
      return path;

    if (StringPrototypeCharCodeAt(resolvedPath, 0) == CHAR_BACKWARD_SLASH) {
      -- Possible UNC root
      if (StringPrototypeCharCodeAt(resolvedPath, 1) == CHAR_BACKWARD_SLASH) {
        local code = StringPrototypeCharCodeAt(resolvedPath, 2);
        if (code ~= CHAR_QUESTION_MARK and code ~= CHAR_DOT) {
          -- Matched non-long UNC root, convert the path to a long UNC path
          return `\\\\?\\UNC\\${StringPrototypeSlice(resolvedPath, 2)}`;
        }
      }
    } else if (
      isWindowsDeviceRoot(StringPrototypeCharCodeAt(resolvedPath, 0)) and
      StringPrototypeCharCodeAt(resolvedPath, 1) == CHAR_COLON and
      StringPrototypeCharCodeAt(resolvedPath, 2) == CHAR_BACKWARD_SLASH
    ) {
      -- Matched device root, convert the path to a long UNC path
      return `\\\\?\\${resolvedPath}`;
    }

    return path;
  },

  --[[
   * @param {string} path
   * @returns {string}
   ]]--
  dirname(path) {
    validateString(path, 'path');
    local len = path.length;
    if (len == 0)
      return '.';
    local rootEnd = -1;
    local offset = 0;
    local code = StringPrototypeCharCodeAt(path, 0);

    if (len == 1) {
      -- `path` contains just a path separator, exit early to avoid
      -- unnecessary work or a dot.
      return isPathSeparator(code) ? path : '.';
    }

    -- Try to match a root
    if (isPathSeparator(code)) {
      -- Possible UNC root

      rootEnd = offset = 1;

      if (isPathSeparator(StringPrototypeCharCodeAt(path, 1))) {
        -- Matched double path separator at beginning
        local j = 2;
        local last = j;
        -- Match 1 or more non-path separators
        while (j < len and
               not isPathSeparator(StringPrototypeCharCodeAt(path, j))) {
          j++;
        }
        if (j < len and j ~= last) {
          -- Matchednot
          last = j;
          -- Match 1 or more path separators
          while (j < len and
                 isPathSeparator(StringPrototypeCharCodeAt(path, j))) {
            j++;
          }
          if (j < len and j ~= last) {
            -- Matchednot
            last = j;
            -- Match 1 or more non-path separators
            while (j < len and
                   not isPathSeparator(StringPrototypeCharCodeAt(path, j))) {
              j++;
            }
            if (j == len) {
              -- We matched a UNC root only
              return path;
            }
            if (j ~= last) {
              -- We matched a UNC root with leftovers

              -- Offset by 1 to include the separator after the UNC root to
              -- treat it as a "normal root" on top of a (UNC) root
              rootEnd = offset = j + 1;
            }
          }
        }
      }
    -- Possible device root
    } else if (isWindowsDeviceRoot(code) and
               StringPrototypeCharCodeAt(path, 1) == CHAR_COLON) {
      rootEnd =
        len > 2 and isPathSeparator(StringPrototypeCharCodeAt(path, 2)) ? 3 : 2;
      offset = rootEnd;
    }

    local end = -1;
    local matchedSlash = true;
    for (local i = len - 1; i >= offset; --i) {
      if (isPathSeparator(StringPrototypeCharCodeAt(path, i))) {
        if (not matchedSlash) {
          end = i;
          break;
        }
      } else {
        -- We saw the first non-path separator
        matchedSlash = false;
      }
    }

    if (end == -1) {
      if (rootEnd == -1)
        return '.';

      end = rootEnd;
    }
    return StringPrototypeSlice(path, 0, end);
  },

  --[[
   * @param {string} path
   * @param {string} [ext]
   * @returns {string}
   ]]--
  basename(path, ext) {
    if (ext ~= nil)
      validateString(ext, 'ext');
    validateString(path, 'path');
    local start = 0;
    local end = -1;
    local matchedSlash = true;

    -- Check for a drive letter prefix so as not to mistake the following
    -- path separator as an extra separator at the end of the path that can be
    -- disregarded
    if (path.length >= 2 and
        isWindowsDeviceRoot(StringPrototypeCharCodeAt(path, 0)) and
        StringPrototypeCharCodeAt(path, 1) == CHAR_COLON) {
      start = 2;
    }

    if (ext ~= nil and ext.length > 0 and ext.length <= path.length) {
      if (ext == path)
        return '';
      local extIdx = ext.length - 1;
      local firstNonSlashEnd = -1;
      for (local i = path.length - 1; i >= start; --i) {
        local code = StringPrototypeCharCodeAt(path, i);
        if (isPathSeparator(code)) {
          -- If we reached a path separator that was not part of a set of path
          -- separators at the end of the string, stop now
          if (not matchedSlash) {
            start = i + 1;
            break;
          }
        } else {
          if (firstNonSlashEnd == -1) {
            -- We saw the first non-path separator, remember this index in case
            -- we need it if the extension ends up not matching
            matchedSlash = false;
            firstNonSlashEnd = i + 1;
          }
          if (extIdx >= 0) {
            -- Try to match the explicit extension
            if (code == StringPrototypeCharCodeAt(ext, extIdx)) {
              if (--extIdx == -1) {
                -- We matched the extension, so mark this as the end of our path
                -- component
                end = i;
              }
            } else {
              -- Extension does not match, so our result is the entire path
              -- component
              extIdx = -1;
              end = firstNonSlashEnd;
            }
          }
        }
      }

      if (start == end)
        end = firstNonSlashEnd;
      else if (end == -1)
        end = path.length;
      return StringPrototypeSlice(path, start, end);
    }
    for (local i = path.length - 1; i >= start; --i) {
      if (isPathSeparator(StringPrototypeCharCodeAt(path, i))) {
        -- If we reached a path separator that was not part of a set of path
        -- separators at the end of the string, stop now
        if (not matchedSlash) {
          start = i + 1;
          break;
        }
      } else if (end == -1) {
        -- We saw the first non-path separator, mark this as the end of our
        -- path component
        matchedSlash = false;
        end = i + 1;
      }
    }

    if (end == -1)
      return '';
    return StringPrototypeSlice(path, start, end);
  },

  --[[
   * @param {string} path
   * @returns {string}
   ]]--
  extname(path) {
    validateString(path, 'path');
    local start = 0;
    local startDot = -1;
    local startPart = 0;
    local end = -1;
    local matchedSlash = true;
    -- Track the state of characters (if any) we see before our first dot and
    -- after any path separator we find
    local preDotState = 0;

    -- Check for a drive letter prefix so as not to mistake the following
    -- path separator as an extra separator at the end of the path that can be
    -- disregarded

    if (path.length >= 2 and
        StringPrototypeCharCodeAt(path, 1) == CHAR_COLON and
        isWindowsDeviceRoot(StringPrototypeCharCodeAt(path, 0))) {
      start = startPart = 2;
    }

    for (local i = path.length - 1; i >= start; --i) {
      local code = StringPrototypeCharCodeAt(path, i);
      if (isPathSeparator(code)) {
        -- If we reached a path separator that was not part of a set of path
        -- separators at the end of the string, stop now
        if (not matchedSlash) {
          startPart = i + 1;
          break;
        }
        continue;
      }
      if (end == -1) {
        -- We saw the first non-path separator, mark this as the end of our
        -- extension
        matchedSlash = false;
        end = i + 1;
      }
      if (code == CHAR_DOT) {
        -- If this is our first dot, mark it as the start of our extension
        if (startDot == -1)
          startDot = i;
        else if (preDotState ~= 1)
          preDotState = 1;
      } else if (startDot ~= -1) {
        -- We saw a non-dot and non-path separator before our dot, so we should
        -- have a good chance at having a non-empty extension
        preDotState = -1;
      }
    }

    if (startDot == -1 or
        end == -1 or
        -- We saw a non-dot character immediately before the dot
        preDotState == 0 or
        -- The (right-most) trimmed path component is exactly '..'
        (preDotState == 1 and
         startDot == end - 1 and
         startDot == startPart + 1)) {
      return '';
    }
    return StringPrototypeSlice(path, startDot, end);
  },

  format: FunctionPrototypeBind(_format, null, '\\'),

  --[[
   * @param {string} path
   * @returns {{
   *  dir: string;
   *  root: string;
   *  base: string;
   *  name: string;
   *  ext: string;
   *  }}
   ]]--
  parse(path) {
    validateString(path, 'path');

    local ret = { root: '', dir: '', base: '', ext: '', name: '' };
    if (path.length == 0)
      return ret;

    local len = path.length;
    local rootEnd = 0;
    local code = StringPrototypeCharCodeAt(path, 0);

    if (len == 1) {
      if (isPathSeparator(code)) {
        -- `path` contains just a path separator, exit early to avoid
        -- unnecessary work
        ret.root = ret.dir = path;
        return ret;
      }
      ret.base = ret.name = path;
      return ret;
    }
    -- Try to match a root
    if (isPathSeparator(code)) {
      -- Possible UNC root

      rootEnd = 1;
      if (isPathSeparator(StringPrototypeCharCodeAt(path, 1))) {
        -- Matched double path separator at beginning
        local j = 2;
        local last = j;
        -- Match 1 or more non-path separators
        while (j < len and
               not isPathSeparator(StringPrototypeCharCodeAt(path, j))) {
          j++;
        }
        if (j < len and j ~= last) {
          -- Matchednot
          last = j;
          -- Match 1 or more path separators
          while (j < len and
                 isPathSeparator(StringPrototypeCharCodeAt(path, j))) {
            j++;
          }
          if (j < len and j ~= last) {
            -- Matchednot
            last = j;
            -- Match 1 or more non-path separators
            while (j < len and
                   not isPathSeparator(StringPrototypeCharCodeAt(path, j))) {
              j++;
            }
            if (j == len) {
              -- We matched a UNC root only
              rootEnd = j;
            } else if (j ~= last) {
              -- We matched a UNC root with leftovers
              rootEnd = j + 1;
            }
          }
        }
      }
    } else if (isWindowsDeviceRoot(code) and
               StringPrototypeCharCodeAt(path, 1) == CHAR_COLON) {
      -- Possible device root
      if (len <= 2) {
        -- `path` contains just a drive root, exit early to avoid
        -- unnecessary work
        ret.root = ret.dir = path;
        return ret;
      }
      rootEnd = 2;
      if (isPathSeparator(StringPrototypeCharCodeAt(path, 2))) {
        if (len == 3) {
          -- `path` contains just a drive root, exit early to avoid
          -- unnecessary work
          ret.root = ret.dir = path;
          return ret;
        }
        rootEnd = 3;
      }
    }
    if (rootEnd > 0)
      ret.root = StringPrototypeSlice(path, 0, rootEnd);

    local startDot = -1;
    local startPart = rootEnd;
    local end = -1;
    local matchedSlash = true;
    local i = path.length - 1;

    -- Track the state of characters (if any) we see before our first dot and
    -- after any path separator we find
    local preDotState = 0;

    -- Get non-dir info
    for (; i >= rootEnd; --i) {
      code = StringPrototypeCharCodeAt(path, i);
      if (isPathSeparator(code)) {
        -- If we reached a path separator that was not part of a set of path
        -- separators at the end of the string, stop now
        if (not matchedSlash) {
          startPart = i + 1;
          break;
        }
        continue;
      }
      if (end == -1) {
        -- We saw the first non-path separator, mark this as the end of our
        -- extension
        matchedSlash = false;
        end = i + 1;
      }
      if (code == CHAR_DOT) {
        -- If this is our first dot, mark it as the start of our extension
        if (startDot == -1)
          startDot = i;
        else if (preDotState ~= 1)
          preDotState = 1;
      } else if (startDot ~= -1) {
        -- We saw a non-dot and non-path separator before our dot, so we should
        -- have a good chance at having a non-empty extension
        preDotState = -1;
      }
    }

    if (end ~= -1) {
      if (startDot == -1 or
          -- We saw a non-dot character immediately before the dot
          preDotState == 0 or
          -- The (right-most) trimmed path component is exactly '..'
          (preDotState == 1 and
           startDot == end - 1 and
           startDot == startPart + 1)) {
        ret.base = ret.name = StringPrototypeSlice(path, startPart, end);
      } else {
        ret.name = StringPrototypeSlice(path, startPart, startDot);
        ret.base = StringPrototypeSlice(path, startPart, end);
        ret.ext = StringPrototypeSlice(path, startDot, end);
      }
    }

    -- If the directory is the root, use the entire root as the `dir` including
    -- the trailing slash if any (`C:\abc` -> `C:\`). Otherwise, strip out the
    -- trailing slash (`C:\abc\def` -> `C:\abc`).
    if (startPart > 0 and startPart ~= rootEnd)
      ret.dir = StringPrototypeSlice(path, 0, startPart - 1);
    else
      ret.dir = ret.root;

    return ret;
  },

  sep: '\\',
  delimiter: ';',
  win32: null,
  posix: null
};

local posixCwd = (() => {
  if (platformIsWin32) {
    -- Converts Windows' backslash path separators to POSIX forward slashes
    -- and truncates any drive indicator
    local regexp = /\\/g;
    return () => {
      local cwd = StringPrototypeReplace(uv.cwd(), regexp, '/');
      return StringPrototypeSlice(cwd, StringPrototypeIndexOf(cwd, '/'));
    };
  }

  -- We're already on POSIX, no need for any transformations
  return () => uv.cwd();
})();

local posix = {
  --[[
   * path.resolve([from ...], to)
   * @param {...string} args
   * @returns {string}
   ]]--
  resolve(...args) {
    local resolvedPath = '';
    local resolvedAbsolute = false;

    for (local i = args.length - 1; i >= -1 and not resolvedAbsolute; i--) {
      local path = i >= 0 ? args[i] : posixCwd();

      validateString(path, 'path');

      -- Skip empty entries
      if (path.length == 0) {
        continue;
      }

      resolvedPath = `${path}/${resolvedPath}`;
      resolvedAbsolute =
        StringPrototypeCharCodeAt(path, 0) == CHAR_FORWARD_SLASH;
    }

    -- At this point the path should be resolved to a full absolute path, but
    -- handle relative paths to be safe (might happen when uv.cwd() fails)

    -- Normalize the path
    resolvedPath = normalizeString(resolvedPath, not resolvedAbsolute, '/',
                                   isPosixPathSeparator);

    if (resolvedAbsolute) {
      return `/${resolvedPath}`;
    }
    return resolvedPath.length > 0 ? resolvedPath : '.';
  },

  --[[
   * @param {string} path
   * @returns {string}
   ]]--
  normalize(path) {
    validateString(path, 'path');

    if (path.length == 0)
      return '.';

    local isAbsolute =
      StringPrototypeCharCodeAt(path, 0) == CHAR_FORWARD_SLASH;
    local trailingSeparator =
      StringPrototypeCharCodeAt(path, path.length - 1) == CHAR_FORWARD_SLASH;

    -- Normalize the path
    path = normalizeString(path, not isAbsolute, '/', isPosixPathSeparator);

    if (path.length == 0) {
      if (isAbsolute)
        return '/';
      return trailingSeparator ? './' : '.';
    }
    if (trailingSeparator)
      path += '/';

    return isAbsolute ? `/${path}` : path;
  },

  --[[
   * @param {string} path
   * @returns {boolean}
   ]]--
  isAbsolute(path) {
    validateString(path, 'path');
    return path.length > 0 and
           StringPrototypeCharCodeAt(path, 0) == CHAR_FORWARD_SLASH;
  },

  --[[
   * @param {...string} args
   * @returns {string}
   ]]--
  join(...args) {
    if (args.length == 0)
      return '.';
    local joined;
    for (local i = 0; i < args.length; ++i) {
      local arg = args[i];
      validateString(arg, 'path');
      if (arg.length > 0) {
        if (joined == nil)
          joined = arg;
        else
          joined += `/${arg}`;
      }
    }
    if (joined == nil)
      return '.';
    return posix.normalize(joined);
  },

  --[[
   * @param {string} from
   * @param {string} to
   * @returns {string}
   ]]--
  relative(from, to) {
    validateString(from, 'from');
    validateString(to, 'to');

    if (from == to)
      return '';

    -- Trim leading forward slashes.
    from = posix.resolve(from);
    to = posix.resolve(to);

    if (from == to)
      return '';

    local fromStart = 1;
    local fromEnd = from.length;
    local fromLen = fromEnd - fromStart;
    local toStart = 1;
    local toLen = to.length - toStart;

    -- Compare paths to find the longest common path from root
    local length = (fromLen < toLen ? fromLen : toLen);
    local lastCommonSep = -1;
    local i = 0;
    for (; i < length; i++) {
      local fromCode = StringPrototypeCharCodeAt(from, fromStart + i);
      if (fromCode ~= StringPrototypeCharCodeAt(to, toStart + i))
        break;
      else if (fromCode == CHAR_FORWARD_SLASH)
        lastCommonSep = i;
    }
    if (i == length) {
      if (toLen > length) {
        if (StringPrototypeCharCodeAt(to, toStart + i) == CHAR_FORWARD_SLASH) {
          -- We get here if `from` is the exact base path for `to`.
          -- For example: from='/foo/bar'; to='/foo/bar/baz'
          return StringPrototypeSlice(to, toStart + i + 1);
        }
        if (i == 0) {
          -- We get here if `from` is the root
          -- For example: from='/'; to='/foo'
          return StringPrototypeSlice(to, toStart + i);
        }
      } else if (fromLen > length) {
        if (StringPrototypeCharCodeAt(from, fromStart + i) ==
            CHAR_FORWARD_SLASH) {
          -- We get here if `to` is the exact base path for `from`.
          -- For example: from='/foo/bar/baz'; to='/foo/bar'
          lastCommonSep = i;
        } else if (i == 0) {
          -- We get here if `to` is the root.
          -- For example: from='/foo/bar'; to='/'
          lastCommonSep = 0;
        }
      }
    }

    local out = '';
    -- Generate the relative path based on the path difference between `to`
    -- and `from`.
    for (i = fromStart + lastCommonSep + 1; i <= fromEnd; ++i) {
      if (i == fromEnd or
          StringPrototypeCharCodeAt(from, i) == CHAR_FORWARD_SLASH) {
        out += out.length == 0 ? '..' : '/..';
      }
    }

    -- Lastly, append the rest of the destination (`to`) path that comes after
    -- the common path parts.
    return `${out}${StringPrototypeSlice(to, toStart + lastCommonSep)}`;
  },

  --[[
   * @param {string} path
   * @returns {string}
   ]]--
  toNamespacedPath(path) {
    -- Non-op on posix systems
    return path;
  },

  --[[
   * @param {string} path
   * @returns {string}
   ]]--
  dirname(path) {
    validateString(path, 'path');
    if (path.length == 0)
      return '.';
    local hasRoot = StringPrototypeCharCodeAt(path, 0) == CHAR_FORWARD_SLASH;
    local end = -1;
    local matchedSlash = true;
    for (local i = path.length - 1; i >= 1; --i) {
      if (StringPrototypeCharCodeAt(path, i) == CHAR_FORWARD_SLASH) {
        if (not matchedSlash) {
          end = i;
          break;
        }
      } else {
        -- We saw the first non-path separator
        matchedSlash = false;
      }
    }

    if (end == -1)
      return hasRoot ? '/' : '.';
    if (hasRoot and end == 1)
      return '//';
    return StringPrototypeSlice(path, 0, end);
  },

  --[[
   * @param {string} path
   * @param {string} [ext]
   * @returns {string}
   ]]--
  basename(path, ext) {
    if (ext ~= nil)
      validateString(ext, 'ext');
    validateString(path, 'path');

    local start = 0;
    local end = -1;
    local matchedSlash = true;

    if (ext ~= nil and ext.length > 0 and ext.length <= path.length) {
      if (ext == path)
        return '';
      local extIdx = ext.length - 1;
      local firstNonSlashEnd = -1;
      for (local i = path.length - 1; i >= 0; --i) {
        local code = StringPrototypeCharCodeAt(path, i);
        if (code == CHAR_FORWARD_SLASH) {
          -- If we reached a path separator that was not part of a set of path
          -- separators at the end of the string, stop now
          if (not matchedSlash) {
            start = i + 1;
            break;
          }
        } else {
          if (firstNonSlashEnd == -1) {
            -- We saw the first non-path separator, remember this index in case
            -- we need it if the extension ends up not matching
            matchedSlash = false;
            firstNonSlashEnd = i + 1;
          }
          if (extIdx >= 0) {
            -- Try to match the explicit extension
            if (code == StringPrototypeCharCodeAt(ext, extIdx)) {
              if (--extIdx == -1) {
                -- We matched the extension, so mark this as the end of our path
                -- component
                end = i;
              }
            } else {
              -- Extension does not match, so our result is the entire path
              -- component
              extIdx = -1;
              end = firstNonSlashEnd;
            }
          }
        }
      }

      if (start == end)
        end = firstNonSlashEnd;
      else if (end == -1)
        end = path.length;
      return StringPrototypeSlice(path, start, end);
    }
    for (local i = path.length - 1; i >= 0; --i) {
      if (StringPrototypeCharCodeAt(path, i) == CHAR_FORWARD_SLASH) {
        -- If we reached a path separator that was not part of a set of path
        -- separators at the end of the string, stop now
        if (not matchedSlash) {
          start = i + 1;
          break;
        }
      } else if (end == -1) {
        -- We saw the first non-path separator, mark this as the end of our
        -- path component
        matchedSlash = false;
        end = i + 1;
      }
    }

    if (end == -1)
      return '';
    return StringPrototypeSlice(path, start, end);
  },

  --[[
   * @param {string} path
   * @returns {string}
   ]]--
  extname(path) {
    validateString(path, 'path');
    local startDot = -1;
    local startPart = 0;
    local end = -1;
    local matchedSlash = true;
    -- Track the state of characters (if any) we see before our first dot and
    -- after any path separator we find
    local preDotState = 0;
    for (local i = path.length - 1; i >= 0; --i) {
      local code = StringPrototypeCharCodeAt(path, i);
      if (code == CHAR_FORWARD_SLASH) {
        -- If we reached a path separator that was not part of a set of path
        -- separators at the end of the string, stop now
        if (not matchedSlash) {
          startPart = i + 1;
          break;
        }
        continue;
      }
      if (end == -1) {
        -- We saw the first non-path separator, mark this as the end of our
        -- extension
        matchedSlash = false;
        end = i + 1;
      }
      if (code == CHAR_DOT) {
        -- If this is our first dot, mark it as the start of our extension
        if (startDot == -1)
          startDot = i;
        else if (preDotState ~= 1)
          preDotState = 1;
      } else if (startDot ~= -1) {
        -- We saw a non-dot and non-path separator before our dot, so we should
        -- have a good chance at having a non-empty extension
        preDotState = -1;
      }
    }

    if (startDot == -1 or
        end == -1 or
        -- We saw a non-dot character immediately before the dot
        preDotState == 0 or
        -- The (right-most) trimmed path component is exactly '..'
        (preDotState == 1 and
         startDot == end - 1 and
         startDot == startPart + 1)) {
      return '';
    }
    return StringPrototypeSlice(path, startDot, end);
  },

  format: FunctionPrototypeBind(_format, null, '/'),

  --[[
   * @param {string} path
   * @returns {{
   *   dir: string;
   *   root: string;
   *   base: string;
   *   name: string;
   *   ext: string;
   *   }}
   ]]--
  parse(path) {
    validateString(path, 'path');

    local ret = { root: '', dir: '', base: '', ext: '', name: '' };
    if (path.length == 0)
      return ret;
    local isAbsolute =
      StringPrototypeCharCodeAt(path, 0) == CHAR_FORWARD_SLASH;
    local start;
    if (isAbsolute) {
      ret.root = '/';
      start = 1;
    } else {
      start = 0;
    }
    local startDot = -1;
    local startPart = 0;
    local end = -1;
    local matchedSlash = true;
    local i = path.length - 1;

    -- Track the state of characters (if any) we see before our first dot and
    -- after any path separator we find
    local preDotState = 0;

    -- Get non-dir info
    for (; i >= start; --i) {
      local code = StringPrototypeCharCodeAt(path, i);
      if (code == CHAR_FORWARD_SLASH) {
        -- If we reached a path separator that was not part of a set of path
        -- separators at the end of the string, stop now
        if (not matchedSlash) {
          startPart = i + 1;
          break;
        }
        continue;
      }
      if (end == -1) {
        -- We saw the first non-path separator, mark this as the end of our
        -- extension
        matchedSlash = false;
        end = i + 1;
      }
      if (code == CHAR_DOT) {
        -- If this is our first dot, mark it as the start of our extension
        if (startDot == -1)
          startDot = i;
        else if (preDotState ~= 1)
          preDotState = 1;
      } else if (startDot ~= -1) {
        -- We saw a non-dot and non-path separator before our dot, so we should
        -- have a good chance at having a non-empty extension
        preDotState = -1;
      }
    }

    if (end ~= -1) {
      local start = startPart == 0 and isAbsolute ? 1 : startPart;
      if (startDot == -1 or
          -- We saw a non-dot character immediately before the dot
          preDotState == 0 or
          -- The (right-most) trimmed path component is exactly '..'
          (preDotState == 1 and
          startDot == end - 1 and
          startDot == startPart + 1)) {
        ret.base = ret.name = StringPrototypeSlice(path, start, end);
      } else {
        ret.name = StringPrototypeSlice(path, start, startDot);
        ret.base = StringPrototypeSlice(path, start, end);
        ret.ext = StringPrototypeSlice(path, startDot, end);
      }
    }

    if (startPart > 0)
      ret.dir = StringPrototypeSlice(path, 0, startPart - 1);
    else if (isAbsolute)
      ret.dir = '/';

    return ret;
  },

  sep: '/',
  delimiter: ':',
  win32: null,
  posix: null
};

posix.win32 = win32.win32 = win32;
posix.posix = win32.posix = posix;

-- Legacy internal API, docs-only deprecated: DEP0080
win32._makeLong = win32.toNamespacedPath;
posix._makeLong = posix.toNamespacedPath;

module.exports = platformIsWin32 ? win32 : posix;
