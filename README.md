<h1>
  <img src="./logo.png" alt="Logo" width="55">
  SID Laboratory 1: Agents in Capture the Flag
</h1>


## Description
This project is part of the university subject  *Sistemes Intel·ligents Distribuïts* (SID), focused on building intelligent agents to compete in a **Capture The Flag** game using the `pyGOMAS` simulation platform.
+ Agents are developed using AgentSpeak and run on the SPADE platform.
+ They follow a Belief-Desire-Intention (BDI) model to reason and act logically.

### Game Enviroment
In [pyGOMAS](https://github.com/javipalanca/pygomas) the classic Capture the Flag game takes place in a World War II setting, where two opposing factions—the Allies and the Axis—compete for control of a single flag.

+ The **attacking team** must infiltrate enemy lines and capture the flag before the timer runs out.
+ The **defending  team** must prevent the attackers from succeeding.

### Agents
The three available roles are:

- **FieldOps 🎖**: Supplies **ammunition pack** to keep allies equipped.
- **Soldier 🪖**: Specializes in combat, dealing **double damage** with weapons.
- **Medic 🏥**: Creates **healing packs** that restore health to teammates.

## Implementation Details

> **Agent Rationality**
> Our agents implement the BDI model to make autonomous decisions optimizing their impact on team objectives while maximizing individual utility. **The agents operate without explicit coordination, making them effective even when paired with agents from other implementations.**

### Project Structure
```bash
.
├── README.md
├── cool-agents/
│   ├── bdifieldop.asl      # Field Operator agent implementation
│   ├── bdimedic.asl        # Medic agent implementation
│   ├── bdimedic_extra.asl  # Extra agent: Medic 
│   ├── bdisoldier.asl      # Soldier agent implementation
│   └── ejemplo.json        # Configuration file for team setup
├── exec-scripts/
│   ├── run-pygomas-Linux.sh     # Execution script for Linux
│   ├── run-pygomas-Windows.bat  # Execution script for Windows
│   └── run-pygomas-macOS.sh     # Execution script for macOS
└── REPORT.pdf              # Detailed project documentation
```

## Setup & Execution

#### Prerequisites
- Python 3.9
-  **Note**: Edit `cool-agents/ejemplo.json` and the `/exec-scripts` to configure your team:
   + Update *host*, *manager*, and *service fields* with appropriate values
   + Adjust agent composition in axis and allied arrays as needed
   + Ensure paths to `.asl` files are correct

### Quick Start
1. **Setup environment**:
```bash
  pip install virtualenv
  python -m venv venv
  
  # Activate (run each new terminal session)
  source venv/bin/activate  # macOS/Linux
  venv\Scripts\activate     # Windows
  
  pip install -r requirements.txt
```
2. **Configure and run**:

  + Edit cool-agents/ejemplo.json with your team configuration
  + Execute the appropriate script with you PC configuration:
  
  ```bash
  ./exec-scripts/run-pygomas-macOS.sh    # macOS
  ./exec-scripts/run-pygomas-Linux.sh    # Linux
  exec-scripts\run-pygomas-Windows.bat   # Windows
  ```
> The script will: 
> + Start the PyGOMAS Manager in a new terminal
> + Launch the PyGOMAS Renderer in a second terminal
> + Start the agent simulation in a third terminal
> + Create `pygomas_stats.txt` with simulation results




## Contributors
- Òscar Molina
- Llum Fuster-Palà
- Javier Puerta
- Júlia Orteu
