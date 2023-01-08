#!/usr/bin/env python3

import datetime
import os
import subprocess
import threading
import wx
from client import *


DIR = os.path.dirname(os.path.realpath(__file__))
RESULTS_DIR = os.path.dirname(DIR) + '/results'
if not os.path.isdir(RESULTS_DIR):
    os.mkdir(RESULTS_DIR)
CONF_DIR = os.path.dirname(DIR) + '/conf'
if not os.path.isdir(CONF_DIR):
    os.mkdir(CONF_DIR)
CONFIG_FILE = CONF_DIR + '/config.json'


def save_config(config):
    with open(CONFIG_FILE, 'w') as f:
        f.write(json.dumps(config))


def load_config():
    try:
        with open(CONFIG_FILE, 'r') as f:
            config = json.loads(f.read())
        config['test_name'] = str(config['test_name'])
        my_ips = []
        dut_ips = []
        for i in range(NINTERFACES):
            my_ips.append(str(ipaddress.IPv6Address(config['my_ips'][i])))
            dut_ips.append(str(ipaddress.IPv6Address(config['dut_ips'][i])))
        config['my_ips'] = my_ips
        config['dut_ips'] = dut_ips
        matrix = []
        for i in range(NINTERFACES):
            row = []
            for j in range(NINTERFACES):
                row.append(bool(config['matrix'][i][j]))
            matrix.append(row)
        config['matrix'] = matrix
        config['skip'] = int(config['skip'])
        config['count'] = int(config['count'])
        config['strict'] = bool(config['strict'])
        config['lfsr'] = bool(config['lfsr'])
    except Exception as e:
        print('Warning: failed to parse config json:', e)
        config = {'test_name': 'Group 0',
                  'my_ips': [], 'dut_ips': [],
                  'matrix': [],
                  'skip': 0, 'count': 1000,
                  'strict': True, 'lfsr': True}
        my_ips = []
        dut_ips = []
        for i in range(NINTERFACES):
            my_ips.append(str(ipaddress.IPv6Address(f'2a0e:aa06:497:{i}::2')))
            dut_ips.append(str(ipaddress.IPv6Address(f'fe80::{i + 1}')))
        config['my_ips'] = my_ips
        config['dut_ips'] = dut_ips
        matrix = []
        for i in range(NINTERFACES):
            row = []
            for j in range(NINTERFACES):
                row.append(i ^ j == 1)
            matrix.append(row)
        config['matrix'] = matrix
        save_config(config)
    return config


class MainFrame(wx.Frame):
    def get_text(self, pnl, text):
        st = wx.StaticText(pnl, label=text)
        font = st.GetFont()
        font.PointSize = 12
        st.SetFont(font)
        return st

    def __init__(self, *args, **kw):
        super(MainFrame, self).__init__(*args, **kw)

        self.my_ips_parsed = None
        self.bird_is_running = False

        self.config = load_config()

        pnl = wx.Panel(self)
        self.panel = pnl

        main_sizer = wx.BoxSizer(wx.HORIZONTAL)
        left_sizer = wx.BoxSizer(wx.VERTICAL)
        right_sizer = wx.BoxSizer(wx.VERTICAL)
        main_sizer.Add(left_sizer, wx.SizerFlags(1).Border().Expand())
        main_sizer.Add(right_sizer, wx.SizerFlags(1).Border().Expand())
        pnl.SetSizer(main_sizer)

        test_name_sizer = wx.BoxSizer(wx.HORIZONTAL)
        left_sizer.Add(test_name_sizer, wx.SizerFlags().Expand())
        test_name_sizer.Add(self.get_text(pnl, 'Test Name: '), wx.SizerFlags().Center())
        self.test_name = wx.TextCtrl(pnl, value=self.config['test_name'])
        test_name_sizer.Add(self.test_name, wx.SizerFlags(1).Expand())

        bird_ctrl_sizer = wx.StaticBoxSizer(wx.HORIZONTAL, pnl, 'Bird Control')
        left_sizer.Add(bird_ctrl_sizer, wx.SizerFlags().Border(wx.TOP).Expand())
        self.bird_run = wx.Button(pnl, label='Run (&R)')
        bird_ctrl_sizer.Add(self.bird_run, wx.SizerFlags(1).Border().Expand())
        self.bird_run.Bind(wx.EVT_BUTTON, self.handle_bird_run)
        self.bird_kill = wx.Button(pnl, label='Kill (&K)')
        bird_ctrl_sizer.Add(self.bird_kill, wx.SizerFlags(1).Border().Expand())
        self.bird_kill.Bind(wx.EVT_BUTTON, self.handle_bird_kill)

        network_config_sizer = wx.StaticBoxSizer(wx.VERTICAL, pnl, 'Network Configuration')
        left_sizer.Add(network_config_sizer, wx.SizerFlags().Border(wx.TOP).Expand())
        my_ip_sizers = []
        self.my_ips = []
        dut_ip_sizers = []
        self.dut_ips = []
        for i in range(NINTERFACES):
            my_ip_sizer = wx.BoxSizer(wx.HORIZONTAL)
            my_ip_sizers.append(my_ip_sizer)
            network_config_sizer.Add(my_ip_sizer, wx.SizerFlags().Border().Expand())
            my_ip_sizer.Add(self.get_text(pnl, f'My IP{i + 1}: '), wx.SizerFlags().Center())
            my_ip = wx.TextCtrl(pnl, value=self.config['my_ips'][i])
            self.my_ips.append(my_ip)
            my_ip_sizer.Add(my_ip, wx.SizerFlags(1).Expand())

            my_ip_sizer.Add(self.get_text(pnl, f' DUT IP{i + 1}: '), wx.SizerFlags().Center())
            dut_ip = wx.TextCtrl(pnl, value=self.config['dut_ips'][i])
            self.dut_ips.append(dut_ip)
            my_ip_sizer.Add(dut_ip, wx.SizerFlags(1).Expand())
        self.network_config_apply = wx.Button(pnl, label='Apply (&N)')
        network_config_sizer.Add(self.network_config_apply, wx.SizerFlags().Border().Expand())
        self.network_config_apply.Bind(wx.EVT_BUTTON, self.handle_network_config_apply)

        basic_test_sizer = wx.StaticBoxSizer(wx.VERTICAL, pnl, 'Basic Forwarding Test')
        left_sizer.Add(basic_test_sizer, wx.SizerFlags().Border(wx.TOP).Expand())
        basic_test_if_sizers = []
        self.basic_test_check_matrix = []
        for i in range(NINTERFACES):
            basic_test_if_sizer = wx.BoxSizer(wx.HORIZONTAL)
            basic_test_if_sizers.append(basic_test_if_sizer)
            basic_test_sizer.Add(basic_test_if_sizer, wx.SizerFlags().Border())
            basic_test_if_sizer.Add(self.get_text(pnl, f'From IF{i + 1} to: '), wx.SizerFlags().Center())
            basic_test_checks = []
            self.basic_test_check_matrix.append(basic_test_checks)
            for j in range(NINTERFACES):
                basic_test_check = wx.CheckBox(pnl, label=f'IF{j + 1}')
                basic_test_checks.append(basic_test_check)
                basic_test_if_sizer.Add(basic_test_check)
                font = basic_test_check.GetFont()
                font.PointSize = 12
                basic_test_check.SetFont(font)
                basic_test_check.SetValue(self.config['matrix'][i][j])
        self.basic_test_test = wx.Button(pnl, label='Test (&B)')
        basic_test_sizer.Add(self.basic_test_test, wx.SizerFlags().Border().Expand())
        self.basic_test_test.Bind(wx.EVT_BUTTON, self.handle_basic_test_test)

        fib_test_sizer = wx.StaticBoxSizer(wx.VERTICAL, pnl, 'Forwarding Table Capacity Test')
        left_sizer.Add(fib_test_sizer, wx.SizerFlags().Border(wx.TOP).Expand())
        skip_count_sizer = wx.BoxSizer(wx.HORIZONTAL)
        fib_test_sizer.Add(skip_count_sizer, wx.SizerFlags().Border().Expand())
        skip_count_sizer.Add(self.get_text(pnl, 'Skip: '), wx.SizerFlags().Center())
        self.skip = wx.TextCtrl(pnl, value=str(self.config['skip']))
        skip_count_sizer.Add(self.skip, wx.SizerFlags(1).Expand())
        skip_count_sizer.Add(self.get_text(pnl, ' Count: '), wx.SizerFlags().Center())
        self.count = wx.TextCtrl(pnl, value=str(self.config['count']))
        skip_count_sizer.Add(self.count, wx.SizerFlags(1).Expand())
        fib_test_check = wx.BoxSizer(wx.HORIZONTAL)
        fib_test_sizer.Add(fib_test_check, wx.SizerFlags().Border().Expand())
        self.fib_test_strict_check = wx.CheckBox(pnl, label=f'Strict')
        fib_test_check.Add(self.fib_test_strict_check, wx.SizerFlags().Border(wx.RIGHT).Expand())
        self.fib_test_strict_check.SetValue(self.config['strict'])
        self.fib_test_lfsr_check = wx.CheckBox(pnl, label=f'Use LFSR')
        fib_test_check.Add(self.fib_test_lfsr_check, wx.SizerFlags().Expand())
        self.fib_test_lfsr_check.SetValue(self.config['lfsr'])
        fib_test_button = wx.BoxSizer(wx.HORIZONTAL)
        fib_test_sizer.Add(fib_test_button, wx.SizerFlags().Border().Expand())
        self.fib_test_config = wx.Button(pnl, label='Configure (&C)')
        fib_test_button.Add(self.fib_test_config, wx.SizerFlags(1).Border(wx.RIGHT).Expand())
        self.fib_test_config.Bind(wx.EVT_BUTTON, self.handle_fib_test_config)
        self.fib_test_download = wx.Button(pnl, label='Download (&D)')
        fib_test_button.Add(self.fib_test_download, wx.SizerFlags(1).Border(wx.LEFT | wx.RIGHT).Expand())
        self.fib_test_download.Bind(wx.EVT_BUTTON, self.handle_fib_test_download)
        self.fib_test_test = wx.Button(pnl, label='Test (&F)')
        fib_test_button.Add(self.fib_test_test, wx.SizerFlags(1).Border(wx.LEFT).Expand())
        self.fib_test_test.Bind(wx.EVT_BUTTON, self.handle_fib_test_test)

        fib_test_result_sizer = wx.StaticBoxSizer(wx.HORIZONTAL, pnl, 'Forwarding Table Capacity Test Results')
        left_sizer.Add(fib_test_result_sizer, wx.SizerFlags(1).Border(wx.TOP).Expand())
        fib_test_result_sizer.Add(self.get_text(pnl, 'Ratio: '), wx.SizerFlags().Border(wx.TOP | wx.LEFT | wx.BOTTOM))
        self.fib_test_result = self.get_text(pnl, '?%')
        fib_test_result_sizer.Add(self.fib_test_result, wx.SizerFlags().Border(wx.TOP | wx.RIGHT | wx.BOTTOM))


        right_sizer.Add(self.get_text(pnl, 'Statistics'))
        bird_route_count_sizer = wx.StaticBoxSizer(wx.VERTICAL, pnl, 'Bird Route Count')
        right_sizer.Add(bird_route_count_sizer, wx.SizerFlags().Border(wx.TOP).Expand())
        bird_route_count_if_sizers = []
        self.bird_route_count_ifs = []
        for i in range(NINTERFACES):
            bird_route_count_if_sizer = wx.BoxSizer(wx.HORIZONTAL)
            bird_route_count_if_sizers.append(bird_route_count_if_sizer)
            bird_route_count_sizer.Add(bird_route_count_if_sizer, wx.SizerFlags().Border())
            bird_route_count_if_sizer.Add(self.get_text(pnl, f'IF{i + 1}: '), wx.SizerFlags().Center())
            bird_route_count_if = self.get_text(pnl, '?')
            self.bird_route_count_ifs.append(bird_route_count_if)
            bird_route_count_if_sizer.Add(bird_route_count_if, wx.SizerFlags().Center())
        bird_route_count_total_sizer = wx.BoxSizer(wx.HORIZONTAL)
        bird_route_count_sizer.Add(bird_route_count_total_sizer, wx.SizerFlags().Border())
        bird_route_count_total_sizer.Add(self.get_text(pnl, 'Total: '), wx.SizerFlags().Center())
        self.bird_route_count_total = self.get_text(pnl, '?/?')
        bird_route_count_total_sizer.Add(self.bird_route_count_total, wx.SizerFlags().Center())
        self.bird_route_count_timer = wx.Timer(self)
        self.Bind(wx.EVT_TIMER, self.handle_bird_route_count_timer)

        throughput_sizer = wx.StaticBoxSizer(wx.HORIZONTAL, pnl, 'Throughput')
        right_sizer.Add(throughput_sizer, wx.SizerFlags(1).Border(wx.TOP).Expand())
        self.throughput = wx.StaticBitmap(pnl, size=wx.Size(300, 300))
        throughput_sizer.Add(self.throughput, wx.SizerFlags(1).Border().Expand())
        self.throughput.SetScaleMode(wx.StaticBitmap.ScaleMode.Scale_AspectFit)

        latency_sizer = wx.StaticBoxSizer(wx.HORIZONTAL, pnl, 'Latency')
        right_sizer.Add(latency_sizer, wx.SizerFlags(1).Border(wx.TOP).Expand())
        self.latency = wx.StaticBitmap(pnl, size=wx.Size(300, 300))
        latency_sizer.Add(self.latency, wx.SizerFlags(1).Border().Expand())
        self.latency.SetScaleMode(wx.StaticBitmap.ScaleMode.Scale_AspectFit)

        self.CreateStatusBar()
        self.SetStatusText('Welcome to Router Tester!')

        self.SetSize(950, 950)

    def disable(self):
        wx.BeginBusyCursor()
        self.panel.Disable()

    def enable(self):
        wx.SafeYield(self)
        self.panel.Enable()
        wx.EndBusyCursor()

    def save(self):
        save_config(self.config)

    def go(self, func, enable_ui=True):
        def worker():
            func()
            if enable_ui:
                wx.CallAfter(self.enable)
        threading.Thread(target=worker).start()

    def _exec_cmd(self, script, *args):
        print('<<<<<<', ' '.join([script, *args]))
        with subprocess.Popen([DIR + '/' + script, *args]) as p:
            p.wait()

    def exec_cmd(self, script, *args):
        self.disable()
        def worker():
            self._exec_cmd(script, *args)
        self.go(worker)

    def read_cmd(self, script, *args):
        print('<<<<<<', ' '.join([script, *args]))
        with subprocess.Popen([DIR + '/' + script, *args], stdout=subprocess.PIPE) as p:
            out = p.stdout.read().decode()
        print(out)
        return out

    def log(self, testname, line):
        with open(f'{testname}.log', 'a') as f:
            if line[-1] != '\n':
                line += '\n'
            line = f'[{str(datetime.datetime.now())}] {line}'
            f.write(line)
        print(line, end='')

    def handle_bird_run(self, e):
        self.disable()
        def worker():
            self._exec_cmd('run-bird')
            def start_timer():
                self.bird_is_running = True
                self.bird_route_count_timer.Start(1000)
            wx.CallAfter(start_timer)
        self.go(worker)

    def handle_bird_kill(self, e):
        self.bird_is_running = False
        self.bird_route_count_timer.Stop()
        self.exec_cmd('kill-bird')

    def handle_network_config_apply(self, e):
        testname = self.test_name.GetLineText(0)
        if not testname:
            wx.MessageBox(f'Test Name should not be empty.', 'Error',
                          wx.OK | wx.ICON_ERROR)
            self.test_name.SetFocus()
            return
        testpath = RESULTS_DIR + '/' + testname
        self.my_ips_parsed = []
        self.dut_ips_parsed = []
        for i in range(NINTERFACES):
            try:
                self.my_ips_parsed.append(ipaddress.IPv6Address(self.my_ips[i].GetLineText(0)))
            except ipaddress.AddressValueError as err:
                wx.MessageBox(f'Failed to parse My IP{i + 1}: {str(err)}', 'Error',
                              wx.OK | wx.ICON_ERROR)
                self.my_ips[i].SetFocus()
                return
            try:
                self.dut_ips_parsed.append(ipaddress.IPv6Address(self.dut_ips[i].GetLineText(0)))
            except ipaddress.AddressValueError as err:
                wx.MessageBox(f'Failed to parse DUT IP{i + 1}: {str(err)}', 'Error',
                              wx.OK | wx.ICON_ERROR)
                self.dut_ips[i].SetFocus()
                return
        self.disable()
        self.config['test_name'] = testname
        self.config['my_ips'] = list(map(str, self.my_ips_parsed))
        self.config['dut_ips'] = list(map(str, self.dut_ips_parsed))
        self.save()
        self.log(testpath, 'Apply Network Configuration')
        for i in range(NINTERFACES):
            self.log(testpath, f'My IP{i + 1}: {self.my_ips_parsed[i]}')
            self.log(testpath, f'DUT IP{i + 1}: {self.dut_ips_parsed[i]}')
        def worker():
            for i in range(NINTERFACES):
                set_interface(i, ip_src=self.my_ips_parsed[i])
            for i in range(NINTERFACES):
                set_interface(i, gateway=self.dut_ips_parsed[i])
        self.go(worker)

    def handle_basic_test_test(self, e):
        if not self.my_ips_parsed:
            wx.MessageBox(f'Network Configuration is not applied.', 'Error',
                          wx.OK | wx.ICON_ERROR)
            self.network_config_apply.SetFocus()
            return
        testname = self.test_name.GetLineText(0)
        if not testname:
            wx.MessageBox(f'Test Name should not be empty.', 'Error',
                          wx.OK | wx.ICON_ERROR)
            self.test_name.SetFocus()
            return
        testpath = RESULTS_DIR + '/' + testname
        matrix = []
        for i in range(NINTERFACES):
            row = []
            for j in range(NINTERFACES):
                row.append(self.basic_test_check_matrix[i][j].IsChecked())
            matrix.append(row)
        self.disable()
        self.config['test_name'] = testname
        self.config['matrix'] = matrix
        self.save()
        def worker():
            self.log(testpath, 'Begin Basic Forwarding Test')
            for i in range(NINTERFACES):
                for j in range(NINTERFACES):
                    if matrix[i][j]:
                        self.log(testpath, f'IF{i + 1} ({self.my_ips_parsed[i]}) -> IF{j + 1} ({self.my_ips_parsed[j]})')
            for i in range(NINTERFACES):
                for j in range(NINTERFACES):
                    if matrix[i][j]:
                        set_interface(i, True, None, self.my_ips_parsed[j], 46 + 14, 0,
                                      use_var_ip_dst=False)
            test_all(testpath)
            for i in range(NINTERFACES):
                set_interface(i, False)
            self.log(testpath, 'End Basic Forwarding Test')
            with open(f'{testpath}.csv', 'r') as f:
                self.log(testpath, f.read())
            def update_plot():
                plot_test_all(testpath)
                self.throughput.SetBitmap(wx.BitmapBundle(wx.Bitmap(f'{testpath}-throughput.png')))
                self.latency.SetBitmap(wx.BitmapBundle(wx.Bitmap(f'{testpath}-latency.png')))
            wx.CallAfter(update_plot)
        self.go(worker)

    def handle_bird_route_count_timer(self, e):
        def worker():
            lines = self.read_cmd('count-bird').split('\n')
            if len(lines) < 2 * NINTERFACES + 1:
                return
            count_ifs = []
            for i in range(NINTERFACES):
                count_ifs.append(lines[2 * i + 1].strip().split(' ', 1)[1].strip())
            total = lines[2 * NINTERFACES].split(' ', 1)[1].strip()
            def update_text():
                for i in range(NINTERFACES):
                    self.bird_route_count_ifs[i].SetLabel(count_ifs[i])
                self.bird_route_count_total.SetLabel(total)
            wx.CallAfter(update_text)
        self.go(worker, enable_ui=False)

    def handle_fib_test_config(self, e):
        testname = self.test_name.GetLineText(0)
        if not testname:
            wx.MessageBox(f'Test Name should not be empty.', 'Error',
                          wx.OK | wx.ICON_ERROR)
            self.test_name.SetFocus()
            return
        testpath = RESULTS_DIR + '/' + testname
        try:
            skip = int(self.skip.GetLineText(0))
        except ValueError as err:
            wx.MessageBox(f'Failed to parse Skip: {str(err)}', 'Error',
                          wx.OK | wx.ICON_ERROR)
            self.skip.SetFocus()
            return
        if skip < 0:
            wx.MessageBox(f'Skip should be greater than or equal to zero.', 'Error',
                          wx.OK | wx.ICON_ERROR)
            self.skip.SetFocus()
            return
        try:
            count = int(self.count.GetLineText(0))
        except ValueError as err:
            wx.MessageBox(f'Failed to parse Count: {str(err)}', 'Error',
                          wx.OK | wx.ICON_ERROR)
            self.count.SetFocus()
            return
        if count < 0:
            wx.MessageBox(f'Count should be greater than or equal to zero.', 'Error',
                          wx.OK | wx.ICON_ERROR)
            self.count.SetFocus()
            return
        '''
        if not self.bird_is_running:
            wx.MessageBox(f'Bird should be running.', 'Error',
                          wx.OK | wx.ICON_ERROR)
            self.bird_run.SetFocus()
            return
        '''
        self.config['test_name'] = testname
        self.config['skip'] = skip
        self.config['count'] = count
        self.save()
        self.log(testpath, f'Configure {count} routes from {skip}')
        self.exec_cmd('configure-routes', str(skip), str(count))

    def handle_fib_test_download(self, e):
        testname = self.test_name.GetLineText(0)
        if not testname:
            wx.MessageBox(f'Test Name should not be empty.', 'Error',
                          wx.OK | wx.ICON_ERROR)
            self.test_name.SetFocus()
            return
        testpath = RESULTS_DIR + '/' + testname
        lfsr = self.fib_test_lfsr_check.IsChecked()
        self.disable()
        self.config['test_name'] = testname
        self.config['lfsr'] = lfsr
        self.save()
        def worker():
            self.log(testpath, f'Download the configured destination IP addresses to the tester')
            download_ip(lfsr)
        self.go(worker)

    def handle_fib_test_test(self, e):
        if not self.my_ips_parsed:
            wx.MessageBox(f'Network Configuration is not applied.', 'Error',
                          wx.OK | wx.ICON_ERROR)
            self.network_config_apply.SetFocus()
            return
        testname = self.test_name.GetLineText(0)
        if not testname:
            wx.MessageBox(f'Test Name should not be empty.', 'Error',
                          wx.OK | wx.ICON_ERROR)
            self.test_name.SetFocus()
            return
        testpath = RESULTS_DIR + '/' + testname
        strict = self.fib_test_strict_check.IsChecked()
        lfsr = self.fib_test_lfsr_check.IsChecked()
        self.disable()
        self.config['test_name'] = testname
        self.config['strict'] = strict
        self.config['lfsr'] = lfsr
        self.save()
        def worker():
            tags = 'Strict' if strict else 'Loose'
            if strict:
                tags += ', ' + ('LFSR' if lfsr else 'Counter')
            self.log(testpath, f'Begin Forwarding Table Capacity Test ({tags})')
            if strict:
                ratio = test_ip_strict(lfsr)
            else:
                ratio = test_ip(testpath)
            self.log(testpath, 'End Forwarding Table Capacity Test')
            self.log(testpath, f'Ratio = {ratio * 100}%')
            def update_text():
                self.fib_test_result.SetLabel(f'{ratio * 100}%')
            wx.CallAfter(update_text)
        self.go(worker)


if __name__ == '__main__':
    set_interface(0, False, mac='8C-1F-64-69-10-01')
    set_interface(1, False, mac='8C-1F-64-69-10-02')
    set_interface(2, False, mac='8C-1F-64-69-10-03')
    set_interface(3, False, mac='8C-1F-64-69-10-04')

    app = wx.App()
    frm = MainFrame(None, title='Router Tester')
    frm.Show()
    app.MainLoop()
