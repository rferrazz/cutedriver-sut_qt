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



include TDriverVerify

# Application behaviour for Qt

module MobyBehaviour

  module QT

	module Application

	  def drag( start_x, start_y, end_x, end_y, duration = 1000 )

		@sut.execute_command( MobyCommand::Drag.new( start_x, start_y, end_x, end_y, duration ) )

	  end

	  # Kills the application process
	  # Currently only for QT
	  def kill

		@sut.execute_command( MobyCommand::Application.new( :Kill, self.executable_name, self.uid, self.sut, nil ) )

	  end

	  def track_popup(class_name, wait_time=1)
		wait_time = wait_time*1000
		fixture('popup', 'waitPopup',{:className => class_name, :interval => wait_time.to_s})
	  end

	  def verify_popup(class_name, time_out = 5)
		xml_source = nil
		verify(time_out) {xml_source = @sut.application.fixture('popup', 'printPopup',{:className => class_name})}  
		MobyBase::StateObject.new( xml_source )			  
	  end
	  
	  def bring_to_foreground
		@sut.execute_command(MobyCommand::Application.new(:BringToForeground, nil, self.uid, self.sut))
      end

	  def tap_objects(objects)
		raise ArgumentError.new("Nothing to tap") unless objects.kind_of?(Array)

		multitouch_operation{
		  objects.each { |o| o.tap }
		}
		
	  end

	  def tap_down_objects(objects)
		raise ArgumentError.new("Nothing to tap") unless objects.kind_of?(Array)

		multitouch_operation{
		  objects.each { |o| o.tap_down }
		}
		
	  end

	  def tap_up_objects(objects)
		raise ArgumentError.new("Nothing to tap") unless objects.kind_of?(Array)

		multitouch_operation{
		  objects.each { |o| o.tap_up }
		}
		
	  end

	  
	  private
	  
	  def multitouch_operation(&block)

		@sut.freeze
		
		#disable sleep to avoid unnecessary sleeping
		MobyUtil::Parameter[ @sut.id ][ :sleep_disabled] = 'true'
		
		command = MobyCommand::Group.new(0, self, block )
		command.set_multitouch(true)
		ret = @sut.execute_command( command )
		
		MobyUtil::Parameter[ @sut.id ][ :sleep_disabled] = 'false'
		
		@sut.unfreeze
		
	  end

	end

  end

end

MobyUtil::Logger.instance.hook_methods( MobyBehaviour::QT::Application )