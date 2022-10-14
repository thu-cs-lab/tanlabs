#!/usr/bin/env python3

import os
import subprocess
import wx
# from client import *

DIR = os.path.dirname(os.path.realpath(__file__))
print(DIR)

def exec_cmd(script, *args):
    print('<<<<<<', ' '.join([script, *args]))
    subprocess.Popen([DIR + '/' + script, *args])

def handle_bird_run(e):
    exec_cmd('run-bird')

def handle_bird_kill(e):
    exec_cmd('kill-bird')

class MainFrame(wx.Frame):
    def get_text(self, pnl, text):
        st = wx.StaticText(pnl, label=text)
        font = st.GetFont()
        font.PointSize = 12
        #font = font.Bold()
        st.SetFont(font)
        return st

    def __init__(self, *args, **kw):
        super(MainFrame, self).__init__(*args, **kw)

        pnl = wx.Panel(self)

        main_sizer = wx.BoxSizer(wx.HORIZONTAL)
        left_sizer = wx.BoxSizer(wx.VERTICAL)
        right_sizer = wx.BoxSizer(wx.VERTICAL)
        main_sizer.Add(left_sizer, wx.SizerFlags(1).Border().Expand())
        main_sizer.Add(right_sizer, wx.SizerFlags(1).Border().Expand())
        pnl.SetSizer(main_sizer)

        test_name_sizer = wx.BoxSizer(wx.HORIZONTAL)
        left_sizer.Add(test_name_sizer, wx.SizerFlags().Expand())
        test_name_sizer.Add(self.get_text(pnl, 'Test Name: '), wx.SizerFlags().Center())
        test_name = wx.TextCtrl(pnl, value='Group 0')
        test_name_sizer.Add(test_name, wx.SizerFlags(1).Expand())

        bird_ctrl_sizer = wx.StaticBoxSizer(wx.HORIZONTAL, pnl, 'Bird Control')
        left_sizer.Add(bird_ctrl_sizer, wx.SizerFlags().Border(wx.TOP).Expand())
        bird_run = wx.Button(pnl, label='Run (&R)')
        bird_ctrl_sizer.Add(bird_run, wx.SizerFlags(1).Border().Expand())
        bird_run.Bind(wx.EVT_BUTTON, handle_bird_run)
        bird_kill = wx.Button(pnl, label='Kill (&K)')
        bird_ctrl_sizer.Add(bird_kill, wx.SizerFlags(1).Border().Expand())
        bird_kill.Bind(wx.EVT_BUTTON, handle_bird_kill)

        network_config_sizer = wx.StaticBoxSizer(wx.VERTICAL, pnl, 'Network Config')
        left_sizer.Add(network_config_sizer, wx.SizerFlags().Border(wx.TOP).Expand())
        my_ip_sizers = []
        my_ips = []
        dut_ip_sizers = []
        dut_ips = []
        for i in range(4):
            my_ip_sizer = wx.BoxSizer(wx.HORIZONTAL)
            my_ip_sizers.append(my_ip_sizer)
            network_config_sizer.Add(my_ip_sizer, wx.SizerFlags().Border().Expand())
            my_ip_sizer.Add(self.get_text(pnl, f'My IP{i + 1}: '), wx.SizerFlags().Center())
            my_ip = wx.TextCtrl(pnl, value=f'2a0e:aa06:497:{i}::2')
            my_ips.append(my_ip)
            my_ip_sizer.Add(my_ip, wx.SizerFlags(1).Expand())

            my_ip_sizer.Add(self.get_text(pnl, f' DUT IP{i + 1}: '), wx.SizerFlags().Center())
            dut_ip = wx.TextCtrl(pnl, value=f'fe80::{i + 1}')
            dut_ips.append(dut_ip)
            my_ip_sizer.Add(dut_ip, wx.SizerFlags(1).Expand())
        network_config_apply = wx.Button(pnl, label='Apply (&N)')
        network_config_sizer.Add(network_config_apply, wx.SizerFlags().Border().Expand())

        basic_test_sizer = wx.StaticBoxSizer(wx.VERTICAL, pnl, 'Basic Forwarding Test')
        left_sizer.Add(basic_test_sizer, wx.SizerFlags().Border(wx.TOP).Expand())
        basic_test_if_sizers = []
        basic_test_check_matrix = []
        for i in range(4):
            basic_test_if_sizer = wx.BoxSizer(wx.HORIZONTAL)
            basic_test_if_sizers.append(basic_test_if_sizer)
            basic_test_sizer.Add(basic_test_if_sizer, wx.SizerFlags().Border())
            basic_test_if_sizer.Add(self.get_text(pnl, f'From IF{i + 1} to: '), wx.SizerFlags().Center())
            basic_test_checks = []
            basic_test_check_matrix.append(basic_test_checks)
            for j in range(4):
                basic_test_check = wx.CheckBox(pnl, label=f'IF{j + 1}')
                basic_test_checks.append(basic_test_check)
                basic_test_if_sizer.Add(basic_test_check)
                font = basic_test_check.GetFont()
                font.PointSize = 12
                basic_test_check.SetFont(font)
                basic_test_check.SetValue(i ^ j == 1)
        basic_test_test = wx.Button(pnl, label='Test (&B)')
        basic_test_sizer.Add(basic_test_test, wx.SizerFlags().Border().Expand())

        fib_test_sizer = wx.StaticBoxSizer(wx.VERTICAL, pnl, 'Forwarding Table Capacity Test')
        left_sizer.Add(fib_test_sizer, wx.SizerFlags().Border(wx.TOP).Expand())
        skip_sizer = wx.BoxSizer(wx.HORIZONTAL)
        fib_test_sizer.Add(skip_sizer, wx.SizerFlags().Border().Expand())
        skip_sizer.Add(self.get_text(pnl, 'Skip: '), wx.SizerFlags().Center())
        skip = wx.TextCtrl(pnl, value='0')
        skip_sizer.Add(skip, wx.SizerFlags(1).Expand())
        count_sizer = wx.BoxSizer(wx.HORIZONTAL)
        fib_test_sizer.Add(count_sizer, wx.SizerFlags().Border().Expand())
        count_sizer.Add(self.get_text(pnl, 'Count: '), wx.SizerFlags().Center())
        count = wx.TextCtrl(pnl, value='1000')
        count_sizer.Add(count, wx.SizerFlags(1).Expand())
        fib_test_config = wx.Button(pnl, label='Configure (&C)')
        fib_test_sizer.Add(fib_test_config, wx.SizerFlags().Border().Expand())
        fib_test_test = wx.Button(pnl, label='Test (&F)')
        fib_test_sizer.Add(fib_test_test, wx.SizerFlags().Border().Expand())

        fib_test_result_sizer = wx.StaticBoxSizer(wx.VERTICAL, pnl, 'Forwarding Table Capacity Test Results')
        left_sizer.Add(fib_test_result_sizer, wx.SizerFlags(1).Border(wx.TOP).Expand())

        right_sizer.Add(self.get_text(pnl, 'Statistics'))
        bird_route_count_sizer = wx.StaticBoxSizer(wx.VERTICAL, pnl, 'Bird Route Count')
        right_sizer.Add(bird_route_count_sizer, wx.SizerFlags().Border(wx.TOP).Expand())
        bird_route_count_if_sizers = []
        bird_route_count_ifs = []
        for i in range(4):
            bird_route_count_if_sizer = wx.BoxSizer(wx.HORIZONTAL)
            bird_route_count_if_sizers.append(bird_route_count_if_sizer)
            bird_route_count_sizer.Add(bird_route_count_if_sizer, wx.SizerFlags().Border())
            bird_route_count_if_sizer.Add(self.get_text(pnl, f'IF{i + 1}: '), wx.SizerFlags().Center())
            bird_route_count_if = self.get_text(pnl, '?')
            bird_route_count_ifs.append(bird_route_count_if)
            bird_route_count_if_sizer.Add(bird_route_count_if, wx.SizerFlags().Center())
        bird_route_count_total_sizer = wx.BoxSizer(wx.HORIZONTAL)
        bird_route_count_sizer.Add(bird_route_count_total_sizer, wx.SizerFlags().Border())
        bird_route_count_total_sizer.Add(self.get_text(pnl, 'Total: '), wx.SizerFlags().Center())
        bird_route_count_total = self.get_text(pnl, '?/?')
        bird_route_count_total_sizer.Add(bird_route_count_total, wx.SizerFlags().Center())

        bandwidth_sizer = wx.StaticBoxSizer(wx.HORIZONTAL, pnl, 'Bandwidth')
        right_sizer.Add(bandwidth_sizer, wx.SizerFlags(1).Border(wx.TOP).Expand())
        bandwidth = wx.StaticBitmap(pnl, size=wx.Size(300, 300))
        bandwidth_sizer.Add(bandwidth, wx.SizerFlags(1).Border().Expand())
        bandwidth.SetScaleMode(wx.StaticBitmap.ScaleMode.Scale_AspectFit)
        bandwidth.SetBitmap(wx.BitmapBundle(wx.Bitmap(DIR + '/../1.png')))

        latency_sizer = wx.StaticBoxSizer(wx.HORIZONTAL, pnl, 'Latency')
        right_sizer.Add(latency_sizer, wx.SizerFlags(1).Border(wx.TOP).Expand())
        latency = wx.StaticBitmap(pnl, size=wx.Size(300, 300))
        latency_sizer.Add(latency, wx.SizerFlags(1).Border().Expand())
        latency.SetScaleMode(wx.StaticBitmap.ScaleMode.Scale_AspectFit)
        latency.SetBitmap(wx.BitmapBundle(wx.Bitmap(DIR + '/../1.png')))

        self.CreateStatusBar()
        self.SetStatusText('Welcome to Router Tester!')

        self.SetSize(950, 950)


if __name__ == '__main__':
    app = wx.App()
    frm = MainFrame(None, title='Router Tester')
    frm.Show()
    app.MainLoop()
