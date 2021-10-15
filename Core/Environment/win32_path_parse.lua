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
   local function parse(path)
	DEBUG("parse", path)
    -- validateString(path, 'path');
	if type(path) ~= "string" then return nil, "Usage: parse(path)" end


    local ret = { root = '', dir = '', base = '', ext = '', name = '' };
    if (#path == 0) then
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
            elseif (j ~= last) then
              -- We matched a UNC root with leftovers
              rootEnd = j + 1;
			end
		end
	end
end
    elseif (isWindowsDeviceRoot(code) and
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
    local i = #path - 1;

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
        elseif (preDotState ~= 1) then
          preDotState = 1;
        elseif (startDot ~= -1) then
        -- We saw a non-dot and non-path separator before our dot, so we should
        -- have a good chance at having a non-empty extension
          preDotState = -1;
	  end
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
end