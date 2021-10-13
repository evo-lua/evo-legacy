
	-- For each pathSegment do (from RIGHT to LEFT!)

	-- last segment only:
	-- if after resolving the final segment, no drive was resolved, use cwd as the leftmost path segment
	-- if after... there is a drive, use that drive's cwd or the current cwd if it's unavailable. If no cwd was found, default to the drive root

	-- all BUT the last one:
	-- validate it is a string (fail otherwise)
	-- skip if it's empty (empty string, "", #segment == 0)

	-- ALL (last AND the other ones):


	local pathSegments = { ... }
	p(pathSegments)

	-- Check segments and normalize them (TBD: split this?)
	for index, segment in ipairs(pathSegments) do
		-- All arguments passed must be strings
		if type(segment) ~= "string" then return nil, "Usage: resolve(path1, [path2, ..., pathN])" end

		-- Transform slashes for consistency (to make processing easier)
		local normalizedSegment = normalizeString(segment, false, "\\")
		print(format("Normalizing path segment: %s --> %s", segment, normalizedSegment))
		pathSegments[index] = normalizedSegment
	end

	p(pathSegments)

	-- local args = { path, ... }
	-- p(args)
	-- -- if #args == 0  then return nil, "Usage: resolve(path1, [path2, ..., pathN])" end
	-- -- if #args == 0  then return nil, "Usage: resolve(path1, [path2, ..., pathN])" end
	-- if type(path) ~= "string" then return nil, "Usage: resolve(path1, [path2, ..., pathN])" end

-- 	local hasDriveLetter = (string_find(path, "[A-Za-z]:/")
-- 	--or string_find(path, "[A-Za-z]:\\")
-- ) ~= nil
-- 	print("has drive letter: ", hasDriveLetter)
-- 	local driveLetter = ""
-- 	if hasDriveLetter then
-- 		driveLetter = string.sub(path, 1, 1)
-- 		print("Drive letter:", driveLetter)
-- 	end

	-- for

	-- return "c:\\blah\\a"

    -- local resolvedDevice = '';
    -- local resolvedTail = '';
    -- local resolvedAbsolute = false;

    -- for i = #args, -1, -1 do
	-- 	local continue = false
	-- 	local path
	-- 	if (i >= 0) then

	-- 		path = args[i];
	-- 		if type(path) ~= "string" then return nil, "Usage: resolve(path)" end

	-- 		-- Skip empty entries
	-- 		if (#path == 0) then
	-- 			continue = true
	-- 		end
	-- 	elseif (#resolvedDevice == 0) then
	-- 		path = uv.cwd()
	-- 	else
	-- 		-- Windows has the concept of drive-specific current working
	-- 		-- directories. If we've resolved a drive letter but not yet an
	-- 		-- absolute path, get cwd for that drive, or the process cwd if
	-- 		-- the drive cwd is not available. We're sure the device is not
	-- 		-- a UNC path at this point, because UNC paths are always absolute.
	-- 		error(resolvedDevice)
	-- 		-- path = process.env[`=${resolvedDevice}`] or uv.cwd();

	-- 		-- Verify that a cwd was found and that it actually points
	-- 		-- to our drive. If not, default to the drive's root.
	-- 		if (path == nil or
	-- 			(StringPrototypeToLowerCase(StringPrototypeSlice(path, 0, 2)) ~=
	-- 			StringPrototypeToLowerCase(resolvedDevice) and
	-- 			StringPrototypeCharCodeAt(path, 2) == CHAR_BACKWARD_SLASH)) then
	-- 			path = format("%s\\", resolvedDevice)
	-- 		end
	-- 	end

	-- 	if not continue then
	-- 		local len = #path;
	-- 		local rootEnd = 0;
	-- 		local device = '';
	-- 		local isAbsolute = false;
	-- 		local code = StringPrototypeCharCodeAt(path, 0);

	-- 		-- Try to match a root
	-- 		if (len == 1) then
	-- 		if (isPathSeparator(code)) then
	-- 		-- `path` contains just a path separator
	-- 		rootEnd = 1;
	-- 		isAbsolute = true;
	-- 		end
	-- 		elseif (isPathSeparator(code)) then
	-- 		-- Possible UNC root

	-- 		-- If we started with a separator, we know we at least have an
	-- 		-- absolute path of some kind (UNC or otherwise)
	-- 		isAbsolute = true;

	-- 		if (isPathSeparator(StringPrototypeCharCodeAt(path, 1))) then
	-- 		-- Matched double path separator at beginning
	-- 		local j = 2;
	-- 		local last = j;
	-- 		-- Match 1 or more non-path separators
	-- 		while (j < len and
	-- 		not isPathSeparator(StringPrototypeCharCodeAt(path, j))) do
	-- 		j = j + 1;
	-- 		end
	-- 		if (j < len and j ~= last) then
	-- 		local firstPart = StringPrototypeSlice(path, last, j);
	-- 		-- Matchednot
	-- 		last = j;
	-- 		-- Match 1 or more path separators
	-- 		while (j < len and
	-- 		isPathSeparator(StringPrototypeCharCodeAt(path, j))) do
	-- 		j = j + 1;
	-- 		end

	-- 		if (j < len and j ~= last) then
	-- 		-- Matchednot
	-- 		last = j;
	-- 		-- Match 1 or more non-path separators
	-- 		while (j < len and
	-- 		not isPathSeparator(StringPrototypeCharCodeAt(path, j))) do
	-- 		j = j + 1
	-- 		end
	-- 		if (j == len or j ~= last) then
	-- 		-- We matched a UNC root
	-- 		device = format("\\\\%s\\%s", firstPart, StringPrototypeSlice(path, last, j))
	-- 		rootEnd = j;
	-- 		end
	-- 		end
	-- 		end
	-- 		else
	-- 		rootEnd = 1;
	-- 		end
	-- 		elseif (isWindowsDeviceRoot(code) and
	-- 		StringPrototypeCharCodeAt(path, 1) == CHAR_COLON) then
	-- 		-- Possible device root
	-- 		device = StringPrototypeSlice(path, 0, 2);
	-- 		rootEnd = 2;
	-- 		if (len > 2 and isPathSeparator(StringPrototypeCharCodeAt(path, 2))) then
	-- 		-- Treat separator following drive name as an absolute path
	-- 		-- indicator
	-- 		isAbsolute = true;
	-- 		rootEnd = 3;
	-- 		end
	-- 		end

	-- 		if (#device > 0) then
	-- 		if (#resolvedDevice > 0) then
	-- 		if (StringPrototypeToLowerCase(device) ~=
	-- 		StringPrototypeToLowerCase(resolvedDevice)) then
	-- 		-- This path points to another device so it is not applicable
	-- 		-- continue; -- TODO
	-- 		error("continue NYI")
	-- 		else
	-- 		resolvedDevice = device;
	-- 		end
	-- 		end

	-- 		if (resolvedAbsolute) then
	-- 		if (#resolvedDevice > 0) then
	-- 		break;
	-- 		end
	-- 		else
	-- 		resolvedTail = format("%s\\%s", StringPrototypeSlice(path, rootEnd), resolvedTail)
	-- 		resolvedAbsolute = isAbsolute;
	-- 		if (isAbsolute and #resolvedDevice > 0) then
	-- 		break;
	-- 		end
	-- 		end
	-- 		end
	-- 	end

	-- 	continue = false
	-- end
    -- -- At this point the path should be resolved to a full absolute path,
    -- -- but handle relative paths to be safe (might happen when uv.cwd()
    -- -- fails)

    -- -- Normalize the tail path
    -- resolvedTail = normalizeString(resolvedTail, not resolvedAbsolute, '\\');

    -- return resolvedAbsolute and format("%s\\%s", resolvedDevice, resolvedTail) or (format("%s%s", resolvedDevice, resolvedTail) or '.')