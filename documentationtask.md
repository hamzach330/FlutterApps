


Analyze the provided Flutter codebase structure (including file paths, directory names, and comments within key files) and generate a concise, structured documentation summary for each distinct module (app or package).

Constraints & Guidelines:

Module Identification: A "module" is defined as a top-level directory within the monorepo structure that represents a complete application (e.g., apps/consumer_app, apps/admin_panel) or a reusable package (e.g., packages/data_models, packages/ui_components).

Length: Each module summary should be no more than 5-7 sentences long.

Output Format: Use Markdown and follow the specific structure provided below.

Prompt Template:

Analyze the following Flutter monorepository structure, focusing on the contents of the `apps/` and `packages/` directories. For each identified module (app or package), generate a summary following the specified format.

---

### **[MODULE NAME]**

| Field | Description |
| :--- | :--- |
| **Module Path** | [e.g., `apps/consumer_app` or `packages/shared_utils`] |
| **Type** | [App or Package/Library] |
| **Purpose/Goal** | A one-sentence description of the module's primary function. |

**Key Features/Functionality:**
* List 2-3 essential user-facing features (for Apps) or core services/logic provided (for Packages).
* Example: Handles user authentication flow.
* Example: Provides a standardized set of custom Button widgets.

**Dependencies/Integrations (External):**
* List 1-2 critical external dependencies (e.g., Firebase, Bloc, Riverpod) or external APIs/Services it heavily relies on.

**Summary:**
A brief, high-level paragraph (3-4 sentences) summarizing the module's architecture (e.g., uses Bloc for state), its main components, and its role within the larger monorepo ecosystem.

---

**[REPEAT FOR NEXT MODULE]**
Instruction for Input (to be included when feeding the code to the AI):

Please provide the following input from your codebase:

A listing of your monorepo's top-level directory structure, specifically the contents of the apps/ and packages/ folders (e.g., the output of tree -L 2 or similar).

For the most critical modules, the content of their main entry file (e.g., lib/main.dart for apps or lib/src/[module_name].dart for packages) and/or the pubspec.yaml file to infer dependencies and purpose.