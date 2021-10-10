
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


	-- path.format, with POSIX separator /
	format: FunctionPrototypeBind(_format, nil, '/'),

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
  -- POSIX path settings
	sep: '/',
	delimiter: ':',
	win32: nil,
	posix: nil
  };