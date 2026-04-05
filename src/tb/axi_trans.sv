class axi_trans extends uvm_sequence_item;

	`uvm_object_utils(axi_trans);

	//global signals
	bit ARESETN;

	//write address channel signals
	rand bit [3:0] AWID;
	rand bit [31:0] AWADDR;
	rand bit [7:0] AWLEN;
	rand bit [2:0] AWSIZE;
	rand bit [1:0] AWBURST;
	bit AWVALID;
	bit AWREADY;	
	//logic AWVALID;
	//logic AWREADY;

	//write data channel signals
	rand bit [3:0] WID;
	rand bit [31:0] WDATA[];
	bit [3:0] WSTRB[];
	bit WLAST;
	bit WVALID;
	bit WREADY;		
	//logic WLAST;
	//logic WVALID;
	//logic WREADY;	

	//write response channel signals
	rand bit [3:0] BID;
	bit [1:0] BRESP;
	bit BVALID;
	bit BREADY;
	//logic BVALID;
	//logic BREADY;	

	//read address channel signals
	rand bit [3:0] ARID;
	rand bit [31:0] ARADDR;
	rand bit [7:0] ARLEN;
	rand bit [2:0] ARSIZE;
	rand bit [1:0] ARBURST;
	bit ARVALID;
	bit ARREADY;	
	//logic ARVALID;
	//logic ARREADY;

	//read data channel signals
	rand bit [3:0] RID;
	rand bit [31:0] RDATA[];
	bit [1:0] RRESP[];
	bit RLAST;
	bit RVALID;
	bit RREADY;		
	//logic WLAST;
	//logic WVALID;
	//logic WREADY;	

	//write
	bit [31:0] addr[]; //address for memory allocation
	int no_bytes; 
	int aligned_addr;
	int start_addr;

	//read
	bit [3:0] RSTRB[]; //strobe
	bit [31:0] raddr[];
	int no_rbytes; 
	int aligned_raddr;
	int start_raddr;

	rand bit [1:0] write_slave;
	rand bit [1:0] read_slave;


	constraint valid_master_address { 
					(write_slave==0) -> AWADDR inside {[32'h0000_0000:32'h00ff_ffff]};
					write_slave==1 -> AWADDR inside {[32'h0100_0000:32'h01ff_ffff]};
					write_slave==2 -> AWADDR inside {[32'h0200_0000:32'h02ff_ffff]};
					write_slave==3 -> AWADDR inside {[32'h0300_0000:32'h03ff_ffff]};
					}

	constraint valid_slave_address { 
					read_slave==0 -> ARADDR inside {[32'h0000_0000:32'h00ff_ffff]};
					read_slave==1 -> ARADDR inside {[32'h0100_0000:32'h01ff_ffff]};
					read_slave==2 -> ARADDR inside {[32'h0200_0000:32'h02ff_ffff]};
					read_slave==3 -> ARADDR inside {[32'h0300_0000:32'h03ff_ffff]};
					}

	constraint wdata {WDATA.size()==(AWLEN+1);}
	constraint ardata {RDATA.size()==(ARLEN+1);}

	constraint awb {AWBURST dist {0:=10,1:=10,2:=10};}
	constraint arb {ARBURST dist {0:=10,1:=10,2:=10};}

	constraint write_id {AWID==WID; BID==WID;}
	constraint read_id {ARID==RID;}

	constraint aws {AWSIZE dist {0:=10,1:=10,2:=10};}
	constraint ars {ARSIZE dist {0:=10,1:=10,2:=10};}

	constraint awl {AWBURST==2 -> (AWLEN+1) inside {2,4,8,16};}
	constraint arl {ARBURST==2 -> (ARLEN+1) inside {2,4,8,16};}

	constraint write_alignment1 {((AWBURST==2 || AWBURST==0) && AWSIZE==1) -> AWADDR%2 == 0;} //0,2,4,6,.
	constraint write_alignment2 {((AWBURST==2 || AWBURST==0) && AWSIZE==2) -> AWADDR%2 == 4;} //0,4,8,12,
	constraint read_alignment1 {((ARBURST==2 || ARBURST==0) && ARSIZE==1) -> ARADDR%2 == 0;} //0,2,4,6,.
	constraint read_alignment2 {((ARBURST==2 || ARBURST==0) && ARSIZE==2) -> ARADDR%2 == 4;} //0,4,8,12,

	constraint max_wboundary {((2**AWSIZE)*(AWLEN+1)) < 4096;}
	constraint max_rboundary {((2**ARSIZE)*(ARLEN+1)) < 4096;}

	constraint awlen {AWLEN inside {[0:15]};}
	constraint arlen {ARLEN inside {[0:15]};}
	//constraint awlen {AWLEN==1;} //fixed,incr
	//constraint arlen {ARLEN==1;} //fixed,incr
	//constraint awlen {AWLEN==1;} //wrap
	//constraint arlen {ARLEN==1;} //wrap

	constraint strobe_range {
    							foreach(WSTRB[i])
        							WSTRB[i] inside {15,14,12,8,7,4,3,2,1};
							}


	function new(string name = "axi_trans");
		super.new(name);
	endfunction

	function bit do_compare(uvm_object rhs, uvm_comparer comparer);
		axi_trans rhs_;
		if(!$cast(rhs_, rhs))
		begin
			`uvm_fatal("do_compare","failed")
			return 0;
		end
		return (super.do_compare(rhs,comparer) &&  AWADDR==rhs_.AWADDR &&
		AWLEN==rhs_.AWLEN && AWSIZE==rhs_.AWSIZE && AWBURST==rhs_.AWBURST && 
		WDATA==rhs_.WDATA && WSTRB==rhs_.WSTRB && BRESP==rhs_.BRESP &&
		ARADDR==rhs_.ARADDR && ARLEN==rhs_.ARLEN && ARSIZE==rhs_.ARSIZE && 
		ARBURST==rhs_.ARBURST && RDATA==rhs_.RDATA && RRESP==rhs_.RRESP);
		/*
		return (super.do_compare(rhs,comparer) && AWID==rhs_.AWID && AWADDR==rhs_.AWADDR &&
		AWLEN==rhs_.AWLEN && AWSIZE==rhs_.AWSIZE && AWBURST==rhs_.AWBURST && WID==rhs_.WID &&
		WDATA==rhs_.WDATA && WSTRB==rhs_.WSTRB && BID==rhs_.BID && BRESP==rhs_.BRESP &&
		ARID==rhs_.ARID && ARADDR==rhs_.ARADDR && ARLEN==rhs_.ARLEN && ARSIZE==rhs_.ARSIZE && 
		ARBURST==rhs_.ARBURST && RID==rhs_.RID && RDATA==rhs_.RDATA && RRESP==rhs_.RRESP);
		*/
	endfunction

	function void do_print(uvm_printer printer);
		//write_address
		printer.print_field("AWID",this.AWID,4,UVM_DEC);
		printer.print_field("AWADDR",this.AWADDR,32,UVM_HEX);
		printer.print_field("AWLEN",this.AWLEN,4,UVM_DEC);
		printer.print_field("AWSIZE",this.AWSIZE,3,UVM_DEC);
		printer.print_field("AWBURST",this.AWBURST,2,UVM_DEC);

		//write_data
		printer.print_field("WID",this.WID,4,UVM_DEC);
		foreach(this.WDATA[i])
		begin
			printer.print_field("WDATA",this.WDATA[i],32,UVM_HEX);
			printer.print_field("WSTRB",this.WSTRB[i],4,UVM_BIN);
			printer.print_field("WLAST",this.WLAST,1,UVM_DEC);
		end

		//write_response
		printer.print_field("BID",this.BID,4,UVM_DEC);
		printer.print_field("BRESP",this.BRESP,2,UVM_DEC);

		//read_address
		printer.print_field("ARID",this.ARID,4,UVM_DEC);
		printer.print_field("ARADDR",this.ARADDR,32,UVM_HEX);
		printer.print_field("ARLEN",this.ARLEN,8,UVM_DEC);
		printer.print_field("ARSIZE",this.ARSIZE,3,UVM_DEC);
		printer.print_field("ARBURST",this.ARBURST,2,UVM_DEC);

		//read_data
		printer.print_field("RID",this.RID,4,UVM_DEC);
		foreach(this.RDATA[i])
		begin
			printer.print_field("RDATA",this.RDATA[i],32,UVM_HEX);
			printer.print_field("RRESP",this.RRESP[i],2,UVM_DEC);
		end
	endfunction

	function void post_randomize();
		//write
		no_bytes = 2**AWSIZE;
		start_addr = AWADDR;
		aligned_addr = (int'(AWADDR/no_bytes))*no_bytes;
		WSTRB=new[AWLEN+1];		

		//read
		no_rbytes = 2**ARSIZE;
		start_raddr = ARADDR;
		aligned_raddr = (int'(ARADDR/no_bytes))*no_bytes;
	
		addr_calc();
		strb_calc();
		raddr_calc();
		//rstrb_calc();
		
		//$display("write_addr : addr = %0p",addr);
		//$display("write_addr_AWADDR : AWADDR = %0p",AWADDR);		
		//$display("read_addr : raddr = %0p",raddr);
		//$display("read_addr_ARADDR : ARADDR = %0p",ARADDR);
	endfunction

	function void addr_calc();
		bit wb;//wrapping has happened or not?
		int burst_len = AWLEN+1;
		int N = burst_len;
		int wrap_boundary;
		//int wrap_boundary = (int'(AWADDR/(no_bytes*burst_len))) * (no_bytes*burst_len); 
		int addr_n = wrap_boundary+ (no_bytes * burst_len);
		addr = new[AWLEN+1];
		addr[0] = AWADDR;
		no_bytes = 2**AWSIZE;
		wrap_boundary = (int'(AWADDR/(no_bytes*burst_len))) * (no_bytes*burst_len); 
		aligned_addr= (int'(AWADDR/no_bytes))*no_bytes;
		start_addr = AWADDR;

		for(int i=2;i<(burst_len+1);i++)
		begin
			if(AWBURST==0)
				addr[i-1] = AWADDR;
			if(AWBURST==1)
				addr[i-1] = aligned_addr + (i-1)*no_bytes;
			if(AWBURST==2) 
			begin 
				if (wb==0)
				begin
					addr[i-1] = aligned_addr + (i-1)*no_bytes;
					if (addr[i-1]==(wrap_boundary + (no_bytes*burst_len)))
					begin
						addr[i-1] = wrap_boundary;
						wb++;
					end
				end
				else
					addr[i-1]=start_addr+ ((i-1)*no_bytes) - (no_bytes*burst_len);
			end
		end
	endfunction

	function void raddr_calc();
		bit wb;//wrapping has happened or not?
		int burst_len = ARLEN+1;
		int N = burst_len;
		//int wrap_boundary = (int'(ARADDR/(no_rbytes*burst_len))) * (no_rbytes*burst_len);
		int wrap_boundary; 
		int raddr_n = wrap_boundary+ (no_rbytes * burst_len);
		raddr = new[ARLEN+1];
		raddr[0] = ARADDR;
		no_rbytes = 2**ARSIZE;
		wrap_boundary = (int'(ARADDR/(no_rbytes*burst_len))) * (no_rbytes*burst_len); 
		aligned_raddr= (int'(ARADDR/no_rbytes))*no_rbytes;
		start_raddr = ARADDR;

		for(int i=2;i<(burst_len+1);i++)
		begin
			if(ARBURST==0)
				raddr[i-1] = ARADDR;
			if(ARBURST==1)
				raddr[i-1] = aligned_raddr + (i-1)*no_rbytes;
			if(ARBURST==2) 
			begin 
				if (wb==0)
				begin
					raddr[i-1] = aligned_raddr + (i-1)*no_rbytes;
					if (raddr[i-1]==(wrap_boundary + (no_rbytes*burst_len)))
					begin
						raddr[i-1] = wrap_boundary;
						wb++;
					end
				end
				else
					raddr[i-1]=start_raddr+ ((i-1)*no_rbytes) - (no_rbytes*burst_len);
			end
		end
	endfunction
	
	function void strb_calc(); 
		int data_bus_bytes=4;
		int lower_byte_lane,upper_byte_lane;
		int lower_byte_lane_0 = start_addr - ((int'(start_addr/data_bus_bytes))*data_bus_bytes);
		int upper_byte_lane_0 = (aligned_addr+(no_bytes-1))-((int'(start_addr/data_bus_bytes))*data_bus_bytes);
		for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
		begin
			WSTRB [0][j]=1;
		end
		for(int i=1;i<(AWLEN+1); i++)
		begin
			lower_byte_lane = addr[i] - (int'(addr[i]/data_bus_bytes))*data_bus_bytes;
			upper_byte_lane = lower_byte_lane + no_bytes - 1;
			for (int j=lower_byte_lane; j<=upper_byte_lane; j++) 
				WSTRB[i][j]=1;
		end 
	endfunction

	/*
	function void rstrb_calc(); 
		int data_bus_bytes=4;
		int lower_byte_lane,upper_byte_lane;
		int lower_byte_lane_0 = start_raddr - ((int'(start_raddr/data_bus_bytes))*data_bus_bytes);
		int upper_byte_lane_0 = (aligned_raddr+(no_rbytes-1))-((int'(start_raddr/data_bus_bytes))*data_bus_bytes);
		for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
		begin
			RSTRB [0][j]=1;
		end
		for(int i=1;i<(ARLEN+1); i++)
		begin
			lower_byte_lane = raddr[i] - (int'(raddr[i]/data_bus_bytes))*data_bus_bytes;
			upper_byte_lane = lower_byte_lane + no_rbytes - 1;
			for (int j=lower_byte_lane; j<=upper_byte_lane; j++) 
				RSTRB[i][j]=1;
		end 
	endfunction
	*/

	function void do_copy(uvm_object rhs);
		axi_trans rhs_;
		if(!$cast(rhs_, rhs))
		begin
			`uvm_fatal("do_copy","failed")
		end
		super.do_copy(rhs);
		AWID=rhs_.AWID;
		AWADDR=rhs_.AWADDR;
		AWLEN=rhs_.AWLEN;
		AWSIZE=rhs_.AWSIZE;
		AWBURST=rhs_.AWBURST;
		WID=rhs_.WID; 
		WDATA=rhs_.WDATA;
		WSTRB=rhs_.WSTRB;
		BID=rhs_.BID;
		BRESP=rhs_.BRESP;
		ARID=rhs_.ARID;
		ARADDR=rhs_.ARADDR;
		ARLEN=rhs_.ARLEN;
		ARSIZE=rhs_.ARSIZE;
		ARBURST=rhs_.ARBURST;
		RID=rhs_.RID;
		RDATA=rhs_.RDATA;
		RRESP=rhs_.RRESP;
	endfunction

endclass
