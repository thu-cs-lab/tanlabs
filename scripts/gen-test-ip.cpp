#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <cstddef>
#include <cstring>
#include <string>
#include <iostream>
#include <fstream>
#include <random>
#include <vector>
#include <arpa/inet.h>

// g++ -O2 -Wall -std=c++11 gen-test-ip.cpp -o gen-test-ip

struct ip6_addr
{
    uint8_t data[16];
};

struct rt_entry
{
    ip6_addr net;
    ip6_addr nexthop;
    uint32_t prefixlen, nexthop_if;
};

struct rt_node
{
    const rt_entry *entry = nullptr;
    rt_node *prev = nullptr, *next[2] = { nullptr, nullptr };
};

struct rt
{
    rt_node root;
};

int get_bit(ip6_addr a, int bit)
{
    return (a.data[bit / 8] >> (7 - (bit % 8))) & 1;
}

void set_bit(ip6_addr &a, int bit, int val)
{
    if (val)
    {
        a.data[bit / 8] |= 1 << (7 - (bit % 8));
    }
    else
    {
        a.data[bit / 8] &= ~(1 << (7 - (bit % 8)));
    }
}

void rt_insert(rt_node *root, const rt_entry *e)
{
    rt_node *node = root;
    for (uint32_t l = 0; l < e->prefixlen; ++l)
    {
        int i = get_bit(e->net, l);
        if (!node->next[i])
        {
            node->next[i] = new rt_node();
            node->next[i]->prev = node;
        }
        node = node->next[i];
    }
    node->entry = e;
}

const rt_entry *rt_find(rt_node *root, ip6_addr addr)
{
    rt_node *node = root;
    for (uint32_t l = 0; l < 128; ++l)
    {
        int i = get_bit(addr, l);
        if (!node->next[i]) break;
        node = node->next[i];
    }
    while (node)
    {
        if (node->entry) return node->entry;
        node = node->prev;
    }
    return nullptr;
}

ip6_addr parse_ip(const char *str)
{
    ip6_addr addr;
    inet_pton(AF_INET6, str, &addr);
    return addr;
}

std::string format_ip(ip6_addr addr)
{
    char str[INET6_ADDRSTRLEN];
    inet_ntop(AF_INET6, &addr, str, sizeof(str));
    return str;
}

std::mt19937 engine;
std::uniform_int_distribution<int> int_rand(0, 255);

ip6_addr rand_ip()
{
    ip6_addr addr;
    for (uint32_t i = 0; i < sizeof(addr.data); ++i)
    {
        addr.data[i] = int_rand(engine);
    }
    return addr;
}

static bool _rt_find_test_ip(rt_node *node, ip6_addr &out, uint32_t l)
{
    if (!node->next[0] && !node->next[1])
    {
        return true;
    }
    if (!node->next[0] || (!node->next[0]->entry && _rt_find_test_ip(node->next[0], out, l + 1)))
    {
        set_bit(out, l, 0);
        return true;
    }
    if (!node->next[1] || (!node->next[1]->entry && _rt_find_test_ip(node->next[1], out, l + 1)))
    {
        set_bit(out, l, 1);
        return true;
    }
    return false;
}

bool rt_find_test_ip(rt_node *root, const rt_entry *e, ip6_addr *out)
{
    ip6_addr addr = rand_ip();
    rt_node *node = root;
    for (uint32_t l = 0; l < e->prefixlen; ++l)
    {
        int i = get_bit(e->net, l);
        set_bit(addr, l, i);
        assert(node->next[i]);
        node = node->next[i];
    }
    *out = addr;
    return _rt_find_test_ip(node, *out, e->prefixlen);
}

int main(int argc, const char *const *argv)
{
    if (argc < 4)
    {
        std::cerr << "Usage: " << argv[0] << " <fib filename> <skip> <n>" << std::endl;
        exit(1);
    }

    int skip = std::stoi(argv[2]), n = std::stoi(argv[3]);

    std::ifstream fin(argv[1]);
    rt rt;
    std::vector<rt_entry *> entries;
    std::string net, nexthop;
    int prefixlen, nexthop_if;
    while (fin >> net >> prefixlen >> nexthop >> nexthop_if)
    {
        if (skip)
        {
            skip -= 1;
            continue;
        }
        if (!n)
        {
            break;
        }
        rt_entry *e = new rt_entry;
        e->net = parse_ip(net.c_str());
        e->prefixlen = prefixlen;
        e->nexthop = parse_ip(nexthop.c_str());
        e->nexthop_if = nexthop_if;
        rt_insert(&rt.root, e);
        entries.push_back(e);
        n -= 1;
    }

    ip6_addr addr;
    for (rt_entry *e : entries) 
    {
        bool found = rt_find_test_ip(&rt.root, e, &addr);
        if (!found)
        {
            std::cout << std::endl;
        }
        else
        {
            std::cout << format_ip(addr) << " " << format_ip(e->nexthop) << " " << e->nexthop_if << std::endl;
            assert(rt_find(&rt.root, addr) == e);
        }
    }

    while (std::cin >> net)
    {
        const rt_entry *e = rt_find(&rt.root, parse_ip(net.c_str()));
        if (!e)
        {
            std::cout << "no route" << std::endl;
        }
        else
        {
            std::cout << "via " << format_ip(e->nexthop) << " interface " << e->nexthop_if << std::endl;
        }
    }

    return 0;
}
