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



module MobyController

	module QT

		module Group

			# Execute the command). 
			# Sends the message to the device using the @sut_adapter (see base class)     
			# == params         
			# == returns
			# == raises
			# NotImplementedError: raised if unsupported command type       
			def execute
			  builder = Nokogiri::XML::Builder.new{
				TasCommands( :id=> application.id.to_s, :transitions => 'true', :service => 'uiCommand', :interval => interval.to_s, :multitouch => multitouch.to_s)
			  }
			  @sut_adapter.set_message_builder(builder)
			  block.call
			  @sut_adapter.send_grouped_request
			end

			def set_adapter( adapter )
				@sut_adapter = adapter
			end

		end #module Action

	end #module QT

end #module MobyController

MobyUtil::Logger.instance.hook_methods( MobyController::QT::Group )