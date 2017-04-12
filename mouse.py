import struct
import sys
import time
from threading import Thread, Lock
from optparse import OptionParser

lock = Lock()

delay = 1.0

state = (False, 0, 0)

(x1, y1) = (0, 0)
(x2, y2) = (0, 0)
(x3, y3) = (0, 0)

accel = (0, 0)

def readStdInput():
    return sys.stdin.buffer.read(3)

def parseMouseEvent(buf):
    leftClicked = buf[0] & 0x1
    dx, dy = struct.unpack("bb", buf[1:])
    return leftClicked, dx, dy

def calculateAcceleration():
    global delay, x1, y1, x2, y2, x3, y3
    return ((x1 - 2 * x2 + x3) / (delay ** 2),
        (y1 - 2 * y2 + y3) / (delay ** 2))

def clearState():
    global state
    state = False, state[1], state[2]

def updateState(leftClicked, dx, dy):
    global state
    state = state[0] | leftClicked, state[1] + dx, state[2] + dy

def updateStored():
    global dt, x1, y1, x2, y2, x3, y3
    x2, y2 = x1, y1
    x3, y3 = x2, y2
    x1, y1 = state[1], state[2]

class Parser(Thread):
    def run(self):
        while True:
            buf = readStdInput()
            lock.acquire()
            updateState(*parseMouseEvent(buf))
            lock.release()

class Calculator(Thread):
    def run(self):
        global accel
        while True:
            lock.acquire()
            updateStored()
            accel = calculateAcceleration()
            lock.release()
            time.sleep(delay)

class Printer(Thread):
    def run(self):
        while True:
            print("%0.6f %0.6f %0.6f %0.6f %0.6f %0.6f"
                % (time.time(), *state, *accel))
            sys.stdout.flush()
            lock.acquire()
            clearState()
            lock.release()
            time.sleep(delay)

if __name__ == "__main__":
    helpText = """
    Redirect the contents of /dev/input/mice into standard input of this python
    script, and it computes a timestamp, absolute X position, absolute Y
    position, X acceleration, and Y acceleration of the mouse at a constant
    sampling rate.

    Licensed under GNU GPL.

    Written by Siddharth Trehan, 2017.

    Usage: python mouse.py [options]"""
    cmdParser = OptionParser(usage=helpText)
    cmdParser.add_option("-t", "--sampling-time", type="float", dest="time",
        help="Time between mouse event samples (default=0.05)", default=0.05)
    options, args = cmdParser.parse_args()
    delay = options.time

    parser = Parser()
    calculator = Calculator()
    printer = Printer()
    parser.start()
    calculator.start()
    printer.start()
