static BBServer *bbServer;
%hook BBServer
    - (id)init {
        bbServer = %orig;
        return bbServer;
    }

    %new
    +(id)NCV_sharedInstance
    {
    	return bbServer;
    }
%end