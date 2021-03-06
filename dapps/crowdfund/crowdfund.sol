contract crowdfund {
    
    struct contribution {
        address sender;
        uint256 value;
    }
    
    struct campaign {
        address recipient;
        uint256 goal;
        uint256 deadline;
        uint256 contrib_total;
        uint256 contrib_count;
        mapping (int => contribution) contrib;
    }
    
    mapping (uint256 => campaign) campaigns;
    
    function create_campaign (uint256 id, address recipient, uint256 goal, uint256 deadline) {
        campaign c = campaigns[id];
        
        if (c.recipient != 0) return;
        
        c.recipient = recipient;
        c.goal = goal;
        c.deadline = deadline;   
    }
    
    function contribute (uint256 id) {
        campaign c = campaigns[id];
        
        var total = c.contrib_total + msg.value;
        c.contrib_total = total;
        
        contribution con = c.contrib[int256(c.contrib_total)];
        
        con.sender = msg.sender;
        con.value = msg.value;
        
        c.contrib_count++;
        
        if (total >= c.goal) {
            c.recipient.send (total);
            this.clear (id);
            return;
        }
        
        if (block.timestamp > c.deadline) {
            for (int256 i = 0; i < int256(c.contrib_count);i++) {
                c.contrib [i].sender.send (c.contrib[i].value);
            }
            this.clear (id);
        }
    }
    
    function clear (uint256 id) {
        if (address(this) == msg.sender) {
            campaign c = campaigns[id];
            
            c.recipient = 0;
            c.goal = 0;
            c.deadline = 0;
            c.contrib_total = 0;
            
            for (int256 i=0;i< int256(c.contrib_count);i++){
                c.contrib [i].sender = 0;
                c.contrib [i].value = 0;
            }
            
            c.contrib_count = 0;
        }
    }
    
    function get_total (uint256 id) returns (uint256 total) {
        return campaigns[id].contrib_total;
    }
    
    function get_recipient (uint256 id) returns (address recipient) {
        return campaigns[id].recipient;
    }
    
    function get_deadline (uint256 id) returns (uint256 deadline) {
        return campaigns[id].deadline;
    }
    
    function get_goal (uint256 id) returns (uint256 goal) {
        return campaigns[id].goal;
    }
    
    function get_free_id () returns (uint256 id) {
        uint256 i = 0;
        while (campaigns[i].recipient != 0) i++;
        return i;
    }
}
