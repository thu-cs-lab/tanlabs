// 'w' means wide.
localparam DATAW_WIDTH = 8 * 48;

localparam VLAN_WIDTH = 8 * 4;

// README: Your code here.
typedef struct packed
{
    logic [15:0] id;
    logic [15:0] ethertype;
} vlan_tag_t;

typedef struct packed
{
    // AXI-Stream signals.
    logic [DATAW_WIDTH - 1:0] data;
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
} frame_data;

// README: Your code here. You can define some other constants like EtherType.
`define MAC_DST (0 * 8) +: 48
`define MAC_SRC (6 * 8) +: 48
`define MAC_TYPE (12 * 8) +: 16
`define IP4_TTL ((14 + 8) * 8) +: 8

localparam ID_CPU = 3'd4;  // The interface ID of CPU is 4.

localparam ETHERTYPE_IP4 = 16'h0008;
localparam ETHERTYPE_VLAN = 16'h0081;

// Incrementally update the checksum in an IPv4 header
// when TTL is decreased by 1.
// Note: This *function* should be a combinational logic.
// Input: old checksum
// Output: new checksum
function [15:0] ip4_update_checksum;
    input [15:0] sum;
begin
    // README: Your code here.
    ip4_update_checksum = 0;
end
endfunction
