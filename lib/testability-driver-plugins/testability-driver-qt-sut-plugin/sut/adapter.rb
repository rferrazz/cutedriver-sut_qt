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



require File.expand_path( File.join( File.dirname( __FILE__ ), 'communication' ) )

module MobyController

	module QT
		
		# Sut adapter that used TCP/IP connections to send and receive data from QT side. 
		class SutAdapter < MobyController::SutAdapter
		
			attr_reader :sut_id

			attr_accessor(

				:socket_read_timeout,
				:socket_write_timeout

			)
		
			# TODO: better way to set the host and port parameters   
			# Initialize the tcp adapter for communicating with the device.
			# Communication is done using two tcp channels one form commanding
			# the device and one for receiving ui state data.
			# UI state data receivin is done in a seprate thread so it is good
			# once usage is complete the shutdown_comms is called
			# == params
			# sut_id id for the sut so that client details can be fetched from params
			def initialize( sut_id, receive_timeout = 25, send_timeout = 25 )

				@socket = nil
				@connected = false

				@sut_id = sut_id

				# set timeouts
				@socket_read_timeout = receive_timeout
				@socket_write_timeout = send_timeout

				@counter = rand( 1000 )

				# connect socket
				#connect( @sut_id )

			end

			def disconnect

				@socket.close if @connected

				@connected = false

			end

			def connect( id = nil )

				id ||= @sut_id

				begin

					@socket = TCPSocket.open( MobyUtil::Parameter[ id ][ :qttas_server_ip ], MobyUtil::Parameter[ id ][ :qttas_server_port ].to_i )

				rescue => ex

					ip = "no ip" if ( ip = MobyUtil::Parameter[ id ][ :qttas_server_ip, "" ] ).empty?
					port = "no port" if ( port = MobyUtil::Parameter[ id ][ :qttas_server_port, "" ] ).empty?

					Kernel::raise IOError.new("Unable to connect QTTAS server, verify that it is running properly (#{ ip }:#{ port }): .\nException: #{ ex.message }")
				end

				@connected = true

			end

			def group?
			  @_group
			end

			# Set the document builder for the grouped behaviour message.
			def set_message_builder(builder)
			  @_group = true
			  @_builder = builder
			end

			def append_command(node_list)		  
			  node_list.each {|ch| @_builder.doc.root.add_child(ch)}				  
			end

			# Sends a grouped command message to the server. Sets group to false and nils the builder
			# to prevent future behviours of being grouped (unless so wanted)
			# == returns    
			# the amout of commands grouped (and send)
			def send_grouped_request
			  @_group = false
			  size = @_builder.doc.root.children.size
			  send_service_request(Comms::MessageGenerator.generate(@_builder.to_xml))
			  @_builder = nil
			  size
			end

			# Send the message to the qt server         
			# If there is no exception propagated the send to the device was successful
			# == params   
			# message:: message in qttas protocol format   
			# == returns    
			# the response body
			def send_service_request( message, return_crc = false )

				connect if !@connected

				# set request message id
				message.message_id = ( @counter += 1 )

				# write request message to socket
				write_socket( message.make_binary_message )

				# read response to determine was the message handled properly and parse the header
				# header[ 0 ] = command_flag, header[ 1 ] = body_size, header[ 2 ] = crc, header[ 3 ] = compression_flag
				header = read_socket( 12 ).unpack( 'CISCI' )

				# read the message body and compare crc checksum
				Kernel::raise IOError.new( "CRC do not match. Maybe the message is corrupted!" ) if CRC::Crc16.crc16_ibm( body = read_socket( header[ 1 ] ) , 0xffff ) != header[ 2 ]

				# return qt response - inlfate the message body if it is compressed
				response = Comms::QTResponse.new( header[ 0 ], ( header[ 3 ] == 2 ? Comms::Inflator.inflate( body ) : body ), header[ 2 ], header[ 4 ] )

				# validate response message
				response.validate_message( @counter )

				# other cases return the body (only really needed in ui state and screenshot situations)
				return_crc ? [ response.msg_body, response.crc ] : response.msg_body

			end

		private

			def read_socket( bytes_count )

				# store time before start receving data
				start_time = Time.now

				# verify that there is data available to be read 
				Kernel::raise IOError.new( "Socket reading timeout (%i) exceeded for %i bytes" % [ @socket_read_timeout, bytes_count ] ) if TCPSocket::select( [ @socket ], nil, nil, @socket_read_timeout ).nil?

				# read data from socket
				read_buffer = @socket.read( bytes_count ){

					Kernel::raise IOError.new( "Socket reading timeout (%i) exceeded for %i bytes" % [ @socket_read_timeout, bytes_count ] ) if ( Time.now - start_time ) > @socket_read_timeout

				}

				Kernel::raise IOError.new( "Socket reading error for %i bytes - No data retrieved" % [ bytes_count ] ) if read_buffer.nil?

				read_buffer

			end

			def write_socket( data )

				@socket.write( data )

				# verify that there is no data in writing buffer 
				Kernel::raise IOError.new( "Socket writing timeout (%i) exceeded for %i bytes" % [ @socket_write_timeout, data.length ] ) if TCPSocket::select( nil, [ @socket ], nil, @socket_write_timeout ).nil?

			end

		end # SutAdapter

	end # QT

end # MobyController

MobyUtil::Logger.instance.hook_methods( MobyController::QT::SutAdapter )