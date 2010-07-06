############################################################################
## 
## Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies). 
## All rights reserved. 
## Contact: Nokia Corporation (testabilitydriver@nokia.com) 
## 
## This file is part of TDriver. 
## 
## If you have questions regarding the use of this file, please contact 
## Nokia at testabilitydriver@nokia.com . 
## 
## This library is free software; you can redistribute it and/or 
## modify it under the terms of the GNU Lesser General Public 
## License version 2.1 as published by the Free Software Foundation 
## and appearing in the file LICENSE.LGPL included in the packaging 
## of this file. 
## 
############################################################################



module MobyBehaviour

	module QT

		module Attribute

			include MobyBehaviour::QT::Behaviour

			#TODO: add error checking
			# Tries to set attributes for an widget/object also maybe?
			# == params
			# attribute:: String, attribute name to set
			# value:: String/ Integer, new value for attribute
			# type:: (Optional) Explicit type of attribute. If no type is given, it will be determined based on the format if the value attribute. 
			# == returns
			# nil
			# == raises
			# RuntimeError::
			# === examples
			#  @sut.application.set_attribute('toolTip', 'ToolTip here') 
			#  @sut.application.set_attribute('visible', true) #do not do this, application will only be visible in process list

			def set_attribute(attribute, value, type = nil)

				Kernel::raise ArgumentError.new( "Attribute-name was empty" ) if attribute.empty?
				Kernel::raise ArgumentError.new( "Argument type must be nil or a non empty String." ) unless type.nil? || ( type.kind_of?( String ) && !type.empty? )

				command = command_params #in qt_behaviour 
				command.transitions_off 
				command.command_name( 'SetAttribute' )

				case type

					when nil

						# Implicit typing

						# by class
						if value.kind_of? Integer
							params = { 'attribute_name' => attribute.to_s, 'attribute_value' => value.to_s.strip, 'attribute_type' => 'int'} 

						elsif value.kind_of? Date
							temp_date = value.day.to_s << '.' << value.month.to_s << '.' << value.year.to_s
							params = { 'attribute_name' => attribute.to_s, 'attribute_value' => temp_date, 'attribute_type' => 'QDate' }

						elsif value.kind_of? Time
							params = { 'attribute_name' => attribute.to_s, 'attribute_value' => value.to_i.to_s, 'attribute_type' => 'QDateTime' }

						elsif value.kind_of? DateTime
							params = { 'attribute_name' => attribute.to_s, 'attribute_value' => Time.parse(value.to_s).to_i.to_s, 'attribute_type' => 'QDateTime' }

						elsif value.kind_of? TrueClass
							params = { 'attribute_name' => attribute.to_s, 'attribute_value' => value.to_s.downcase, 'attribute_type' => 'bool'}

						elsif value.kind_of? FalseClass
							params = { 'attribute_name' => attribute.to_s, 'attribute_value' => value.to_s.downcase, 'attribute_type' => 'bool'}

						else
							# by format
							# if ( value.kind_of?( Integer ) || ( value.kind_of?( String ) && value.strip == value.strip.to_i.to_s ) )
							if value.kind_of?( String ) && value.strip == value.strip.to_i.to_s
								params = { 'attribute_name' => attribute.to_s, 'attribute_value' => value.to_s.strip, 'attribute_type' => 'int'}

							elsif (value == true || value == false || (value.kind_of?(String) && (value.strip.downcase == "true" || value.strip.downcase == "false")))
								params = { 'attribute_name' => attribute.to_s, 'attribute_value' => value.to_s.downcase, 'attribute_type' => 'bool'}

							else
								params = { 'attribute_name' => attribute.to_s, 'attribute_value' => value.to_s, 'attribute_type' => 'string'}

							end 

						end

					when "QRect"
						params = { 'attribute_name' => attribute.to_s, 'attribute_value' => value.to_s, 'attribute_type' => 'QRect'}

					when "QPoint"
						params = { 'attribute_name' => attribute.to_s, 'attribute_value' => value.to_s, 'attribute_type' => 'QPoint'} 

					when "QSize"
						params = { 'attribute_name' => attribute.to_s, 'attribute_value' => value.to_s, 'attribute_type' => 'QSize'}

					when "QDateTime"

						params = { 'attribute_name' => attribute.to_s, 'attribute_type' => 'QDateTime' }

						if value.kind_of? String
							params[ 'attribute_value' ] = value.to_s

						elsif value.kind_of? Integer
							params[ 'attribute_value' ] = value.to_s

						elsif value.kind_of? Time 
							params[ 'attribute_value' ] = value.to_i.to_s

						elsif value.kind_of? DateTime 
							params[ 'attribute_value' ] = Time.parse( value.to_s ).to_i.to_s

						else
							Kernel::raise ArgumentError.new( "The value for QDateTime type attributes must be of type String, Integer, Time or DateTime, it was #{value.class.to_s}." )

						end 

					when "QDate"

						params = { 'attribute_name' => attribute.to_s, 'attribute_type' => 'QDate' }

						if value.kind_of? String
							params[ 'attribute_value' ] = value.to_s

						elsif value.kind_of? Date
							temp_date = value.day.to_s << '.' << value.month.to_s << '.' << value.year.to_s
							params[ 'attribute_value' ] = temp_date

						else
							Kernel::raise ArgumentError.new( "The value for QDate type attributes must be of type String or Date, it was #{value.class.to_s}." )

						end

				else

					#puts "Unidentified.\nName: " << attribute.to_s << "\nValue: " << value.to_s << "\nType: " << type.to_s
					params = { 'attribute_name' => attribute.to_s, 'attribute_value' => value.to_s, 'attribute_type' => type.to_s }

				end 

				command.command_params( params )
				command.service( 'objectManipulation' )
				returnValue = @sut.execute_command( command )
			  
   			    returnValue = "OK"
			    begin 
				  returnValue = @sut.execute_command( command )
				rescue
				  MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed when calling method set_attribute with values attribute:#{attribute.to_s} value:#{value.to_s}.;#{identity};set_attribute;"
				  Kernel::raise RuntimeError.new("Setting attribute '%s' to value '%s' failed with error: %s" % [attribute, value, returnValue])
				end
			  
			    MobyUtil::Logger.instance.log "behaviour" , "PASS;The method set_attribute was executed successfully with with values attribute:#{attribute.to_s} value:#{value.to_s}.;#{identity};set_attribute;"
	  
			    nil


			end

		end

	end
end

MobyUtil::Logger.instance.hook_methods( MobyBehaviour::QT::Attribute )