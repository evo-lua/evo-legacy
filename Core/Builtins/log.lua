local log = {}

-- Severities are based on the standard syslog template, with additions for testing and events
function log.event(message, ...) print("[EVENT]", message, ...) end
function log.test(message, ...) print("[TEST]", message, ...) end
function log.debug(message, ...) print("[DEBUG]", message, ...) end
function log.info(message, ...) print("[INFO]", message, ...) end
function log.notice(message, ...) print("[NOTICE]", message, ...) end
function log.warning(message, ...) print("[WARNING]", message, ...) end
function log.error(message, ...)
	print("[ERROR]", message, ...)
	print(debug.traceback())
end
function log.critical(message, ...) print("[CRITICAL]", message, ...) end
function log.alert(message, ...) print("[ALERT]", message, ...) end
function log.emergency(message, ...) print("[EMERGENCY]", message, ...) end

_G.EVENT = log.event
_G.TEST = log.test
_G.DEBUG = log.debug
_G.INFO = log.info
_G.NOTICE = log.notice
_G.WARNING = log.warning
_G.ERROR = log.error
_G.CRITICAL = log.critical
_G.ALERT = log.alert
_G.EMERGENCY = log.emergency

_G.log = log

return log