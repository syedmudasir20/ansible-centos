#!/usr/bin/python

from ansible.module_utils.basic import AnsibleModule
import subprocess

def run_module():
    module_args = dict(
        service_name=dict(type='str', required=True)
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False
    )

    service = module.params['service_name']

    # Check service status
    try:
        status = subprocess.check_output(
            ["systemctl", "is-active", service],
            stderr=subprocess.STDOUT
        ).decode().strip()
    except subprocess.CalledProcessError:
        status = "inactive"

    result = dict(service=service, status=status)

    # If service is inactive, try starting it
    if status != "active":
        try:
            subprocess.check_call(["systemctl", "start", service])
            result['status'] = "started"
            result['changed'] = True
        except Exception as e:
            module.fail_json(msg=f"Failed to start {service}: {e}", **result)
    else:
        result['changed'] = False

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
