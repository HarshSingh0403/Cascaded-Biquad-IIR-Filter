# Cascaded-Biquad-IIR-Filter
# 📡 Design and Implementation of Cascaded IIR Biquad Filter (FPGA)

## 📌 Overview
This project focuses on the design and implementation of a **cascaded IIR (Infinite Impulse Response) biquad filter** using **Direct Form I architecture** in Verilog.

Two architectures are implemented and analyzed:
- Non-Pipelined Architecture
- Pipelined Architecture

The project evaluates trade-offs between **latency, throughput, hardware utilization, and timing performance**, making it suitable for FPGA and DSP applications.

---

## 🧠 Key Concepts

- IIR Digital Filters  
- Biquad (Second-Order) Sections  
- Cascaded Filter Design (6th Order)  
- Direct Form I Structure  
- RTL Design using Verilog  
- Pipelining for Performance Optimization  

### 🔢 Filter Equation

---

## 🏗️ Architecture

### 🔹 Non-Pipelined Design
- Each biquad section computes output in **one clock cycle**
- 3 cascaded sections → **6th order filter**
- Total latency: **3 clock cycles**
- Simpler design with fewer registers
- Long critical path → lower maximum clock frequency

---

### 🔹 Pipelined Design
- Registers inserted:
  - After multipliers (inside biquad)
  - Between cascaded stages
- Breaks long combinational paths
- Improves timing performance

- Total latency: **8 clock cycles**
- Higher achievable clock frequency (Fmax)
- Increased hardware utilization

---

## ⚖️ Comparison

| Feature        | Non-Pipelined        | Pipelined              |
|---------------|---------------------|------------------------|
| Latency       | 3 cycles            | 8 cycles               |
| Throughput    | 1 sample / clock    | 1 sample / 2 clocks    |
| Fmax          | Lower               | Higher                 |
| Complexity    | Low                 | High                   |
| Registers     | Fewer               | More                   |

---

## 📁 Project Structure

---

## ⚙️ Implementation Details

- Language: **Verilog HDL**
- Data Width: **16-bit signed**
- Filter Type: **IIR Cascaded Biquad**
- Architecture: **Direct Form I**
- Arithmetic: Fixed-point

### Scaling
Output is scaled using: acc[29:14]


---

## 📊 Results

### 🔹 Non-Pipelined
- Area: ~27,350  
- Cells: 642  
- Timing: Setup violation observed  

### 🔹 Pipelined
- Area: ~30,240  
- Cells: 812  
- Timing: Meets setup constraints  

---

## 🎯 Key Takeaways

- Non-pipelined design:
  - Lower latency
  - Simpler and resource-efficient

- Pipelined design:
  - Higher clock frequency
  - Better timing closure
  - Increased latency and hardware usage

---

## 🚀 Applications

- Digital Signal Processing (DSP)
- Audio signal filtering
- Communication systems
- FPGA-based real-time processing

---

## 👨‍💻 Authors

- Garvit Maheshwari  
- Adish Vipin  
- Tanmay Sharma  
- Harsh Vardhan Singh  

---

## 📜 License
This project is for academic and educational purposes only.
