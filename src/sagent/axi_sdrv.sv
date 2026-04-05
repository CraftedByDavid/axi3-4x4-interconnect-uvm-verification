class axi_sdrv extends uvm_driver#(axi_trans);

	`uvm_component_utils(axi_sdrv);

	virtual axi_sif sif;
	axi_sagent_config scfgh;

	axi_trans th,th1;
	axi_trans q1[$],q2[$],q3[$];
	
	//write_channel
	semaphore sem_awad = new(); //write_data_dependent_addr
	semaphore sem_wdrp = new(); //write_response_dependent_data
	semaphore sem_awaddr = new(1); //write_address
	semaphore sem_awdata = new(1); //write_data
	semaphore sem_wrp = new(1); //write_response
	semaphore sem_awrp = new(1); //write_response_dependent_data_address
	//read_channel
	semaphore sem_radc = new(); //read_data_dependent_addr
	semaphore sem_rac = new(1); //read_address
	semaphore sem_rdc = new(1); //read_data

	int count,ending;

	function new(string name = "axi_sdrv", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);		
		if(!uvm_config_db#(axi_sagent_config)::get(this,"","axi_sagent_config",scfgh))
		begin
			`uvm_fatal("axi_sagent_config","FAILED TO GET CONTENTS IN  SLAVE DRIVER");
		end
	endfunction

	function void connect_phase(uvm_phase phase);
		sif=scfgh.svif;
	endfunction

	task run_phase(uvm_phase phase);
		forever
		begin
			drive(req);
		end
	endtask

	task drive(axi_trans th);
		th=axi_trans::type_id::create("th");
		fork
		begin
			sem_awaddr.get(1);
			read_awaddr(th);
			sem_awaddr.put(1);
			sem_awad.put(1);
		end		
		begin
			sem_awad.get(1);
			sem_awdata.get(1);
			read_data(q1.pop_front());
			sem_awdata.put(1);
			sem_wdrp.put(1);
		end		
		begin
			sem_wdrp.get(1);
			sem_wrp.get(1);
			drive_wresp(q2.pop_front());
			sem_wrp.put(1);
		end		
		begin
			sem_rac.get(1);
			slave_raddr();
			sem_rac.put(1);
			sem_radc.put(1);
		end		
		begin
			sem_radc.get(1);
			sem_rdc.get(1);
			slave_rdata(q3.pop_front());
			sem_rdc.put(1);
		end		
		join_any
		//join
	endtask

	task read_awaddr(axi_trans th);
		`uvm_info("SLAVE DRIVER","START OF READ_AWADDR",UVM_MEDIUM);

		@(sif.slv_drv_cb);
		sif.slv_drv_cb.AWREADY <= 1;

		@(sif.slv_drv_cb);
		wait(sif.slv_drv_cb.AWVALID)
		begin
			th.AWID = sif.slv_drv_cb.AWID;
			th.AWLEN = sif.slv_drv_cb.AWLEN;
			th.AWSIZE = sif.slv_drv_cb.AWSIZE;		
			th.AWBURST = sif.slv_drv_cb.AWBURST;
			th.AWVALID = sif.slv_drv_cb.AWVALID;
			th.AWADDR = sif.slv_drv_cb.AWADDR;
		end
		
		q1.push_back(th);
		q2.push_back(th);
		sif.slv_drv_cb.AWREADY <= 0;

		@(sif.slv_drv_cb);
		`uvm_info("SLAVE DRIVER",$sformatf("READ_AWADDR :- \n %0s",th.sprint()),UVM_LOW);

		`uvm_info("SLAVE DRIVER","END OF READ_AWADDR",UVM_MEDIUM);
	endtask

	task read_data(axi_trans th);
		int mem[int];

		`uvm_info("SLAVE DRIVER","START OF READ_DATA",UVM_MEDIUM);

		th.addr_calc();

		`uvm_info("SLAVE DRIVER",$sformatf("ALIGNED ADDRESS =%0h",th.aligned_addr),UVM_MEDIUM);
		for(int i=0;i<(th.AWLEN+1);i++)
		begin
			sif.slv_drv_cb.WREADY <= 1;
			@(sif.slv_drv_cb);
			wait(sif.slv_drv_cb.WVALID)

			if(sif.slv_drv_cb.WSTRB==15)
				mem[th.addr[i]] = sif.slv_drv_cb.WDATA;	

			if(sif.slv_drv_cb.WSTRB==14)
				mem[th.addr[i]] = sif.slv_drv_cb.WDATA[31:8];

			if(sif.slv_drv_cb.WSTRB==12)
				mem[th.addr[i]] = sif.slv_drv_cb.WDATA[31:16];		

			if(sif.slv_drv_cb.WSTRB==8)
				mem[th.addr[i]] = sif.slv_drv_cb.WDATA[31:24];	

			if(sif.slv_drv_cb.WSTRB==7)
				mem[th.addr[i]] = sif.slv_drv_cb.WDATA[23:0];	

			if(sif.slv_drv_cb.WSTRB==4)
				mem[th.addr[i]] = sif.slv_drv_cb.WDATA[23:16];

			if(sif.slv_drv_cb.WSTRB==3)
				mem[th.addr[i]] = sif.slv_drv_cb.WDATA[15:0];

			if(sif.slv_drv_cb.WSTRB==2)
				mem[th.addr[i]] = sif.slv_drv_cb.WDATA[15:8];

			if(sif.slv_drv_cb.WSTRB==1)
				mem[th.addr[i]] = sif.slv_drv_cb.WDATA[7:0];

			sif.slv_drv_cb.WREADY <= 0;
			@(sif.slv_drv_cb);
			count=1;
		end

		`uvm_info("SLAVE DRIVER",$sformatf("MEMORY = %0p",mem),UVM_MEDIUM);

		`uvm_info("SLAVE DRIVER","END OF READ_DATA",UVM_MEDIUM);
	endtask

	task drive_wresp(axi_trans th);
		`uvm_info("SLAVE DRIVER","START OF DRIVE_WRESP",UVM_MEDIUM);

		sif.slv_drv_cb.BVALID <= 1;
		sif.slv_drv_cb.BRESP <= 0;
		sif.slv_drv_cb.BID <= th.AWID;

		@(sif.slv_drv_cb);
		wait(sif.slv_drv_cb.BREADY)		
			sif.slv_drv_cb.BVALID <= 0;
			sif.slv_drv_cb.BRESP <= 'hx;
	
		@(sif.slv_drv_cb);

		`uvm_info("SLAVE DRIVER","END OF DRIVE_WRESP",UVM_MEDIUM);
	endtask

	task slave_raddr();
		`uvm_info("SLAVE DRIVER","START OF SLAVE_RADDR",UVM_MEDIUM);

		th1=axi_trans::type_id::create("th1");

		@(sif.slv_drv_cb);
		sif.slv_drv_cb.ARREADY <= 1;

		@(sif.slv_drv_cb);
		wait(sif.slv_drv_cb.ARVALID)
			th1.ARID = sif.slv_drv_cb.ARID;
			th1.ARADDR = sif.slv_drv_cb.ARADDR;
			th1.ARLEN = sif.slv_drv_cb.ARLEN;
			th1.ARSIZE = sif.slv_drv_cb.ARSIZE;		
			th1.ARBURST = sif.slv_drv_cb.ARBURST;
		sif.slv_drv_cb.ARREADY <= 0;
	
		q3.push_back(th1);

		@(sif.slv_drv_cb);
		//sif.slv_drv_cb.ARREADY <= 0;

		`uvm_info("SLAVE DRIVER",$sformatf("SLAVE_RADDR :- \n %0s",th1.sprint()),UVM_LOW);

		`uvm_info("SLAVE DRIVER","END OF SLAVE_RADDR",UVM_MEDIUM);
	endtask

	task slave_rdata(axi_trans th1);
		int length = th1.ARLEN;

		`uvm_info("SLAVE DRIVER","START OF SLAVE_RDATA",UVM_MEDIUM);

		for(int i=0;i<length+1;i++)
		begin
			sif.slv_drv_cb.RDATA <= $urandom;
			//`uvm_info("SLAVE DRIVER",$sformatf("SLAVE_RDATA - RDATA :- %0d",sif.slv_drv_cb.RDATA),UVM_NONE);
			sif.slv_drv_cb.RVALID <= 1;
			sif.slv_drv_cb.RID <= th1.ARID;
			sif.slv_drv_cb.RRESP <= 0;

			if(i==length)
				sif.slv_drv_cb.RLAST <= 1;
			else
				sif.slv_drv_cb.RLAST <= 0;

			@(sif.slv_drv_cb);
			wait(sif.slv_drv_cb.RREADY)		
				sif.slv_drv_cb.RVALID <= 0;
				sif.slv_drv_cb.RLAST <= 0;
				sif.slv_drv_cb.RRESP <= 'hx;

			@(sif.slv_drv_cb);
			count=1;
		end
		`uvm_info("SLAVE DRIVER","END OF SLAVE_RDATA",UVM_MEDIUM);
	endtask

endclass

/*
class axi_sdrv extends uvm_driver#(axi_strans);

	`uvm_component_utils(axi_sdrv);

	function new(string name = "axi_sdrv", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

endclass
*/