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

		module SutController

			def disconnect

				@sut_adapter.disconnect

			end

			def connect( id )

				@sut_adapter.connect( id )

			end

		end # SutController

	end # QT

end # MobyController

MobyUtil::Logger.instance.hook_methods( MobyController::QT::SutController )