# (c) 2017 Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

# Make coding more python3-ish
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = '''
    callback: andock_stdout
    type: stdout
    short_description: yaml-ized Ansible screen output
    version_added: 2.5
    description:
        - Ansible output that can be quite a bit easier to read than the
          default JSON formatting.
    extends_documentation_fragment:
      - default_callback
    requirements:
      - set as stdout in configuration
'''

import yaml
import json
import re
import string
import sys

from ansible import constants as C
from ansible.module_utils._text import to_bytes, to_text
from ansible.module_utils.six import string_types
from ansible.parsing.yaml.dumper import AnsibleDumper
from ansible.plugins.callback import CallbackBase, strip_internal_keys
from ansible.plugins.callback.default import CallbackModule as Default
from pprint import pprint

# from http://stackoverflow.com/a/15423007/115478
def should_use_block(value):
    """Returns true if string should be in block format"""
    for c in u"\u000a\u000d\u001c\u001d\u001e\u0085\u2028\u2029":
        if c in value:
            return True
    return False


def my_represent_scalar(self, tag, value, style=None):
    """Uses block style for multi-line strings"""
    if style is None:
        if should_use_block(value):
            style = '|'
            # we care more about readable than accuracy, so...
            # ...no trailing space
            value = value.rstrip()
            # ...and non-printable characters
            value = ''.join(x for x in value if x in string.printable)
            # ...tabs prevent blocks from expanding
            value = value.expandtabs()
            # ...and odd bits of whitespace
            value = re.sub(r'[\x0b\x0c\r]', '', value)
            # ...as does trailing space
            value = re.sub(r' +\n', '\n', value)
        else:
            style = self.default_style
    node = yaml.representer.ScalarNode(tag, value, style=style)
    if self.alias_key is not None:
        self.represented_objects[self.alias_key] = node
    return node


class CallbackModule(Default):

    """
    Variation of the Default output which uses nicely readable YAML instead
    of JSON for printing results.
    """

    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'andock_stdout'
    def __init__(self):
        super(CallbackModule, self).__init__()
        yaml.representer.BaseRepresenter.represent_scalar = my_represent_scalar

    def v2_playbook_on_task_start(self, task, is_conditional):
        self.outlines = []
        self.outlines.append("TASK [%s]" % task.get_name().strip())
        if self._display.verbosity >= 2:
            path = task.get_path()
            if path:
                self.outlines.append("task path: %s" % path)

    def v2_runner_on_ok(self, result):
        if 'print_action' in result._task.tags or self._display.verbosity > 1:
            super(CallbackModule, self).v2_runner_on_ok(result)
        self.outlines = []

    def v2_playbook_on_stats(self, stats):
        pass

    def v2_runner_on_unreachable(self, result):
        if self._last_task_banner != result._task._uuid:
            self._print_task_banner(result._task)

        delegated_vars = result._result.get('_ansible_delegated_vars', None)
        if delegated_vars:
            msg = "fatal: [%s -> %s]: UNREACHABLE! " % (result._host.get_name(), delegated_vars['ansible_host'], self._dump_results(result._result))
        else:
            dump_result = self._dump_results(result._result)
            if "SSH Error: data could not be sent to remote host" in dump_result:
                dump_result = "Is Andock installed? To install Andock run \"andock server install\""
            msg = "fatal: [%s]: UNREACHABLE! => %s" % (result._host.get_name(), dump_result)
        self._display.display(msg, color=C.COLOR_UNREACHABLE, stderr=True)

    def v2_runner_item_on_ok(self, result):
        if 'print_action' in result._task.tags or self._display.verbosity > 1:
            super(CallbackModule, self).v2_runner_item_on_ok(result)

        self.outlines = []
    def _handle_warnings(self, res):
        ''' display warnings, if enabled and any exist in the result '''

        if 'warnings' in res and res['warnings']:
            for warning in res['warnings']:
                self._display.warning(warning)
                pass
            del res['warnings']
        if 'deprecations' in res and res['deprecations']:
            for warning in res['deprecations']:

                self._display.deprecated(**warning)
            del res['deprecations']

    def v2_runner_on_failed(self, result, ignore_errors=False):
        super(CallbackModule, self).v2_runner_on_failed(result, ignore_errors)

    def v2_runner_on_skipped(self, result):
        self.outlines = []

    def v2_playbook_item_on_skipped(self, result):
        self.outlines = []

    def v2_runner_item_on_skipped(self, result):
        self.outlines = []

    def v2_playbook_on_play_start(self, play):
        #msg = u"START"
        self._play = play
        #self._display.banner(msg)

    def display(self):
        if len(self.outlines) == 0:
            return
        (first, rest) = self.outlines[0], self.outlines[1:]
        self._display.banner(first)
        for line in rest:
            self._display.display(line)
        self.outlines = []

    def _dump_results(self, result, indent=None, sort_keys=True, keep_invocation=False):
        if result.get('_ansible_no_log', False):
            return json.dumps(dict(censored="The output has been hidden due to the fact that 'no_log: true' was specified for this result"))

        # All result keys stating with _ansible_ are internal, so remove them from the result before we output anything.
        abridged_result = strip_internal_keys(result)

        # remove invocation unless specifically wanting it
        if not keep_invocation and self._display.verbosity < 3 and 'invocation' in result:
            del abridged_result['invocation']

        # remove diff information from screen output
        if self._display.verbosity < 3 and 'diff' in result:
            del abridged_result['diff']

        # remove exception from screen output
        if 'exception' in abridged_result:
            del abridged_result['exception']

        dumped = ''

        # put changed and skipped into a header line
        if 'changed' in abridged_result:
            dumped += 'changed=' + str(abridged_result['changed']).lower() + ' '
            del abridged_result['changed']

        if 'skipped' in abridged_result:
            dumped += 'skipped=' + str(abridged_result['skipped']).lower() + ' '
            del abridged_result['skipped']

        # if we already have stdout, we don't need stdout_lines
        if 'stdout' in abridged_result and 'stdout_lines' in abridged_result:
            abridged_result['stdout_lines'] = '<omitted>'

        # if we already have stderr, we don't need stderr_lines
        if 'stderr' in abridged_result and 'stderr_lines' in abridged_result:
            abridged_result['stderr_lines'] = '<omitted>'

        if abridged_result:
            dumped += '\n'
            dumped += to_text(yaml.dump(abridged_result, allow_unicode=True, width=1000, Dumper=AnsibleDumper, default_flow_style=False))

        # indent by a couple of spaces
        dumped = '\n  '.join(dumped.split('\n')).rstrip()
        return dumped


    def _serialize_diff(self, diff):
        return to_text(yaml.dump(diff, allow_unicode=True, width=1000, Dumper=AnsibleDumper, default_flow_style=False))

    v2_playbook_on_handler_task_start = v2_playbook_on_task_start
