class axi_mmon extends uvm_monitor;

	`uvm_component_utils(axi_mmon);

	virtual axi_mif mif;
	axi_magent_config mcfgh;
	uvm_analysis_port #(axi_trans) mmp;

	axi_trans th,th1,th2,th3,th4;
	axi_trans q1[$],q2[$];

	//write_channel
	semaphore sem_awdc = new(); //write_data_dependent_addr
	semaphore sem_wdrc = new(); //write_response_dependent_data
	semaphore sem_wdc = new(1); //write_data
	semaphore sem_awc = new(1); //write_address
	semaphore sem_wrc = new(1); //write_response
	//read_channel
	semaphore sem_ardc = new(); //read_data_dependent_addr
	semaphore sem_arc = new(1); //read_address
	semaphore sem_rdc = new(1); //read_data

	static int pkt_sent;

	function new(string name = "axi_mmon", uvm_component parent);
		super.new(name,parent);
		mmp=new("mmp",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);		
		if(!uvm_config_db#(axi_magent_config)::get(this,"","axi_magent_config",mcfgh))
		begin
			`uvm_fatal("axi_magent_config","FAILED TO GET CONTENTS IN MASTER MONITOR");
		end
	endfunction

	function void connect_phase(uvm_phase phase);
		mif=mcfgh.mvif;
	endfunction

	task run_phase(uvm_phase phase);
		forever
		begin
			collect_data();
		end
	endtask

	task collect_data();
		fork
		begin
			sem_awc.get(1);
			collect_awaddr();
			sem_awdc.put(1);
			sem_awc.put(1);
		end		
		begin
			sem_awdc.get(1);
			sem_wdc.get(1);
			collect_wdata(q1.pop_front());
			sem_wdc.put(1);
			sem_wdrc.put(1);
		end		
		begin
			sem_wdrc.get(1);
			sem_wrc.get(1);
			collect_bresp();
			sem_wrc.put(1);
		end		
		begin
			sem_arc.get(1);
			collect_raddr();
			sem_arc.put(1);
			sem_ardc.put(1);
		end		
		begin
			sem_ardc.get(1);
			sem_rdc.get(1);
			collect_rdata(q2.pop_front());
			sem_rdc.put(1);
		end		
		join_any
		//join
	endtask

	task collect_awaddr();
		`uvm_info("MASTER MONITOR","START OF COLLECT_WADDR",UVM_MEDIUM);

		th=axi_trans::type_id::create("th");
		wait(mif.mst_mon_cb.AWVALID && mif.mst_mon_cb.AWREADY)
			th.AWVALID = mif.mst_mon_cb.AWVALID;
			th.AWADDR = mif.mst_mon_cb.AWADDR;
			th.AWSIZE = mif.mst_mon_cb.AWSIZE;
			th.AWID = mif.mst_mon_cb.AWID;
			th.AWLEN = mif.mst_mon_cb.AWLEN;
			th.AWBURST = mif.mst_mon_cb.AWBURST;

		q1.push_back(th);
		mmp.write(th);
		pkt_sent++;
		`uvm_info("MASTER MONITOR",$sformatf("COLLECT_AWADDR :- \n %0s",th.sprint()),UVM_LOW);
		//th.print();
		
		@(mif.mst_mon_cb);

		`uvm_info("MASTER MONITOR","END OF COLLECT_WADDR",UVM_MEDIUM);
	endtask

	task collect_wdata(axi_trans th);
		`uvm_info("MASTER MONITOR","START OF COLLECT_WDATA",UVM_MEDIUM);

		th1=axi_trans::type_id::create("th1");
		//th1=th;
		//$cast(th1,th.clone());
		th1.copy(th);
		th1.addr_calc();
		//th1.strb_calc();
		th1.WDATA = new[th.AWLEN+1];
		th1.WSTRB = new[th.AWLEN+1];
		//th1.WSTRB = new[th.WDATA.size()];
		//th1.strb_calc();

		foreach(th1.WDATA[i])
		begin
			//th1.WSTRB[i] = mif.mst_mon_cb.WSTRB;
			//`uvm_info("MASTER MONITOR",$sformatf("COLLECT_WDATA - WSTRB - TRANSACTION:- %0d",th1.WSTRB[i]),UVM_NONE);
			//`uvm_info("MASTER MONITOR",$sformatf("COLLECT_WDATA - WSTRB - INTERFACE:- %0d",mif.mst_mon_cb.WSTRB),UVM_NONE);
			wait(mif.mst_mon_cb.WVALID && mif.mst_mon_cb.WREADY)
			th1.WSTRB[i] = mif.mst_mon_cb.WSTRB;
			//`uvm_info("MASTER MONITOR",$sformatf("COLLECT_WDATA - WSTRB - TRANSACTION:- %0d",th1.WSTRB[i]),UVM_NONE);
			//`uvm_info("MASTER MONITOR",$sformatf("COLLECT_WDATA - WSTRB - INTERFACE:- %0d",mif.mst_mon_cb.WSTRB),UVM_NONE);
			if(mif.mst_mon_cb.WSTRB==15)
				th1.WDATA[i] = mif.mst_mon_cb.WDATA;	

			if(mif.mst_mon_cb.WSTRB==14)
				th1.WDATA[i] = mif.mst_mon_cb.WDATA[31:8];

			if(mif.mst_mon_cb.WSTRB==12)
				th1.WDATA[i] = mif.mst_mon_cb.WDATA[31:16];		

			if(mif.mst_mon_cb.WSTRB==8)
				th1.WDATA[i] = mif.mst_mon_cb.WDATA[31:24];	

			if(mif.mst_mon_cb.WSTRB==7)
				th1.WDATA[i] = mif.mst_mon_cb.WDATA[23:0];	

			if(mif.mst_mon_cb.WSTRB==4)
				th1.WDATA[i] = mif.mst_mon_cb.WDATA[23:16];

			if(mif.mst_mon_cb.WSTRB==3)
				th1.WDATA[i] = mif.mst_mon_cb.WDATA[15:0];

			if(mif.mst_mon_cb.WSTRB==2)
				th1.WDATA[i] = mif.mst_mon_cb.WDATA[15:8];

			if(mif.mst_mon_cb.WSTRB==1)
				th1.WDATA[i] = mif.mst_mon_cb.WDATA[7:0];

			th1.WID = mif.mst_mon_cb.WID;
			th1.WLAST = mif.mst_mon_cb.WLAST;
			th1.WVALID = mif.mst_mon_cb.WVALID;

			@(mif.mst_mon_cb);
		end
		
		mmp.write(th1);
		pkt_sent++;
		`uvm_info("MASTER MONITOR",$sformatf("COLLECT_WDATA :- \n %0s",th1.sprint()),UVM_LOW);
		//th1.print();
		
		`uvm_info("MASTER MONITOR","END OF COLLECT_WDATA",UVM_MEDIUM);
	endtask

	task collect_bresp();
		`uvm_info("MASTER MONITOR","START OF COLLECT_BRESP",UVM_MEDIUM);

		th2=axi_trans::type_id::create("th2");

		wait(mif.mst_mon_cb.BVALID && mif.mst_mon_cb.BREADY)
			th2.BRESP = mif.mst_mon_cb.BRESP;	
			th2.BID = mif.mst_mon_cb.BID;		
			mmp.write(th2);
			pkt_sent++;		
			`uvm_info("MASTER MONITOR",$sformatf("COLLECT_BRESP :- \n %0s",th2.sprint()),UVM_LOW);
			//th2.print();

		@(mif.mst_mon_cb);

		`uvm_info("MASTER MONITOR","END OF COLLECT_BRESP",UVM_MEDIUM);
	endtask

	task collect_raddr();
		`uvm_info("MASTER MONITOR","START OF COLLECT_RADDR",UVM_MEDIUM);

		th3=axi_trans::type_id::create("th3");

		wait(mif.mst_mon_cb.ARVALID && mif.mst_mon_cb.ARREADY)
			th3.ARVALID = mif.mst_mon_cb.ARVALID;
			th3.ARADDR = mif.mst_mon_cb.ARADDR;
			th3.ARSIZE = mif.mst_mon_cb.ARSIZE;
			th3.ARID = mif.mst_mon_cb.ARID;
			th3.ARLEN = mif.mst_mon_cb.ARLEN;
			th3.ARBURST = mif.mst_mon_cb.ARBURST;
			q2.push_back(th3);

		@(mif.mst_mon_cb);
		mmp.write(th3);
		pkt_sent++;
		`uvm_info("MASTER MONITOR",$sformatf("COLLECT_RADDR :- \n %0s",th3.sprint()),UVM_LOW);
		//th3.print();

		`uvm_info("MASTER MONITOR","END OF COLLECT_RADDR",UVM_MEDIUM);
	endtask


	task collect_rdata(axi_trans th);
		`uvm_info("MASTER MONITOR","START OF COLLECT_RDATA",UVM_MEDIUM);

		th4=axi_trans::type_id::create("th4");
		//th4=th;
		//$cast(th4,th.clone());
		th4.copy(th);
		th4.addr_calc();		
		th4.RDATA = new[th.ARLEN+1];
		th4.RSTRB = new[th.RDATA.size()];		
		th4.RRESP = new[th.RDATA.size()];

		foreach(th4.RDATA[i])
		begin
			wait(mif.mst_mon_cb.RVALID && mif.mst_mon_cb.RREADY)
				th4.RRESP[i] = mif.mst_mon_cb.RRESP;
				th4.RDATA[i] = mif.mst_mon_cb.RDATA;
				th4.RID = mif.mst_mon_cb.RID;
				th4.RLAST = mif.mst_mon_cb.RLAST;
				th4.RVALID = mif.mst_mon_cb.RVALID;
				@(mif.mst_mon_cb);
		end
		
		mmp.write(th4);
		pkt_sent++;
		`uvm_info("MASTER MONITOR",$sformatf("COLLECT_RDATA :- \n %0s",th4.sprint()),UVM_LOW);
		//th4.print();
		
		`uvm_info("MASTER MONITOR","END OF COLLECT_RDATA",UVM_MEDIUM);
	endtask

	function void report_phase(uvm_phase phase);
			`uvm_info("MASTER MONITOR",$sformatf("NUMBER OF PACKETS = %0d",pkt_sent),UVM_MEDIUM);
	endfunction
endclass

/*
class axi_mmon extends uvm_monitor;

	`uvm_component_utils(axi_mmon);

	uvm_analysis_port #(axi_mtrans) mmp;

	function new(string name = "axi_mmon", uvm_component parent);
		super.new(name,parent);
		mmp=new("mmp",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

endclass
*/