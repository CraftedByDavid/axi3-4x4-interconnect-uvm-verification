class axi_smon extends uvm_monitor;

	`uvm_component_utils(axi_smon);

	virtual axi_sif sif;
	axi_sagent_config scfgh;
	uvm_analysis_port #(axi_trans) smp;

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

	function new(string name = "axi_smon", uvm_component parent);
		super.new(name,parent);
		smp=new("smp",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);		
		if(!uvm_config_db#(axi_sagent_config)::get(this,"","axi_sagent_config",scfgh))
		begin
			`uvm_fatal("axi_sagent_config","FAILED TO GET CONTENTS IN SLAVE MONITOR");
		end
	endfunction

	function void connect_phase(uvm_phase phase);
		sif=scfgh.svif;
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
		`uvm_info("SLAVE MONITOR","START OF COLLECT_WADDR",UVM_MEDIUM);

		th=axi_trans::type_id::create("th");
		wait(sif.slv_mon_cb.AWVALID && sif.slv_mon_cb.AWREADY)
			th.AWVALID = sif.slv_mon_cb.AWVALID;
			th.AWADDR = sif.slv_mon_cb.AWADDR;
			th.AWSIZE = sif.slv_mon_cb.AWSIZE;
			th.AWID = sif.slv_mon_cb.AWID;
			th.AWLEN = sif.slv_mon_cb.AWLEN;
			th.AWBURST = sif.slv_mon_cb.AWBURST;

		q1.push_back(th);
		smp.write(th);
		`uvm_info("SLAVE MONITOR",$sformatf("COLLECT_AWADDR :- \n %0s",th.sprint()),UVM_LOW);
		//th.print();
		
		@(sif.slv_mon_cb);

		`uvm_info("SLAVE MONITOR","END OF COLLECT_WADDR",UVM_MEDIUM);
	endtask

	task collect_wdata(axi_trans th);
		`uvm_info("SLAVE MONITOR","START OF COLLECT_WDATA",UVM_MEDIUM);

		th1=axi_trans::type_id::create("th1");
		//th1=th;
		th1.copy(th);
		th.addr_calc();
		th1.WDATA = new[th.AWLEN+1];
		th1.WSTRB = new[th.AWLEN+1];
		//th1.WSTRB = new[th.WDATA.size()];

		foreach(th1.WDATA[i])
		begin
			wait(sif.slv_mon_cb.WVALID && sif.slv_mon_cb.WREADY)
			th1.WSTRB[i] = sif.slv_mon_cb.WSTRB;
			if(sif.slv_mon_cb.WSTRB==15)
				th1.WDATA[i] = sif.slv_mon_cb.WDATA;	

			if(sif.slv_mon_cb.WSTRB==14)
				th1.WDATA[i] = sif.slv_mon_cb.WDATA[31:8];

			if(sif.slv_mon_cb.WSTRB==12)
				th1.WDATA[i] = sif.slv_mon_cb.WDATA[31:16];		

			if(sif.slv_mon_cb.WSTRB==8)
				th1.WDATA[i] = sif.slv_mon_cb.WDATA[31:24];	

			if(sif.slv_mon_cb.WSTRB==7)
				th1.WDATA[i] = sif.slv_mon_cb.WDATA[23:0];	

			if(sif.slv_mon_cb.WSTRB==4)
				th1.WDATA[i] = sif.slv_mon_cb.WDATA[23:16];

			if(sif.slv_mon_cb.WSTRB==3)
				th1.WDATA[i] = sif.slv_mon_cb.WDATA[15:0];

			if(sif.slv_mon_cb.WSTRB==2)
				th1.WDATA[i] = sif.slv_mon_cb.WDATA[15:8];

			if(sif.slv_mon_cb.WSTRB==1)
				th1.WDATA[i] = sif.slv_mon_cb.WDATA[7:0];

			th1.WID = sif.slv_mon_cb.WID;
			th1.WLAST = sif.slv_mon_cb.WLAST;
			th1.WVALID = sif.slv_mon_cb.WVALID;
		
			@(sif.slv_mon_cb);
		end
		
		smp.write(th1);
		`uvm_info("SLAVE MONITOR",$sformatf("COLLECT_WDATA :- \n %0s",th1.sprint()),UVM_LOW);
		//th1.print();
		
		`uvm_info("SLAVE MONITOR","END OF COLLECT_WDATA",UVM_MEDIUM);
	endtask

	task collect_bresp();
		`uvm_info("SLAVE MONITOR","START OF COLLECT_BRESP",UVM_MEDIUM);

		th2=axi_trans::type_id::create("th2");

		wait(sif.slv_mon_cb.BVALID && sif.slv_mon_cb.BREADY)
			th2.BID = sif.slv_mon_cb.BID;
			th2.BRESP = sif.slv_mon_cb.BRESP;			
			smp.write(th2);	
			`uvm_info("SLAVE MONITOR",$sformatf("COLLECT_BRESP :- \n %0s",th2.sprint()),UVM_LOW);
			//th2.print();

		@(sif.slv_mon_cb);

		`uvm_info("SLAVE MONITOR","END OF COLLECT_BRESP",UVM_MEDIUM);
	endtask

	task collect_raddr();
		`uvm_info("SLAVE MONITOR","START OF COLLECT_RADDR",UVM_MEDIUM);

		th3=axi_trans::type_id::create("th3");

		wait(sif.slv_mon_cb.ARVALID && sif.slv_mon_cb.ARREADY)
			th3.ARVALID = sif.slv_mon_cb.ARVALID;
			th3.ARADDR = sif.slv_mon_cb.ARADDR;
			th3.ARSIZE = sif.slv_mon_cb.ARSIZE;
			th3.ARID = sif.slv_mon_cb.ARID;
			th3.ARLEN = sif.slv_mon_cb.ARLEN;
			th3.ARBURST = sif.slv_mon_cb.ARBURST;
			q2.push_back(th3);

		@(sif.slv_mon_cb);
		smp.write(th3);
		`uvm_info("SLAVE MONITOR",$sformatf("COLLECT_RADDR :- \n %0s",th3.sprint()),UVM_LOW);
		//th3.print();

		`uvm_info("SLAVE MONITOR","END OF COLLECT_RADDR",UVM_MEDIUM);
	endtask

	task collect_rdata(axi_trans th);
		`uvm_info("SLAVE MONITOR","START OF COLLECT_RDATA",UVM_MEDIUM);

		th4=axi_trans::type_id::create("th1");
		//th4=th;
		th4.copy(th);
		th4.raddr_calc();
		th4.RDATA = new[th.ARLEN+1];
		//th4.RSTRB = new[th.ARLEN+1];
		//th4.RSTRB = new[th.RDATA.size()];
		//th4.RRESP= new[th.RDATA.size()];
		//th4.rstrb_calc();
		foreach(th4.RDATA[i])
		begin
			//`uvm_info("SLAVE MONITOR",$sformatf("COLLECT_RDATA - RDATA - INTERFACE:- %0d",sif.slv_mon_cb.RDATA),UVM_NONE);
			//`uvm_info("SLAVE MONITOR",$sformatf("COLLECT_RDATA - RDATA - TRANSACTION:- %0d",th4.RDATA[i]),UVM_NONE);						
			wait(sif.slv_mon_cb.RVALID && sif.slv_mon_cb.RREADY)
				th4.RRESP[i] = sif.slv_mon_cb.RRESP;
				th4.RDATA[i] = sif.slv_mon_cb.RDATA;
			//`uvm_info("SLAVE MONITOR",$sformatf("COLLECT_RDATA - RDATA - INTERFACE:- %0d",sif.slv_mon_cb.RDATA),UVM_NONE);
			//`uvm_info("SLAVE MONITOR",$sformatf("COLLECT_RDATA - RDATA - TRANSACTION:- %0d",th4.RDATA[i]),UVM_NONE);
			//`uvm_info("SLAVE MONITOR",$sformatf("COLLECT_RDATA - RSTRB - TRANSACTION:- %0d",th4.RSTRB[i]),UVM_NONE);
			/*
				if(th4.RSTRB[i]==15)
					th4.RDATA[i] = sif.slv_mon_cb.RDATA;	

				if(th4.RSTRB[i]==14)
					th4.RDATA[i] = sif.slv_mon_cb.RDATA[31:8];

				if(th4.RSTRB[i]==12)
					th4.RDATA[i] = sif.slv_mon_cb.RDATA[31:16];		

				if(th4.RSTRB[i]==8)
					th4.RDATA[i] = sif.slv_mon_cb.RDATA[31:24];	

				if(th4.RSTRB[i]==7)
					th4.RDATA[i] = sif.slv_mon_cb.RDATA[23:0];	

				if(th4.RSTRB[i]==4)
					th4.RDATA[i] = sif.slv_mon_cb.RDATA[23:16];

				if(th4.RSTRB[i]==3)
					th4.RDATA[i] = sif.slv_mon_cb.RDATA[15:0];

				if(th4.RSTRB[i]==2)
					th4.RDATA[i] = sif.slv_mon_cb.RDATA[15:8];

				if(th4.RSTRB[i]==1)
					th4.RDATA[i] = sif.slv_mon_cb.RDATA[7:0];
			*/	
				th4.RID = sif.slv_mon_cb.RID;
				th4.RLAST = sif.slv_mon_cb.RLAST;
				th4.RVALID = sif.slv_mon_cb.RVALID;
		
				@(sif.slv_mon_cb);
		end
		
		smp.write(th4);
		`uvm_info("SLAVE MONITOR",$sformatf("COLLECT_RDATA :- \n %0s",th4.sprint()),UVM_LOW);

		`uvm_info("SLAVE MONITOR","END OF COLLECT_RDATA",UVM_MEDIUM);
	endtask

endclass

/*
class axi_smon extends uvm_monitor;

	`uvm_component_utils(axi_smon);

	uvm_analysis_port #(axi_strans) smp;

	function new(string name = "axi_smon", uvm_component parent);
		super.new(name,parent);
		smp=new("smp",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

endclass
*/