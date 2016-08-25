# Copyright (c) 2015 Aptira Pty Ltd.
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.


from guts.i18n import _


class MigrationDriver(object):
    """Base class for migration drivers."""

    def __init__(self, *args, **kwargs):
        pass

    def initialize(self, connection_dict):
        """Initialize Migration Driver.

        This is for drivers that don't implement initialize().
        """
        msg = _("Initialize source hypervisor is not "
                "implemented by the driver.")
        raise NotImplementedError(msg)

    def get_vms_list(self):
        """Get all VMs stub.

        This is for drivers that don't implement get_vms_list().
        """
        msg = _("Get VMs list from source hypervisor is not "
                "implemented by the driver.")
        raise NotImplementedError(msg)

    def download_vm_disks(self, context, vm_uuid, base_path):
        """Download VM disks stub.

        This is for drivers that don't implement download_vm_disks().
        """
        msg = _("Method to download VM disks from source hypervisor to "
                "base_path is not implemented by the driver.")
        raise NotImplementedError(msg)
