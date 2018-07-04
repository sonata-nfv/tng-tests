import yaml
import logging
import os
import pkg_resources
import uuid

log = logging.getLogger(__name__)


class EventLogger(object):

    def __init__(self, name):
        self._name = name
        self._log = logging.getLogger(name)
        self._events = dict()

        # load events config
        self._eventdict = self.load_eventcfg()

    @property
    def errors(self):
        return list(filter(lambda event: event['level'] == 'error',
                           self._events.values()))

    @property
    def warnings(self):
        return list(filter(lambda event: event['level'] == 'warning',
                    self._events.values()))

    def reset(self):
        self._events.clear()
        self._eventdict = self.load_eventcfg()

    def log(self, header, msg, source_id, event_code, event_id=None,
            detail_event_id=None):
        level = self._eventdict[event_code]
        key = self.get_key(source_id, event_code, level)

        if key not in self._events.keys():
            event = self._events[key] = dict()
            event['source_id'] = source_id
            event['event_code'] = event_code
            event['level'] = level
            event['event_id'] = event_id if event_id else source_id
            event['header'] = header
            event['detail'] = list()

            # log header upon new key
            if level == 'error':
                self._log.error(header)
            elif level == 'warning':
                self._log.warning(header)
            elif level == 'none':
                pass

        else:
            event = self._events[key]

        if not msg:
            return

        # log message
        if level == 'error':
            self._log.error(msg)
        elif level == 'warning':
            self._log.warning(msg)
        elif level == 'none':
            pass

        msg_dict = dict()
        msg_dict['message'] = msg
        msg_dict['detail_event_id'] = detail_event_id \
            if detail_event_id else event['event_id']
        event['detail'].append(msg_dict)

    @staticmethod
    def load_eventcfg():
        filename = 'eventcfg.yml'
        configpath = pkg_resources.resource_filename(
            __name__, os.path.join('eventcfg.yml'))
        with open(configpath, 'r') as _f:
            eventdict = yaml.load(_f)

        # if existent, load custom eventcfg.yml
        configpath = filename
        if os.path.isfile(configpath):
            with open(configpath, 'r') as _f:
                custom_eventdict = yaml.load(_f)
                
            # check if all events of custom config are valid
            for cevent, cvalue in custom_eventdict.items():
                cvalue = str(cvalue).lower()
                if cevent not in eventdict.keys() or not \
                        (cvalue == 'error' or cvalue == 'warning' or
                         cvalue == 'none'):
                    log.warning("Failed parsing custom event config file "
                                "'{0}': '{1}: {2}' is not a valid event or "
                                "has an invalid value. Assuming defaults."
                                .format(configpath, cevent, cvalue))
                    return eventdict

            # overlap default values
            for cevent, cvalue in custom_eventdict.items():
                eventdict[cevent] = cvalue

        return eventdict

    @staticmethod
    def dump_eventcfg(eventdict):
        filename = "eventcfg.yml"
        with open(filename, 'w') as _f:
            yaml.dump(eventdict, _f, default_flow_style=False)

    @staticmethod
    def get_key(source_id, event_code, level):
        return str(source_id) + '-' + str(event_code) + '-' + str(level)


class LoggerManager(object):

    def __init__(self):
        self._loggers = dict()

    def get_logger(self, name):
        if name not in self._loggers.keys():
            self._loggers[name] = EventLogger(name)
        else:
            self._loggers[name].reset()

        return self._loggers[name]


EventLogger.manager = LoggerManager()


def get_logger(name):
    if not name:
        return
    return EventLogger.manager.get_logger(name)


def generate_evt_id():
    return str(uuid.uuid4())
