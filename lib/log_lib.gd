extends Node
## Simple log4j-style printer.
##
## Import as a global singleton, set [member log_level], and call the logging methods.


enum LogLevel {NONE=0, ERROR=5, INFO=10, DEBUG=15, TRACE=20}

@export var log_level := LogLevel.INFO


static func print(caller:Node, message:String):
	print("{1}: {2}".format([caller.name, message]))


func _log(message:String, prefix:String):
	print("{0} [{1}] {2}".format(["%-10d" % Time.get_ticks_usec(), prefix, message]))


func trace(message:String):
	if log_level >= LogLevel.TRACE:
		_log(message, "TRACE")


func debug(message:String):
	if log_level >= LogLevel.DEBUG:
		_log(message, "DEBUG")


func info(message:String):
	if log_level >= LogLevel.INFO:
		_log(message, "INFO")


func error(message:String):
	if log_level >= LogLevel.ERROR:
		_log(message, "ERROR")
