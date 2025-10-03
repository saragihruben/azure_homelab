from termcolor import colored
import csv
import subprocess
import json
import platform
import shutil

def info(msg): print(colored(f"[INFO]  {msg}", "cyan"))
def success(msg): print(colored(f"[✓]     {msg}", "green"))
def warning(msg): print(colored(f"[!]     {msg}", "yellow"))
def error(msg): print(colored(f"[✗]     {msg}", "red"))

def az_cli(cmd_list):
    # Find the Azure CLI binary path
    az_path = shutil.which("az")
    
    # If the path is not found, raise an error
    if az_path is None:
        error("❌ Azure CLI ('az') not found in PATH. Is it installed and accessible?")
        raise FileNotFoundError("Azure CLI not found")
    
    # Force the use of shell for Windows batch files (.CMD)
    if az_path.endswith(".CMD"):
        use_shell = True
    else:
        use_shell = False  # Not using shell for executables like .EXE

    cmd_list[0] = az_path  # Ensure full path to az is used

    try:
        result = subprocess.run(cmd_list, capture_output=True, text=True, shell=use_shell)
        result.check_returncode()  # This will raise an exception for non-zero exit codes
    except subprocess.CalledProcessError as e:
        error(f"Command failed with error: {e}")
        return False, e.stderr.strip()  # Return stderr on error
    except Exception as e:
        error(f"Unexpected error: {e}")
        return False, str(e)  # Return unexpected error message

    # Return success with stdout if no errors
    return True, result.stdout.strip()


def get_user_id(upn):
    exists, out = az_cli(["az", "ad", "user", "show", "--id", upn, "--query", "id", "-o", "tsv"])
    if not exists:
        info(f"User {upn} not found in Azure AD.")
        return None  # Return None if the user doesn't exist
    return out



def get_user_upn(user_id):
    exists, out = az_cli(["az", "ad", "user", "show", "--id", user_id, "--query", "userPrincipalName", "-o", "tsv"])
    return out if exists else None


def get_group_id(group_name):
    exists, out = az_cli(["az", "ad", "group", "show", "--group", group_name, "--query", "id", "-o", "tsv"])
    return out if exists else None


def is_member(group_id, user_id):
    exists, _ = az_cli(["az", "ad", "group", "member", "check", "--group", group_id, "--member-id", user_id])
    return exists


def get_existing_memberships():
    memberships = {}
    info("🔍 Fetching existing group memberships from Azure...")
    exists, out = az_cli(["az", "ad", "group", "list", "--query", "[].{id:id,displayName:displayName}", "-o", "json"])
    if exists:
        groups = json.loads(out)
        for group in groups:
            group_id = group["id"]
            group_name = group["displayName"]
            group_key = group_name.lower().replace(" ", "_")
            exists, members = az_cli([
                "az", "ad", "group", "member", "list",
                "--group", group_id,
                "--query", "[].{id:id}",
                "-o", "json"
            ])
            if exists:
                members = json.loads(members)
                for member in members:
                    user_id = member["id"]
                    memberships[f"{user_id}_{group_key}"] = {
                        "user_id": user_id,
                        "group_id": group_id
                    }
    return memberships

def main():
    info("📄 Reading users.csv...")
    users = {}
    groups = {}
    memberships = {}
    new_users = 0
    new_groups = 0
    new_memberships = 0

    existing_memberships = get_existing_memberships()

    with open("users.csv", newline="") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            key = row["user_key"]
            upn = row["user_principal_name"]
            display_name = row["display_name"]
            password = row["password"]
            group_list = row["groups"].split("|")

            # Check if user exists and get their user_id
            user_id = get_user_id(upn)

            if not user_id:
                # New user
                users[key] = {
                    "user_principal_name": upn,
                    "display_name": display_name,
                    "password": password
                }
                new_users += 1
                success(f"New user to create: {upn}")
            else:
                # Existing user
                existing_upn = get_user_upn(user_id)
                if existing_upn != upn:
                    warning(f"UPN mismatch: {existing_upn} (Azure) != {upn} (CSV) - Skipping this user.")
                    continue
                users[key] = {
                    "user_principal_name": upn,
                    "display_name": display_name,
                    "password": password,
                    "user_id": user_id
                }

            for group in group_list:
                group = group.strip()
                group_key = group.lower().replace(" ", "_")
                group_id = get_group_id(group)

                # Track group and add it to the groups dictionary
                if group_key not in groups:
                    groups[group_key] = {
                        "display_name": group
                    }
                    if not group_id:
                        new_groups += 1
                        success(f"New group to create: {group}")
                    else:
                        groups[group_key]["group_id"] = group_id
                        success(f"Existing group found: {group}")

                # Check membership and avoid duplicate creation
                if user_id and group_id:
                    membership_key = f"{user_id}_{group_key}"
                    if membership_key not in existing_memberships:
                        memberships[f"{key}_{group_key}"] = {
                            "user_id": user_id,
                            "group_id": group_id
                        }
                        new_memberships += 1
                        success(f"Assigning membership: {upn} → {group}")
                    else:
                        warning(f"Membership exists: {upn} → {group}")
                        memberships[f"{key}_{group_key}"] = {
                            "user_id": user_id,
                            "group_id": group_id
                        }

    # Write users.tfvars
    info("📝 Writing users.tfvars...")
    with open("users.tfvars", "w") as f:
        f.write("users = {\n")
        for key, user in users.items():
            f.write(f'  "{key}" = {{\n')
            f.write(f'    user_principal_name = "{user["user_principal_name"]}"\n')
            f.write(f'    display_name        = "{user["display_name"]}"\n')
            f.write(f'    password            = "{user["password"]}"\n')
            f.write("    force_password_change = true\n")
            f.write("  }\n")
        f.write("}\n")

    # Write groups.tfvars
    info("📝 Writing groups.tfvars...")
    with open("groups.tfvars", "w") as f:
        f.write("groups = {\n")
        for key, group in groups.items():
            f.write(f'  "{key}" = {{\n')
            f.write(f'    display_name = "{group["display_name"]}"\n')
            if "group_id" in group:
                f.write(f'    group_id = "{group["group_id"]}"\n')
            f.write("  }\n")
        f.write("}\n")

    # Write memberships.tfvars
    info("📝 Writing memberships.tfvars...")
    with open("memberships.tfvars", "w") as f:
        f.write("memberships = {\n")
        for key, m in memberships.items():
            f.write(f'  "{key}" = {{\n')
            f.write(f'    user_id  = "{m["user_id"]}"\n')
            f.write(f'    group_id = "{m["group_id"]}"\n')
            f.write("  }\n")
        f.write("}\n")

    success("\n✅ tfvars files generated: users.tfvars, groups.tfvars, memberships.tfvars")
    info("\n📊 Summary:")
    info(f"  ➕ New users: {new_users}")
    info(f"  ➕ New groups: {new_groups}")
    info(f"  🔁 Memberships to assign: {new_memberships}")

if __name__ == "__main__":
    main()