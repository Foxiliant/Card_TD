# Agent Development Log: Card Castle Defense

## Session: Oct 27, 2026

### 🛠 Structural Changes
- **Project Path**: Moved project root to `C:\Users\06775\OneDrive\Документы\ai-test\Card_TD`.
- **Project Config**: Restored `project.godot` with correct version (4.7), Forward Plus renderer, and Jolt Physics.
- **Folder Structure**: Created `scripts/data`, `scripts/castle`, `scripts/battle`, `scripts/ui`, `scenes`, `data/cards`, `data/enemies`, `tests`.

### 📦 Implemented Components
- **GameConfig**: Implemented as a `RefCounted` class with `OVERLOAD_HP_FACTOR`.
- **Data Models**: Created `CardData`, `CardEffect`, and `EnemyData` as Resources.
- **Castle Core**:
    - `Block`: Handles position, rotation, and footprint.
    - `CastleGrid`: Manages block placement and basic occupancy checks.
    - `LoadSolver`: Implements load calculation from top to bottom with proportional weight distribution based on overlap.

### 🧪 Test Results (Run-tests.gd)
**Status: Partial Success (2/4)**

| Test | Description | Result | Note |
|---|---|---|---|
| 1 | Overload | ✅ PASSED | Load and HP reduction work correctly. |
| 2 | Recovery | ❌ FAIL | Load becomes 0.0 after removing mid-block. Need to implement `CollapseResolver` (Gravity). |
| 3 | Weight Dist. | ❌ FAIL | Distribution not proportional (S1=1.5, S2=0.0). Need to fix overlap logic in `LoadSolver`. |
| 4 | Capacity Bonus| ✅ PASSED | Passive bonuses from blocks above are applied. |

### 🚩 Known Issues & Next Steps
1. **LoadSolver**: Fix weight distribution logic for multi-cell blocks (Planks).
2. **CollapseResolver**: Implement the destruction loop and gravity (as per SPEC section 7).
3. **Tests**: Fix Test 2 and Test 3.
4. **Build Phase**: Start implementing `BuildController` and visual grid.
