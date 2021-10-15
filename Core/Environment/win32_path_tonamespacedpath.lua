	--[[
		* @param {string} path
		* @returns {string}
		]]--
		local function toNamespacedPath(path)
			DEBUG("toNamespacedPath", path)
				  -- Note: this will *probably* throw somewhere.
				  if (type(path) ~= 'string' or #path == 0) then
					return path;
				  end

				  local resolvedPath = win32.resolve(path);

				  if (#resolvedPath <= 2) then
					return path;
				  end

				  if (StringPrototypeCharCodeAt(resolvedPath, 0) == CHAR_BACKWARD_SLASH) then
					-- Possible UNC root
					if (StringPrototypeCharCodeAt(resolvedPath, 1) == CHAR_BACKWARD_SLASH) then
					  local code = StringPrototypeCharCodeAt(resolvedPath, 2);
					  if (code ~= CHAR_QUESTION_MARK and code ~= CHAR_DOT) then
						-- Matched non-long UNC root, convert the path to a long UNC path
						return "\\\\?\\UNC\\" .. StringPrototypeSlice(resolvedPath, 2)
					  end
					end
				 elseif (
					isWindowsDeviceRoot(StringPrototypeCharCodeAt(resolvedPath, 0)) and
					StringPrototypeCharCodeAt(resolvedPath, 1) == CHAR_COLON and
					StringPrototypeCharCodeAt(resolvedPath, 2) == CHAR_BACKWARD_SLASH
				  ) then
					-- Matched device root, convert the path to a long UNC path
					return "\\\\?\\" .. resolvedPath
				  end

				  return path;
				end
