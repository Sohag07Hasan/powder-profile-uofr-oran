#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: Multi UE Flowgraph
# GNU Radio version: 3.10.9.2

from PyQt5 import Qt
from gnuradio import qtgui
from PyQt5 import QtCore
from gnuradio import blocks
from gnuradio import gr
from gnuradio.filter import firdes
from gnuradio.fft import window
import sys
import signal
from PyQt5 import Qt
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
from gnuradio import zeromq



class twoGNBfourUE(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "Multi UE Flowgraph", catch_exceptions=True)
        Qt.QWidget.__init__(self)
        self.setWindowTitle("Multi UE Flowgraph")
        qtgui.util.check_set_qss()
        try:
            self.setWindowIcon(Qt.QIcon.fromTheme('gnuradio-grc'))
        except BaseException as exc:
            print(f"Qt GUI: Could not set Icon: {str(exc)}", file=sys.stderr)
        self.top_scroll_layout = Qt.QVBoxLayout()
        self.setLayout(self.top_scroll_layout)
        self.top_scroll = Qt.QScrollArea()
        self.top_scroll.setFrameStyle(Qt.QFrame.NoFrame)
        self.top_scroll_layout.addWidget(self.top_scroll)
        self.top_scroll.setWidgetResizable(True)
        self.top_widget = Qt.QWidget()
        self.top_scroll.setWidget(self.top_widget)
        self.top_layout = Qt.QVBoxLayout(self.top_widget)
        self.top_grid_layout = Qt.QGridLayout()
        self.top_layout.addLayout(self.top_grid_layout)

        self.settings = Qt.QSettings("GNU Radio", "twoGNBfourUE")

        try:
            geometry = self.settings.value("geometry")
            if geometry:
                self.restoreGeometry(geometry)
        except BaseException as exc:
            print(f"Qt GUI: Could not restore geometry: {str(exc)}", file=sys.stderr)

        ##################################################
        # Variables
        ##################################################
        self.samp_rate = samp_rate = 1.92e6
        self.min_gain = min_gain = 0
        self.max_gain = max_gain = 1
        self.cell_gain3 = cell_gain3 = 0.080
        self.cell_gain2 = cell_gain2 = 0.050
        self.cell_gain1 = cell_gain1 = 0.080
        self.cell_gain0 = cell_gain0 = 0.050

        ##################################################
        # Blocks
        ##################################################

        self._cell_gain3_range = qtgui.Range(min_gain, max_gain, 0.0001, 0.080, 200)
        self._cell_gain3_win = qtgui.RangeWidget(self._cell_gain3_range, self.set_cell_gain3, "'cell_gain3'", "counter_slider", float, QtCore.Qt.Horizontal)
        self.top_layout.addWidget(self._cell_gain3_win)
        self._cell_gain2_range = qtgui.Range(min_gain, max_gain, 0.0001, 0.050, 200)
        self._cell_gain2_win = qtgui.RangeWidget(self._cell_gain2_range, self.set_cell_gain2, "'cell_gain2'", "counter_slider", float, QtCore.Qt.Horizontal)
        self.top_layout.addWidget(self._cell_gain2_win)
        self._cell_gain1_range = qtgui.Range(min_gain, max_gain, 0.0001, 0.080, 200)
        self._cell_gain1_win = qtgui.RangeWidget(self._cell_gain1_range, self.set_cell_gain1, "'cell_gain1'", "counter_slider", float, QtCore.Qt.Horizontal)
        self.top_layout.addWidget(self._cell_gain1_win)
        self._cell_gain0_range = qtgui.Range(min_gain, max_gain, 0.0001, 0.050, 200)
        self._cell_gain0_win = qtgui.RangeWidget(self._cell_gain0_range, self.set_cell_gain0, "'cell_gain0'", "counter_slider", float, QtCore.Qt.Horizontal)
        self.top_layout.addWidget(self._cell_gain0_win)
        self.zeromq_req_source_1_0 = zeromq.req_source(gr.sizeof_gr_complex, 1, 'tcp://localhost:3000', 100, False, (-1), False)
        self.zeromq_req_source_1 = zeromq.req_source(gr.sizeof_gr_complex, 1, 'tcp://localhost:2000', 100, False, (-1), False)
        self.zeromq_req_source_0_1 = zeromq.req_source(gr.sizeof_gr_complex, 1, 'tcp://localhost:3010', 100, False, (-1), False)
        self.zeromq_req_source_0_0_0 = zeromq.req_source(gr.sizeof_gr_complex, 1, 'tcp://localhost:3007', 100, False, (-1), False)
        self.zeromq_req_source_0_0 = zeromq.req_source(gr.sizeof_gr_complex, 1, 'tcp://localhost:2007', 100, False, (-1), False)
        self.zeromq_req_source_0 = zeromq.req_source(gr.sizeof_gr_complex, 1, 'tcp://localhost:2010', 100, False, (-1), False)
        self.zeromq_rep_sink_1_1 = zeromq.rep_sink(gr.sizeof_gr_complex, 1, 'tcp://*:3008', 100, False, (-1), True)
        self.zeromq_rep_sink_1_0_0 = zeromq.rep_sink(gr.sizeof_gr_complex, 1, 'tcp://*:3006', 100, False, (-1), True)
        self.zeromq_rep_sink_1_0 = zeromq.rep_sink(gr.sizeof_gr_complex, 1, 'tcp://*:2006', 100, False, (-1), True)
        self.zeromq_rep_sink_1 = zeromq.rep_sink(gr.sizeof_gr_complex, 1, 'tcp://*:2008', 100, False, (-1), True)
        self.zeromq_rep_sink_0_0 = zeromq.rep_sink(gr.sizeof_gr_complex, 1, 'tcp://*:3009', 100, False, (-1), True)
        self.zeromq_rep_sink_0 = zeromq.rep_sink(gr.sizeof_gr_complex, 1, 'tcp://*:2009', 100, False, (-1), True)
        self.blocks_throttle2_1_0 = blocks.throttle( gr.sizeof_gr_complex*1, samp_rate, True, 0 if "auto" == "auto" else max( int(float(0.1) * samp_rate) if "auto" == "time" else int(0.1), 1) )
        self.blocks_throttle2_1 = blocks.throttle( gr.sizeof_gr_complex*1, samp_rate, True, 0 if "auto" == "auto" else max( int(float(0.1) * samp_rate) if "auto" == "time" else int(0.1), 1) )
        self.blocks_throttle2_0_0 = blocks.throttle( gr.sizeof_gr_complex*1, samp_rate, True, 0 if "auto" == "auto" else max( int(float(0.1) * samp_rate) if "auto" == "time" else int(0.1), 1) )
        self.blocks_throttle2_0 = blocks.throttle( gr.sizeof_gr_complex*1, samp_rate, True, 0 if "auto" == "auto" else max( int(float(0.1) * samp_rate) if "auto" == "time" else int(0.1), 1) )
        self.blocks_multiply_const_vxx_0_2 = blocks.multiply_const_cc(cell_gain2)
        self.blocks_multiply_const_vxx_0_1_0 = blocks.multiply_const_cc(cell_gain2)
        self.blocks_multiply_const_vxx_0_1 = blocks.multiply_const_cc(cell_gain0)
        self.blocks_multiply_const_vxx_0_0_1 = blocks.multiply_const_cc(cell_gain3)
        self.blocks_multiply_const_vxx_0_0_0_0 = blocks.multiply_const_cc(cell_gain3)
        self.blocks_multiply_const_vxx_0_0_0 = blocks.multiply_const_cc(cell_gain1)
        self.blocks_multiply_const_vxx_0_0 = blocks.multiply_const_cc(cell_gain1)
        self.blocks_multiply_const_vxx_0 = blocks.multiply_const_cc(cell_gain0)
        self.blocks_add_xx_0_0 = blocks.add_vcc(1)
        self.blocks_add_xx_0 = blocks.add_vcc(1)


        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_add_xx_0, 0), (self.blocks_throttle2_0, 0))
        self.connect((self.blocks_add_xx_0_0, 0), (self.blocks_throttle2_0_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0, 0), (self.blocks_add_xx_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0_0, 0), (self.blocks_add_xx_0, 1))
        self.connect((self.blocks_multiply_const_vxx_0_0_0, 0), (self.zeromq_rep_sink_1_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0_0_0_0, 0), (self.zeromq_rep_sink_1_0_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0_0_1, 0), (self.blocks_add_xx_0_0, 1))
        self.connect((self.blocks_multiply_const_vxx_0_1, 0), (self.zeromq_rep_sink_1, 0))
        self.connect((self.blocks_multiply_const_vxx_0_1_0, 0), (self.zeromq_rep_sink_1_1, 0))
        self.connect((self.blocks_multiply_const_vxx_0_2, 0), (self.blocks_add_xx_0_0, 0))
        self.connect((self.blocks_throttle2_0, 0), (self.zeromq_rep_sink_0, 0))
        self.connect((self.blocks_throttle2_0_0, 0), (self.zeromq_rep_sink_0_0, 0))
        self.connect((self.blocks_throttle2_1, 0), (self.blocks_multiply_const_vxx_0_0_0, 0))
        self.connect((self.blocks_throttle2_1, 0), (self.blocks_multiply_const_vxx_0_1, 0))
        self.connect((self.blocks_throttle2_1_0, 0), (self.blocks_multiply_const_vxx_0_0_0_0, 0))
        self.connect((self.blocks_throttle2_1_0, 0), (self.blocks_multiply_const_vxx_0_1_0, 0))
        self.connect((self.zeromq_req_source_0, 0), (self.blocks_multiply_const_vxx_0, 0))
        self.connect((self.zeromq_req_source_0_0, 0), (self.blocks_multiply_const_vxx_0_0, 0))
        self.connect((self.zeromq_req_source_0_0_0, 0), (self.blocks_multiply_const_vxx_0_0_1, 0))
        self.connect((self.zeromq_req_source_0_1, 0), (self.blocks_multiply_const_vxx_0_2, 0))
        self.connect((self.zeromq_req_source_1, 0), (self.blocks_throttle2_1, 0))
        self.connect((self.zeromq_req_source_1_0, 0), (self.blocks_throttle2_1_0, 0))


    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "twoGNBfourUE")
        self.settings.setValue("geometry", self.saveGeometry())
        self.stop()
        self.wait()

        event.accept()

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.blocks_throttle2_0.set_sample_rate(self.samp_rate)
        self.blocks_throttle2_0_0.set_sample_rate(self.samp_rate)
        self.blocks_throttle2_1.set_sample_rate(self.samp_rate)
        self.blocks_throttle2_1_0.set_sample_rate(self.samp_rate)

    def get_min_gain(self):
        return self.min_gain

    def set_min_gain(self, min_gain):
        self.min_gain = min_gain

    def get_max_gain(self):
        return self.max_gain

    def set_max_gain(self, max_gain):
        self.max_gain = max_gain

    def get_cell_gain3(self):
        return self.cell_gain3

    def set_cell_gain3(self, cell_gain3):
        self.cell_gain3 = cell_gain3
        self.blocks_multiply_const_vxx_0_0_0_0.set_k(self.cell_gain3)
        self.blocks_multiply_const_vxx_0_0_1.set_k(self.cell_gain3)

    def get_cell_gain2(self):
        return self.cell_gain2

    def set_cell_gain2(self, cell_gain2):
        self.cell_gain2 = cell_gain2
        self.blocks_multiply_const_vxx_0_1_0.set_k(self.cell_gain2)
        self.blocks_multiply_const_vxx_0_2.set_k(self.cell_gain2)

    def get_cell_gain1(self):
        return self.cell_gain1

    def set_cell_gain1(self, cell_gain1):
        self.cell_gain1 = cell_gain1
        self.blocks_multiply_const_vxx_0_0.set_k(self.cell_gain1)
        self.blocks_multiply_const_vxx_0_0_0.set_k(self.cell_gain1)

    def get_cell_gain0(self):
        return self.cell_gain0

    def set_cell_gain0(self, cell_gain0):
        self.cell_gain0 = cell_gain0
        self.blocks_multiply_const_vxx_0.set_k(self.cell_gain0)
        self.blocks_multiply_const_vxx_0_1.set_k(self.cell_gain0)




def main(top_block_cls=twoGNBfourUE, options=None):

    qapp = Qt.QApplication(sys.argv)

    tb = top_block_cls()

    tb.start()

    tb.show()

    def sig_handler(sig=None, frame=None):
        tb.stop()
        tb.wait()

        Qt.QApplication.quit()

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    timer = Qt.QTimer()
    timer.start(500)
    timer.timeout.connect(lambda: None)

    qapp.exec_()

if __name__ == '__main__':
    main()
