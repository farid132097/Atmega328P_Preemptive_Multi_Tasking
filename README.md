<h2>AVR RTOS Kernel</h2>
A lightweight real-time operating system (RTOS) written in AVR assembly, designed for the ATmega328P and similar 8-bit AVR microcontrollers.
This kernel is built from scratch with deterministic context switching, task scheduling, and sleep management, making it suitable for low-power, time-critical embedded applications.
</br>
</br>
<h2>Key features</h2>
-Preemptive scheduling with priority-based task management</br>
-Context switching implemented in pure AVR assembly</br>
-Kernel tick driven by hardware timer interrupts</br>
-Task sleep & wakeup with constant latency support</br>
-Low memory footprint, optimized for 8-bit MCUs</br>
-Extensible for semaphores, queues, and synchronization primitives</br>
</br>
</br>
<h2>Target Platform</h2>
MCU: ATmega328P (Arduino Uno and compatible boards)</br>
Clock: 8 MHz / 16 MHz (configurable)</br>
Toolchain: AVR-GCC + avr-libc + Makefile</br>
