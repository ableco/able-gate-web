Result = Struct.new(:status, :note)

# This instance of result handles the lack of a result from
# either onboard or offboard operations from a service handler
NULL_RESULT = Result.new(:warning, 'There is not result for this operation')
