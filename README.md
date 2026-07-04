# UART(Universal Asynchronous Receiver/Transmitter)
**UART (Universal Asynchronous Receiver/Transmitter)** is one of the most widely used **asynchronous serial communication protocols** for exchanging data between two digital devices. Unlike synchronous communication protocols, UART does **not require a common clock signal** between the transmitter and receiver. Instead, both devices communicate using a predefined **baud rate**, allowing them to remain synchronized during data transmission.

UART uses two dedicated communication lines:
- **TX (Transmit):** Transfers serial data from the transmitter.
- **RX (Receive):** Receives serial data at the receiver.

During communication, an 8-bit parallel data word is converted into a serial bit stream by the transmitter. Each data frame begins with a **Start Bit**, followed by the **data bits** (typically transmitted LSB first), and ends with one or more **Stop Bits**. The receiver detects the start bit, samples the incoming serial data according to the configured baud rate, reconstructs the original data, and verifies the completion of the frame.

Due to its **simple hardware implementation, low cost, and reliable point-to-point communication**, UART is extensively used in **microcontrollers, embedded systems, GPS modules, Bluetooth modules, Wi-Fi modules, Arduino, Raspberry Pi, and computer serial interfaces**.
# System Architecture

The UART communication system is designed using a modular architecture comprising three primary modules: **UART Transmitter**, **UART Receiver**, and a **Top-Level Integration Module**. The transmitter and receiver operate independently while sharing a common system clock and reset signal. The top-level module integrates both submodules, enabling simultaneous transmission and reception through dedicated **TX** and **RX** communication lines.

The **UART Transmitter** accepts 8-bit parallel input data along with a transmission request signal (`newd`). It serializes the input data into a UART-compliant frame consisting of a **Start Bit**, **Data Bits**, and a **Stop Bit**, and asserts the `donetx` signal upon successful transmission.

The **UART Receiver** continuously monitors the serial input (`rx`) for a valid start bit. Once detected, it samples the incoming serial data based on the configured baud rate, reconstructs the original 8-bit parallel data, and asserts the `donerx` signal after successful reception.

The overall architecture follows a modular and scalable RTL design methodology, allowing the transmitter and receiver to be independently developed, verified, and integrated into the complete UART communication system.

<p align="center">
  <img src="IMAGES/UART Top-Level Block Diagram.png" width="900">
</p>

<p align="center">
<b>Figure 1.</b>Figure 1. UART Top-Level Block Diagram
</p>

# UART Frame Format

UART transmits data in the form of **frames**, where each frame contains the information required for reliable asynchronous communication between the transmitter and receiver. Since UART does not use a shared clock signal, synchronization is achieved using **Start** and **Stop** bits, while both devices operate at the same configured **baud rate**.

A standard **8-bit UART frame** consists of the following fields:

- **Idle State (Logic 1):** The communication line remains HIGH when no data is being transmitted.
- **Start Bit (Logic 0):** Indicates the beginning of a new data frame and synchronizes the receiver.
- **Data Bits (8 Bits):** The actual information is transmitted serially, beginning with the **Least Significant Bit (LSB)** and ending with the **Most Significant Bit (MSB)**.
- **Stop Bit (Logic 1):** Marks the end of the data frame and returns the communication line to the idle state.

The receiver detects the **Start Bit**, samples each incoming data bit according to the configured baud rate, reconstructs the original 8-bit parallel data, and verifies the **Stop Bit** to ensure successful frame reception.

<p align="center">
  <img src="IMAGES/UART Frame Format.png" width="900">
</p>

<p align="center">
<b>Figure 2.</b> Standard UART Frame Format for 8-Bit Asynchronous Serial Communication
</p>

# UART Transmitter

The UART Transmitter is responsible for converting 8-bit parallel input data into a serial bit stream that complies with the UART communication protocol. Upon receiving a valid transmission request (`newd`), the transmitter generates a UART frame consisting of a **Start Bit**, **8 Data Bits** (transmitted LSB first), and a **Stop Bit**. The transmission process is synchronized using the configured baud rate, and the `donetx` signal is asserted after the complete frame has been successfully transmitted.

The transmitter is implemented using a **Finite State Machine (FSM)** comprising four states: **IDLE**, **START**, **TRANSFER**, and **DONE**. Each state performs a specific operation to ensure reliable and sequential transmission of serial data.

## Finite State Machine (FSM)

<p align="center">
  <img src="IMAGES/TRANSMITTER FSM.png" width="500">
</p>

<p align="center">
<b>Figure 3.</b> Finite State Machine of the UART Transmitter
</p>

## State Description

| State | Description |
|--------|-------------|
| **IDLE** | Waits for a valid transmission request (`newd`). The TX line remains in the logic HIGH (idle) state. |
| **START** | Generates the Start Bit (logic LOW) to indicate the beginning of a new UART frame. |
| **TRANSFER** | Serially transmits the 8-bit input data, beginning with the Least Significant Bit (LSB). |
| **DONE** | Generates the Stop Bit (logic HIGH), asserts the `donetx` signal, and returns to the IDLE state. |

## Functional Simulation
The transmitter waveform demonstrates the complete UART transmission process. Initially, the **TX** line remains in the **Idle (Logic HIGH)** state. When the **`newd`** signal is asserted, the transmitter generates a **Start Bit (Logic LOW)**, followed by the serial transmission of the **8-bit input data (`dintx`)**, beginning with the **Least Significant Bit (LSB)**. After all data bits have been transmitted, a **Stop Bit (Logic HIGH)** is generated, and the **`donetx`** signal is asserted to indicate the successful completion of transmission.

For functional verification, the transmitted serial data is reconstructed as **`tx_data`** within the testbench. When **`donetx`** becomes HIGH, **`tx_data`** is compared with the original input **`dintx`**. The waveform confirms that **`tx_data == dintx`**, demonstrating that the transmitter correctly serializes the input data without any loss or corruption.

<p align="center">
  <img src="SIMULATION WAVEFORM/TRANSMITTER WAVEFORM.png" width="1000">
</p>

<p align="center">
<b>Figure 4.</b> Functional Simulation of the UART Transmitter showing successful transmission and verification of transmitted data.
</p>

# UART Receiver

The UART Receiver is responsible for converting the incoming serial data stream into its original 8-bit parallel format. It continuously monitors the **RX** line for a valid **Start Bit**. Once a start bit is detected, the receiver samples the incoming serial data at the configured baud rate, reconstructs the transmitted byte, and verifies the **Stop Bit** to ensure successful frame reception. Upon receiving the complete data frame, the `donerx` signal is asserted, indicating that the received data is available at the output.

Similar to the transmitter, the receiver is implemented using a **Finite State Machine (FSM)** to control the reception process and ensure accurate synchronization with the incoming serial data.

## Finite State Machine (FSM)

<p align="center">
  <img src="IMAGES/RECEIVER FSM.png" width="500">
</p>

<p align="center">
<b>Figure 5.</b> Finite State Machine of the UART Receiver
</p>

## State Description

| State | Description |
|--------|-------------|
| **IDLE** | Waits for the detection of a valid **Start Bit (Logic LOW)** on the `rx` line. During this state, the receiver remains idle, clears the bit counter, and deasserts the `done` signal. Upon detecting the start bit, it transitions to the **START** state to begin data reception. |
| **START** | Receives the incoming **8-bit serial data** by sampling each bit at the configured baud rate and shifting it into the receive register in **LSB-first** order. After all eight bits have been received, the receiver asserts the `done` signal to indicate successful reception and returns to the **IDLE** state, ready for the next data frame. |

## Functional Simulation

The receiver waveform demonstrates the complete UART reception process. Initially, the **RX** line remains in the **Idle (Logic HIGH)** state. When a **Start Bit (Logic LOW)** is detected, the receiver begins sampling the incoming serial data according to the configured baud rate. The received bits are sequentially shifted into the receive register to reconstruct the original **8-bit parallel data**.

For functional verification, the serial input data is simultaneously stored as **`rx_data`** within the testbench. Upon successful reception of all eight data bits, the **`donerx`** signal is asserted, indicating the completion of the reception process. At this instant, the receiver output **`doutrx`** is compared with the reference **`rx_data`** generated by the testbench. The waveform confirms that **`doutrx == rx_data`** when **`donerx`** becomes HIGH, demonstrating the correct reconstruction and reception of the transmitted data.

<p align="center">
  <img src="SIMULATION WAVEFORM/RECEIVER WAVEFORM-1.png" width="1000">
</p>

<p align="center">
<b>Figure 6.</b> UART Receiver – Serial Data Reception
</p>

<p align="center">
  <img src="SIMULATION WAVEFORM/RECEIVER WAVEFORM-2.png" width="1000">
</p>

<p align="center">
<b>Figure 7.</b> UART Receiver – Successful Data Reconstruction and Verification (`doutrx == rx_data`)
</p>

# Tools Used

The following tools and software were used for the design, simulation, verification, and documentation of this project:

| Tool | Purpose |
|------|---------|
| **Verilog HDL** | RTL Design and Hardware Description |
| **Xilinx Vivado** | Design Entry, Simulation, and Functional Verification |
| **Vivado Simulator (XSIM)** | Waveform Analysis and Debugging |
| **Git & GitHub** | Version Control and Project Documentation |
| **draw.io (diagrams.net)** | Block Diagrams and FSM Design |

---

# Conclusion

This project successfully demonstrates the RTL implementation of a **UART (Universal Asynchronous Receiver/Transmitter)** communication system using **Verilog HDL**. The design incorporates modular **transmitter** and **receiver** architectures with **FSM-based control logic** to achieve reliable asynchronous serial communication. Functional verification using a **self-checking testbench** confirms the correct transmission and reception of 8-bit data, validating the accuracy of the implemented UART protocol. This project provides a strong foundation for understanding serial communication protocols and digital system design in FPGA and ASIC development.
