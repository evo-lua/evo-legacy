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
  for i = 0, #path, 1 do

	-- append path separator at the end, if it's missing?
    if (i < path.length) then
    	code = StringPrototypeCharCodeAt(path, i);
	else
		if (isPathSeparator(code)) then
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
			dots = dots + 1
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
    -- return isAbsolute ? `${device}\\${tail}` : `${device}${tail}`; -- TODO
end


  --[[
   * @param {string} path
   * @returns {boolean}
   ]]--
   local function isAbsolutePath(path)
    validateString(path, 'path');
    local len = path.length;
    if (len == 0) then
      return false;
	end
    local code = StringPrototypeCharCodeAt(path, 0);
    return isPathSeparator(code) or
      -- Possible device root
      (len > 2 and
      isWindowsDeviceRoot(code) and
      StringPrototypeCharCodeAt(path, 1) == CHAR_COLON and
      isPathSeparator(StringPrototypeCharCodeAt(path, 2)));
   end

  --[[
   * @param {...string} args
   * @returns {string}
   ]]--
  local function joinPath(...)
	local args = { ... }

    if (#args == 0) then
      return '.';
	end
    local joined;
    local firstPart;
    for i = 0, i <= #args, 1 do -- TODO foreach
      local arg = args[i];
      validateString(arg, 'path');
      if (arg.length > 0) then
        if (joined == nil) then
          joined = arg
		  firstPart = arg;
        else
        --   joined = joined .. `\\${arg}`; -- TODO
		end
    end

    if (joined == nil) then
      return '.';
	end
    -- Make sure that the joined path doesn't start with two slashes, because
    -- normalize() will mistake it for a UNC path then.
    --
    -- This step is skipped when it is very clear that the user actually
    -- intended to point at a UNC path. This is assumed when the first
    -- non-empty string arguments starts with exactly two slashes followed by
    -- at least one more non-slash character.
    --
    -- Note that for normalize() to treat a path as a UNC path it needs to
    -- have at least 2 components, so we don't filter for that here.
    -- This means that the user can use join to construct UNC paths from
    -- a server name and a share name; for example:
    --   path.join('--server', 'share') -> '\\\\server\\share\\')
    local needsReplace = true;
    local slashCount = 0;
    if (isPathSeparator(StringPrototypeCharCodeAt(firstPart, 0))) then
      slashCount = slashCount + 1;
      local firstLen = firstPart.length;
      if (firstLen > 1 and
          isPathSeparator(StringPrototypeCharCodeAt(firstPart, 1))) then
			slashCount = slashCount + 1;
        if (firstLen > 2) then
          if (isPathSeparator(StringPrototypeCharCodeAt(firstPart, 2))) then
		  slashCount = slashCount + 1;
          else
            -- We matched a UNC path in the first part
            needsReplace = false;
		  end
        end
	end
end
    if (needsReplace) then
      -- Find any more consecutive slashes we need to replace
      while (slashCount < #joined and
             isPathSeparator(StringPrototypeCharCodeAt(joined, slashCount))) do
				slashCount = slashCount + 1;
			 end

      -- Replace the slashes if needed
      if (slashCount >= 2) then
        -- joined = `\\${StringPrototypeSlice(joined, slashCount)}`; -- todo
	  end

    return win32.normalize(joined); -- todo fix lookup with closure
end


  --[[
   * It will solve the relative path from `from` to `to`, for instancee
   * from = 'C:\\orandea\\test\\aaa'
   * to = 'C:\\orandea\\impl\\bbb'
   * The output of the function should be: '..\\..\\impl\\bbb'
   * @param {string} from
   * @param {string} to
   * @returns {string}
   ]]--
   local function convertRelativePath(from, to)
    validateString(from, 'from');
    validateString(to, 'to');

    if (from == to) then
      return '';
	end

    local fromOrig = win32.resolve(from);
    local toOrig = win32.resolve(to);

    if (fromOrig == toOrig) then
      return '';
	end

    from = StringPrototypeToLowerCase(fromOrig);
    to = StringPrototypeToLowerCase(toOrig);

    if (from == to) then
      return '';
	end

    -- Trim any leading backslashes
    local fromStart = 0;
    while (fromStart < from.length and
           StringPrototypeCharCodeAt(from, fromStart) == CHAR_BACKWARD_SLASH) do
			fromStart = fromStart + 1
		   end
    -- Trim trailing backslashes (applicable to UNC paths only)
    local fromEnd = #from;
    while (
      fromEnd - 1 > fromStart and
      StringPrototypeCharCodeAt(from, fromEnd - 1) == CHAR_BACKWARD_SLASH
    ) do
	  fromEnd = fromEnd - 1
	end
    local fromLen = fromEnd - fromStart;

    -- Trim any leading backslashes
    local toStart = 0;
    while (toStart < to.length and
           StringPrototypeCharCodeAt(to, toStart) == CHAR_BACKWARD_SLASH) do
			toStart = toStart + 1
		   end
    -- Trim trailing backslashes (applicable to UNC paths only)
    local toEnd = to.length;
    while (toEnd - 1 > toStart and
           StringPrototypeCharCodeAt(to, toEnd - 1) == CHAR_BACKWARD_SLASH) do
	  toEnd = toEnd - 1
		   end
    local toLen = toEnd - toStart;

    -- Compare paths to find the longest common path from root
    -- local length = fromLen < toLen ? fromLen : toLen; -- TODO
    local lastCommonSep = -1;
    local i;
    for i = 0, i < length, 1 do
      local fromCode = StringPrototypeCharCodeAt(from, fromStart + i);
      if (fromCode ~= StringPrototypeCharCodeAt(to, toStart + i)) then
        break;
      else if (fromCode == CHAR_BACKWARD_SLASH) then
        lastCommonSep = i;
	  end

    -- We found a mismatch before the first common path separator was seen, so
    -- return the original `to`.
    if (i ~= length) then
      if (lastCommonSep == -1) then
        return toOrig;
	  end
    else
      if (toLen > length) then
        if (StringPrototypeCharCodeAt(to, toStart + i) ==
            CHAR_BACKWARD_SLASH) then
          -- We get here if `from` is the exact base path for `to`.
          -- For example: from='C:\\foo\\bar'; to='C:\\foo\\bar\\baz'
          return StringPrototypeSlice(toOrig, toStart + i + 1);
			end
        if (i == 2) then
          -- We get here if `from` is the device root.
          -- For example: from='C:\\'; to='C:\\foo'
          return StringPrototypeSlice(toOrig, toStart + i);
		end
	end
      if (fromLen > length) then
        if (StringPrototypeCharCodeAt(from, fromStart + i) ==
            CHAR_BACKWARD_SLASH) then
          -- We get here if `to` is the exact base path for `from`.
          -- For example: from='C:\\foo\\bar'; to='C:\\foo'
          lastCommonSep = i;
        else if (i == 2) then
          -- We get here if `to` is the device root.
          -- For example: from='C:\\foo\\bar'; to='C:\\'
          lastCommonSep = 3;
		end
	end
      if (lastCommonSep == -1) then
        lastCommonSep = 0;
	  end
    end

    local out = '';
    -- Generate the relative path based on the path difference between `to` and
    -- `from`
    for i = fromStart + lastCommonSep + 1, i <= fromEnd, 1 do
      if (i == fromEnd or
          StringPrototypeCharCodeAt(from, i) == CHAR_BACKWARD_SLASH) then
        -- out += out.length == 0 ? '..' : '\\..';  -- todo
		  end
		end

    toStart = toStart + lastCommonSep;

    -- Lastly, append the rest of the destination (`to`) path that comes after
    -- the common path parts
    if (out.length > 0) then
    --   return `${out}${StringPrototypeSlice(toOrig, toStart, toEnd)}`; -- todo
	end

    if (StringPrototypeCharCodeAt(toOrig, toStart) == CHAR_BACKWARD_SLASH) then
	  toStart = toStart + 1
    return StringPrototypeSlice(toOrig, toStart, toEnd);
	end

	local type = type

	--[[
		* @param {string} path
		* @returns {string}
		]]--
local function toNamespacedPath(path)
		  -- Note: this will *probably* throw somewhere.
		  if (type(path) ~= 'string' or #path == 0) then
			return path;
		  end

		  local resolvedPath = win32.resolve(path);

		  if (resolvedPath.length <= 2) then
			return path;
		  end

		  if (StringPrototypeCharCodeAt(resolvedPath, 0) == CHAR_BACKWARD_SLASH) then
			-- Possible UNC root
			if (StringPrototypeCharCodeAt(resolvedPath, 1) == CHAR_BACKWARD_SLASH) then
			  local code = StringPrototypeCharCodeAt(resolvedPath, 2);
			  if (code ~= CHAR_QUESTION_MARK and code ~= CHAR_DOT) then
				-- Matched non-long UNC root, convert the path to a long UNC path
				-- return `\\\\?\\UNC\\${StringPrototypeSlice(resolvedPath, 2)}`; -- TODO
			  end
			end
		 else if (
			isWindowsDeviceRoot(StringPrototypeCharCodeAt(resolvedPath, 0)) and
			StringPrototypeCharCodeAt(resolvedPath, 1) == CHAR_COLON and
			StringPrototypeCharCodeAt(resolvedPath, 2) == CHAR_BACKWARD_SLASH
		  ) then
			-- Matched device root, convert the path to a long UNC path
			-- return `\\\\?\\${resolvedPath}`; -- todo
		  end

		  return path;
		end

		  --[[
   * @param {string} path
   * @returns {string}
   ]]--
local function getDirectoryName(path)
		validateString(path, 'path');
		local len = path.length;
		if (len == 0) then
		  return '.';
		end

		local rootEnd = -1;
		local offset = 0;
		local code = StringPrototypeCharCodeAt(path, 0);

		if (len == 1) then
		  -- `path` contains just a path separator, exit early to avoid
		  -- unnecessary work or a dot.
		--   return isPathSeparator(code) ? path : '.';  -- todo
		end

		-- Try to match a root
		if (isPathSeparator(code)) then
		  -- Possible UNC root

		  rootEnd = 1
		  offset = 1;

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
				  return path;
				end
				if (j ~= last) then
				  -- We matched a UNC root with leftovers

				  -- Offset by 1 to include the separator after the UNC root to
				  -- treat it as a "normal root" on top of a (UNC) root
				  rootEnd = j + 1
				  offset = j + 1;
				end
			end
		end
	end
		-- Possible device root
		else if (isWindowsDeviceRoot(code) and
				   StringPrototypeCharCodeAt(path, 1) == CHAR_COLON) then
		--   rootEnd =			len > 2 and isPathSeparator(StringPrototypeCharCodeAt(path, 2)) ? 3 : 2; -- todo
		  offset = rootEnd;
				   end

		local endIndex = -1;
		local matchedSlash = true;
		for i = len - 1, i >= offset, -1 do
		  if (isPathSeparator(StringPrototypeCharCodeAt(path, i))) then
			if (not matchedSlash) then
				endIndex = i;
			  break;
			end
		  else
			-- We saw the first non-path separator
			matchedSlash = false;
		  end
		end

		if (endIndex == -1) then
		  if (rootEnd == -1) then
			return '.';
		  end
		  endIndex = rootEnd;
		end
		return StringPrototypeSlice(path, 0, endIndex);
	end

	--[[
		* @param {string} path
		* @param {string} [ext]
		* @returns {string}
		]]--
		local function getFileName(path, ext)
		  if (ext ~= nil) then
			validateString(ext, 'ext');
		  end
		  validateString(path, 'path');
		  local start = 0;
		  local endIndex = -1;
		  local matchedSlash = true;

		  -- Check for a drive letter prefix so as not to mistake the following
		  -- path separator as an extra separator at the end of the path that can be
		  -- disregarded
		  if (path.length >= 2 and
			  isWindowsDeviceRoot(StringPrototypeCharCodeAt(path, 0)) and
			  StringPrototypeCharCodeAt(path, 1) == CHAR_COLON) then
			start = 2;
			  end

		  if (ext ~= nil and #ext > 0 and #ext <= #path) then
			if (ext == path) then
			  return '';
			end

			local extIdx = ext.length - 1;
			local firstNonSlashEnd = -1;
			for i = #path - 1, i >= start, -1 do -- todo pairs
			  local code = StringPrototypeCharCodeAt(path, i);
			  if (isPathSeparator(code)) then
				-- If we reached a path separator that was not part of a set of path
				-- separators at the end of the string, stop now
				if (not matchedSlash) then
				  start = i + 1;
				  break;
				end
			  else
				if (firstNonSlashEnd == -1) then
				  -- We saw the first non-path separator, remember this index in case
				  -- we need it if the extension ends up not matching
				  matchedSlash = false;
				  firstNonSlashEnd = i + 1;
				end
				if (extIdx >= 0) then
				  -- Try to match the explicit extension
				  if (code == StringPrototypeCharCodeAt(ext, extIdx)) then
					extIdx = extIdx - 1
					if (extIdx == -1) then
					  -- We matched the extension, so mark this as the end of our path
					  -- component
					  endIndex = i;
					end
				else
					-- Extension does not match, so our result is the entire path
					-- component
					extIdx = -1;
					endIndex = firstNonSlashEnd;
				end
			end
		end
	end

			if (start == endIndex) then
				endIndex = firstNonSlashEnd;
			else if (endIndex == -1) then
				endIndex = path.length;
			return StringPrototypeSlice(path, start, endIndex);
			end
		end
		  for i = #path - 1, i >= start, -1 do -- todo pairs, review all for loops for this pattern
			if (isPathSeparator(StringPrototypeCharCodeAt(path, i))) then
			  -- If we reached a path separator that was not part of a set of path
			  -- separators at the end of the string, stop now
			  if (not matchedSlash) then
				start = i + 1;
				break;
			  end
			else if (endIndex == -1) then
			  -- We saw the first non-path separator, mark this as the end of our
			  -- path component
			  matchedSlash = false;
			  endIndex = i + 1;
			end
		end

		  if (endIndex == -1) then
			return '';
		  end

		  return StringPrototypeSlice(path, start, endIndex);
		end

		local function
			--[[
			 * @param {string} path
			 * @returns {string}
			 ]]--
			 getFileExtension(path)
			  validateString(path, 'path');
			  local start = 0;
			  local startDot = -1;
			  local startPart = 0;
			  local endIndex = -1;
			  local matchedSlash = true;
			  -- Track the state of characters (if any) we see before our first dot and
			  -- after any path separator we find
			  local preDotState = 0;

			  -- Check for a drive letter prefix so as not to mistake the following
			  -- path separator as an extra separator at the end of the path that can be
			  -- disregarded

			  if (#path >= 2 and
				  StringPrototypeCharCodeAt(path, 1) == CHAR_COLON and
				  isWindowsDeviceRoot(StringPrototypeCharCodeAt(path, 0))) then
				start = 2
				startPart = 2;
			end

			  for i = #path - 1, i >= start, -1 do -- todo pairs
				local code = StringPrototypeCharCodeAt(path, i);
				if (isPathSeparator(code)) then
				  -- If we reached a path separator that was not part of a set of path
				  -- separators at the end of the string, stop now
				  if (not matchedSlash) then
					startPart = i + 1;
					break;
				  end
				--   continue; -- todo
				end

				if (endIndex == -1) then
				  -- We saw the first non-path separator, mark this as the end of our
				  -- extension
				  matchedSlash = false;
				  endIndex = i + 1;
				end

				if (code == CHAR_DOT) then
				  -- If this is our first dot, mark it as the start of our extension
				  if (startDot == -1) then
					startDot = i;
				  else if (preDotState ~= 1) then
					preDotState = 1;
				else if (startDot ~= -1) then
				  -- We saw a non-dot and non-path separator before our dot, so we should
				  -- have a good chance at having a non-empty extension
				  preDotState = -1;
				end
			end

			  if (startDot == -1 or
			      endIndex == -1 or
				  -- We saw a non-dot character immediately before the dot
				  preDotState == 0 or
				  -- The (right-most) trimmed path component is exactly '..'
				  (preDotState == 1 and
				   startDot == endIndex - 1 and
				   startDot == startPart + 1)) then
				return '';
			  end
			  return StringPrototypeSlice(path, startDot, endIndex);
			end


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
   local function parsePath(path)
    validateString(path, 'path');

    local ret = { root = '', dir = '', base = '', ext = '', name = '' };
    if (path.length == 0) then
      return ret;
	end

    local len = #path;
    local rootEnd = 0;
    local code = StringPrototypeCharCodeAt(path, 0);

    if (len == 1) then
      if (isPathSeparator(code)) then
        -- `path` contains just a path separator, exit early to avoid
        -- unnecessary work
        ret.root = path
		ret.dir = path;
        return ret;
	  end
      ret.base = path
	  ret.name = path;
      return ret;
    end
    -- Try to match a root
    if (isPathSeparator(code)) then
      -- Possible UNC root

      rootEnd = 1;
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
              rootEnd = j;
            else if (j ~= last) then
              -- We matched a UNC root with leftovers
              rootEnd = j + 1;
			end
		end
	end
end
    else if (isWindowsDeviceRoot(code) and
               StringPrototypeCharCodeAt(path, 1) == CHAR_COLON) then
      -- Possible device root
      if (len <= 2) then
        -- `path` contains just a drive root, exit early to avoid
        -- unnecessary work
        ret.root = path
		ret.dir = path;
        return ret;
	  end
      rootEnd = 2;
      if (isPathSeparator(StringPrototypeCharCodeAt(path, 2))) then
        if (len == 3) then
          -- `path` contains just a drive root, exit early to avoid
          -- unnecessary work
          ret.root = path
		  ret.dir = path;
          return ret;
		end
        rootEnd = 3;
	end
end
    if (rootEnd > 0) then
      ret.root = StringPrototypeSlice(path, 0, rootEnd);
	end

    local startDot = -1;
    local startPart = rootEnd;
    local endIndex = -1;
    local matchedSlash = true;
    local i = path.length - 1;

    -- Track the state of characters (if any) we see before our first dot and
    -- after any path separator we find
    local preDotState = 0;

    -- Get non-dir info
    for i = i, i >= rootEnd, -1 do -- todo pairs
      code = StringPrototypeCharCodeAt(path, i);
      if (isPathSeparator(code)) then
        -- If we reached a path separator that was not part of a set of path
        -- separators at the end of the string, stop now
        if (not matchedSlash) then
          startPart = i + 1;
          break;
		end
        -- continue; -- todo
	end
      if (endIndex == -1) then
        -- We saw the first non-path separator, mark this as the end of our
        -- extension
        matchedSlash = false;
        endIndex = i + 1;
	end
      if (code == CHAR_DOT) then
        -- If this is our first dot, mark it as the start of our extension
        if (startDot == -1) then
          startDot = i;
        else if (preDotState ~= 1) then
          preDotState = 1;
      else if (startDot ~= -1) then
        -- We saw a non-dot and non-path separator before our dot, so we should
        -- have a good chance at having a non-empty extension
        preDotState = -1;
	  end
    end

    if (endIndex ~= -1) then
      if (startDot == -1 or
          -- We saw a non-dot character immediately before the dot
          preDotState == 0 or
          -- The (right-most) trimmed path component is exactly '..'
          (preDotState == 1 and
           startDot == endIndex - 1 and
           startDot == startPart + 1)) then
        ret.base = StringPrototypeSlice(path, startPart, endIndex);
		ret.name = StringPrototypeSlice(path, startPart, endIndex);
      else
        ret.name = StringPrototypeSlice(path, startPart, startDot);
        ret.base = StringPrototypeSlice(path, startPart, endIndex);
        ret.ext = StringPrototypeSlice(path, startDot, endIndex);
	  end
    end

    -- If the directory is the root, use the entire root as the `dir` including
    -- the trailing slash if any (`C:\abc` -> `C:\`). Otherwise, strip out the
    -- trailing slash (`C:\abc\def` -> `C:\abc`).
    if (startPart > 0 and startPart ~= rootEnd) then
      ret.dir = StringPrototypeSlice(path, 0, startPart - 1);
    else
      ret.dir = ret.root;

    return ret;
	end

local win32 = {
	resolve = resolveRelativePath,
	normalize = normalizePath,
	isAbsolute = isAbsolutePath,
	join = joinPath,
	relative = convertRelativePath,
	toNamespacedPath = toNamespacedPath,
	dirname = getDirectoryName,
	basename = getFileName,
	extname = getFileExtension,
	parse = parsePath,



-- todo wat?
-- path.format?
  format: FunctionPrototypeBind(_format, nil, '\\'),

-- path.sep?
  sep = '\\',
  delimiter = ';',
  win32 = nil,
  posix = nil
};


-- assign namespaces
posix.win32 = win32
win32.win32 = win32;
posix.posix = posix
win32.posix = posix;

-- probably not relevant?
-- Legacy internal API, docs-only deprecated: DEP0080
win32._makeLong = win32.toNamespacedPath;
posix._makeLong = posix.toNamespacedPath;

-- definitely not relevant, just return the right one?
if ffi.os == "Windows" then
	return win32
else
	return posix
end
-- module.exports = platformIsWin32 ? win32 : posix;