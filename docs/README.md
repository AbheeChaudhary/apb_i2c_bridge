## Microarchitecture: FSM Design

The core control logic of the APB-to-I2C bridge is driven by a 5-state Finite State Machine (FSM). The FSM handles clock domain pacing and protocol translation, ensuring that high-speed parallel APB transactions are safely serialized into the I2C protocol.

### FSM State Definitions & Logic

| State | Description | Outputs & Bus Control | Next State Condition |
| :--- | :--- | :--- | :--- |
| **`IDLE`** | Default state. Bridge is passive. | `pready = 1` (Bus free). `SCL = 1`, `SDA = 1`. | Transitions to `START` when APB asserts `psel` && `penable`. |
| **`START`** | Generates the I2C Start Condition. | `pready = 0` (Stalls APB). Pulls `SDA` Low while `SCL` is High. | Unconditional transition to `DATA_SHIFT` on the next I2C clock tick. |
| **`DATA_SHIFT`** | Serializes the 8-bit APB `pwdata`. | `pready = 0`. Toggles `SCL`. Shifts data onto `SDA` on SCL Low. | Transitions to `ACK_PHASE` when 8-bit counter reaches 0. |
| **`ACK_PHASE`** | Listens for Slave Acknowledgment. | `pready = 0`. Releases `SDA` (High-Z) to allow Slave to pull low. | Unconditional transition to `STOP` (for single-byte transfers). |
| **`STOP`** | Generates the I2C Stop Condition. | `pready = 1` (Unstalls APB). Pulls `SDA` High while `SCL` is High. | Unconditional transition to `IDLE`. |

### Design Considerations for Silicon
* **Wait-State Insertion:** The `pready` signal is dynamically controlled by the FSM. It is immediately de-asserted upon leaving `IDLE` to prevent the RISC-V core from overwriting the APB data registers while the slow I2C transmission is in progress.
* **Glitch-Free Outputs:** State transitions are strictly synchronized to the system `pclk`, but I2C wire toggling is guarded by a clock-divider enable tick to ensure setup/hold times for the I2C specification are met.

### Simulation Results
![GTKWave Simulation showing APB wait-states and I2C serialization](apb-i2c-waveform-A5-input.png)
*Waveform demonstrating successful wait-state insertion (`pready` logic) during the parallel-to-serial protocol translation of payload 0xA5.*
