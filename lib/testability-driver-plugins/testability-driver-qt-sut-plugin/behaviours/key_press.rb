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

		module KeyPress

			include MobyBehaviour::QT::Behaviour

			# Perform key press event to object. 
			# == params
			# key::Symbol, scancode or MobyCommand::KeySequence
			# == returns 
			# nil
			# == raises
			# ArgumentError:: Wrong argument type %s for key (Expected: %s)
			# ArgumentError:: Scan code for :%s not defined in keymap
			# ArgumentError:: Error occured during keypress (Response: %s)
			# === examples
			#  @object.press_key(:kTab)       # Symbol defined in sut specific XML
			#  @object.press_key(0x01000001)  # Scancode
			def press_key( key )

				begin

					command = command_params
					command.command_name('KeyPress')
					command.set_require_response( true )

					# raise exception if value type other than Fixnum or Symbol
					Kernel::raise ArgumentError.new( "Wrong argument type %s for key (Expected: %s)" % [ key.class, "Symbol/Fixnum/KeySequence" ] ) unless [ Fixnum, Symbol, MobyCommand::KeySequence ].include?( key.class )  

					# verify that keymap is defined for sut if symbol used. 
					Kernel::raise ArgumentError.new(

					  "Symbol #{ key.inspect } cannot be used due to no keymap defined for #{ @sut.id } in TDriver configuration file."

					) if key.kind_of?( Symbol ) && !MobyUtil::Parameter[ @sut.id ].has_key?( :keymap )

                    @key_sequence = nil
					if key.kind_of?( Symbol )

					  scancode = MobyUtil::Parameter[ @sut.id ][ :keymap ][ key, nil ]
					  scancode = scancode.hex if scancode.kind_of?( String )
					  # raise exception if value is other than fixnum
					  Kernel::raise ArgumentError.new( "Scan code for :%s not defined in keymap" % key ) unless scancode.kind_of?( Fixnum )

					  # add scancode for keypress event
					  command.command_value( scancode.to_s )

					elsif key.kind_of?( MobyCommand::KeySequence )
					
					  @key_sequence = []
					  key.get_sequence.each do | key_event |
					      
					  tempcode = MobyUtil::Parameter[ @sut.id ][ :keymap ][ key_event[ :value ], nil ]
					  tempcode = tempcode.hex if tempcode.kind_of?( String )
						
					  press_type = { :KeyDown => 'KeyPress', :KeyUp => 'KeyRelease' }.fetch( key_event[ :type ] ){ "KeyClick" }
					  @key_sequence << { :value => tempcode, :params => { :name => press_type, :modifiers => "0", :delay => "0" } }
												
					  end					  
					  command.command_value( @key_sequence )
					else

				      scancode = key.to_i
					
					  # raise exception if value is other than fixnum
					  Kernel::raise ArgumentError.new( "Scan code for :%s not defined in keymap" % key ) unless scancode.kind_of?( Fixnum )

					  # add scancode for keypress event
					  command.command_value( scancode.to_s )
					end	

					# execute command & verify that execution passed ("OK" expected as response) 
          @sut.execute_command(command)
					#Kernel::raise RuntimeError.new("Error occured during keypress (Response: %s)" % @response ) unless ( @response = @sut.execute_command(command) ) == "OK" 

				rescue Exception => exception

					MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed press_key with key \"#{ key }\".;#{ identity };press_key;"
					Kernel::raise exception

				end

				MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation press_key executed successfully with key \"#{ key }\".;#{ identity };press_key;"
		
				nil
			
			end

		end

	end
end

MobyUtil::Logger.instance.hook_methods( MobyBehaviour::QT::KeyPress )