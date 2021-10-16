
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
	--   validateObject(pathObject, 'pathObject');
	if type(pathObject) ~= "table" then return nil, "Usage: format(separator, pathObject)" end
	  local dir = pathObject.dir or pathObject.root;
	  local base = pathObject.base or  (pathObject.name or '') .. (pathObject.ext or '')
	  if (not dir) then
		return base;
	  end
	  return (dir == pathObject.root) and (dir .. base) or dir .. sep .. base
	end

	function win32.format(path)
		error("win32.format nyi")
		self = nil
		separator = '\\' -- Windows -- TBD: Does it need \\\\ instead?
		_format(separator, {}) -- no pathobject is needed?
	end



-- todo add tests for these two
function posix.format(path)
	error("posix.format nyi")
end