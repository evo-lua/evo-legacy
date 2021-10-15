
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


	-- path.format, with POSIX separator /
	format: FunctionPrototypeBind(_format, nil, '/'),

	  --[[
	   * @param {string} path
	   * @returns {string}
	   ]]--
	   toNamespacedPath(path) {
		-- Non-op on posix systems
		return path;
	  }
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