// 'w' means wide.
localparam DATAW_WIDTH = 8 * 48;

// README: Your code here.

typedef struct packed
{
    logic [(DATAW_WIDTH - 8 * 20 - 8 * 14) - 1:0] payload;
    logic [31:0] dst;
    logic [31:0] src;
    logic [15:0] checksum;
    logic [7:0] proto;
    logic [7:0] ttl;
    logic [15:0] flags;
    logic [15:0] id;
    logic [15:0] total_len;
    logic [7:0] dscp_ecn;
    logic [3:0] version;
    logic [3:0] ihl;
} ip4_hdr;

typedef struct packed
{
    logic [(DATAW_WIDTH - 8 * 28 - 8 * 14) - 1:0] payload;
    logic [31:0] tpa;
    logic [47:0] tha;
    logic [31:0] spa;
    logic [47:0] sha;
    logic [15:0] op;
    logic [47:0] magic;
} arp_hdr;

typedef struct packed
{
    union packed
    {
        ip4_hdr ip4;
        arp_hdr arp;
    } payload;
    logic [15:0] ethertype;
    logic [47:0] src;
    logic [47:0] dst;
} ether_hdr;

typedef struct packed
{
    // AXI-Stream signals.
    ether_hdr data;
    logic [DATAW_WIDTH / 8 - 1:0] keep;
    logic last;
    logic [DATAW_WIDTH / 8 - 1:0] user;
    logic [ID_WIDTH - 1:0] id;  // The ingress interface.
    logic valid;

    // Control signals.
    logic is_first;  // Is this the first beat of a frame?

    // Other control signals.
    // **They are only effective at the first beat.**
    logic [ID_WIDTH - 1:0] dest;  // The egress interface.
    logic drop;  // Drop this frame (i.e., this beat and the following beats till the last)?
    logic dont_touch;  // Do not touch this beat!

    // Drop the next frame? It is useful when you need to shrink a frame
    // (e.g., replace an IPv4 packet to an ARP request).
    // You can do so by setting both last and drop_next.
    logic drop_next;

    // README: Your code here.
} frame_beat;

// README: Your code here. You can define some other constants like EtherType.
localparam ID_CPU = 3'd4;  // The interface ID of CPU is 4.

localparam ETHERTYPE_IP4 = 16'h0008;
localparam ETHERTYPE_IP6 = 16'hdd86;
