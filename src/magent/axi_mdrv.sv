class axi_mdrv extends uvm_driver#(axi_trans);

	`uvm_component_utils(axi_mdrv);

	//virtual axi_mif.AXI_MDRV mvif;
	virtual axi_mif mif;
	axi_magent_config mcfgh;

	axi_trans th;
	axi_trans q1[$],q2[$],q3[$],q4[$],q5[$];
	
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

	function new(string name = "axi_mdrv", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(axi_magent_config)::get(this,"","axi_magent_config",mcfgh))
		begin
			`uvm_fatal("axi_magent_config","FAILED TO GET CONTENTS IN MASTER DRIVER");
		end
	endfunction

	function void connect_phase(uvm_phase phase);
		mif=mcfgh.mvif;
	endfunction

	task run_phase(uvm_phase phase);
		forever
		begin
			seq_item_port.get_next_item(req);
			drive(req);
			seq_item_port.item_done();
			`uvm_info("MASTER DRIVER",$sformatf("RUN_PHASE :- \n %0s",req.sprint()),UVM_LOW);
			//req.print();
		end
	endtask

	task drive(axi_trans th);
		q1.push_back(th);
		q2.push_back(th);
		q3.push_back(th);	
		q4.push_back(th);
		q5.push_back(th);
		fork
		begin
			sem_awc.get(1);
			drive_awaddr(q1.pop_front());
			sem_awdc.put(1);
			sem_awc.put(1);
		end		
		begin
			sem_awdc.get(1);
			sem_wdc.get(1);
			drive_wdata(q2.pop_front());
			sem_wdc.put(1);
			sem_wdrc.put(1);
		end		
		begin
			sem_wdrc.get(1);
			sem_wrc.get(1);
			drive_bresp(q3.pop_front());
			sem_wrc.put(1);
		end		
		begin
			sem_arc.get(1);
			drive_raddr(q4.pop_front());
			sem_arc.put(1);
			sem_ardc.put(1);
		end		
		begin
			sem_ardc.get(1);
			sem_rdc.get(1);
			drive_rdata(q5.pop_front());
			sem_rdc.put(1);
		end		
		join_any
		//join
	endtask


	task drive_awaddr(axi_trans th);
		`uvm_info("MASTER DRIVER","START OF DRIVE WRITE ADDRESS",UVM_MEDIUM);

		mif.mst_drv_cb.AWVALID <= 1;
		mif.mst_drv_cb.AWADDR <= th.AWADDR;
		mif.mst_drv_cb.AWSIZE<= th.AWSIZE;		
		mif.mst_drv_cb.AWID <= th.AWID;
		mif.mst_drv_cb.AWLEN <= th.AWLEN;
		mif.mst_drv_cb.AWBURST <= th.AWBURST;

		@(mif.mst_drv_cb);
		wait(mif.mst_drv_cb.AWREADY)
			mif.mst_drv_cb.AWVALID <= 0;

		@(mif.mst_drv_cb);

		`uvm_info("MASTER DRIVER","END OF DRIVE WRITE ADDRESS",UVM_MEDIUM);
	endtask

	task drive_wdata(axi_trans th);
		`uvm_info("MASTER DRIVER","START OF DRIVE WRITE DATA",UVM_MEDIUM);

		foreach(th.WDATA[i])
		begin
			//mif.mst_drv_cb.WLAST <= 0;
			mif.mst_drv_cb.WVALID <= 1;
			mif.mst_drv_cb.WDATA <= th.WDATA[i];
			mif.mst_drv_cb.WSTRB <= th.WSTRB[i];
			mif.mst_drv_cb.WID <= th.WID;
			
			if(i==th.AWLEN)
			//if(i==th.WDATA.size()-1)
				mif.mst_drv_cb.WLAST <= 1;
			else
				mif.mst_drv_cb.WLAST <= 0;

			@(mif.mst_drv_cb);
			wait(mif.mst_drv_cb.WREADY)
				mif.mst_drv_cb.WVALID <= 0;
				mif.mst_drv_cb.WLAST <= 0;

			@(mif.mst_drv_cb);
		end	
		//mif.mst_drv_cb.WLAST <= 0;
		`uvm_info("MASTER DRIVER","END OF DRIVE WRITE DATA",UVM_MEDIUM);
	endtask	

	task drive_bresp(axi_trans th);
		`uvm_info("MASTER DRIVER","START OF DRIVE WRITE RESPONSE",UVM_MEDIUM);

		mif.mst_drv_cb.BREADY <= 1;
	
		@(mif.mst_drv_cb);
		wait(mif.mst_drv_cb.BVALID)
			mif.mst_drv_cb.BREADY <= 0;

		@(mif.mst_drv_cb);

		`uvm_info("MASTER DRIVER","END OF DRIVE WRITE RESPONSE",UVM_MEDIUM);
	endtask	

	task drive_raddr(axi_trans th);
		`uvm_info("MASTER DRIVER","START OF DRIVE READ ADDRESS",UVM_MEDIUM);

		@(mif.mst_drv_cb);
		mif.mst_drv_cb.ARID <= th.ARID;
		mif.mst_drv_cb.ARLEN <= th.ARLEN;
		mif.mst_drv_cb.ARSIZE<= th.ARSIZE;
		mif.mst_drv_cb.ARBURST <= th.ARBURST;
		mif.mst_drv_cb.ARADDR <= th.ARADDR;
		mif.mst_drv_cb.ARVALID <= 1;	
		q5.push_back(th);
	
		@(mif.mst_drv_cb);
		wait(mif.mst_drv_cb.ARREADY)
			mif.mst_drv_cb.ARVALID <= 0;

		@(mif.mst_drv_cb);		

		`uvm_info("MASTER DRIVER","END OF DRIVE READ ADDRESS",UVM_MEDIUM);
	endtask	

	task drive_rdata(axi_trans th);	
		`uvm_info("MASTER DRIVER","START OF DRIVE READ DATA",UVM_MEDIUM);

		for(int i=0;i<(th.ARLEN+1);i++)
		begin
			mif.mst_drv_cb.RREADY <= 1;
	
			@(mif.mst_drv_cb);
			wait(mif.mst_drv_cb.RVALID)
				mif.mst_drv_cb.RREADY <= 0;

			@(mif.mst_drv_cb);
		end
	
		`uvm_info("MASTER DRIVER","END OF DRIVE READ DATA",UVM_MEDIUM);
	endtask

endclass

/*
class axi_mdrv extends uvm_driver#(axi_mtrans);

	`uvm_component_utils(axi_mdrv);

	function new(string name = "axi_mdrv", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

endclass
*/