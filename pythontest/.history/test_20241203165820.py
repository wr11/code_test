class OperationRegister(type):
	registry = {}

	def __new__(mcs, *args, **kwargs):
		print("mcs", mcs, "\n", *args, "\n", **kwargs)
		cls = type.__new__(mcs, *args, **kwargs)
		if len(cls.__mro__) > 2:
			OperationRegister.registry[cls.__operation__] = cls()
		return cls


class OperationBase(metaclass=OperationRegister):
	__operation__ = ""
	__help__ = ""
	__description__ = ""

	def define_arguments(self, parser):
		raise NotImplementedError

	def run(self, args):
		raise NotImplementedError


# pylint: disable=line-too-long
class OperationSingleStart(OperationBase):
	__operation__ = "single_start"
	__help__ = "Start a single service"
	__description__ = "Just bring up a single service, do not check data directory and mongo"

	def define_arguments(self, parser):
		parser.add_argument("type", choices=("multi", "unique"))
		parser.add_argument("name", choices=Settings.AVAILABLE_SERVICES)
		parser.add_argument(
			"--num",
			type=int,
			default=1,
			help="Number of servers to start. Ignored if it is a unique service",
		)
		parser.add_argument(
			"--debug",
			nargs=3,
			default=None,
			metavar=("TYPE", "SERVICE", "ID"),
			help="Start the service with gdbserver and connect to a pycharm debugger (A gdb client and a pycharm debugger are required).\n" # noqa
			"- TYPE: gdb/pycharm/gdb_pycharm\n"
			"- SERVICE: name of the service\n"
			"- ID: index of the multi service (ignored if it is a unique service)",
		)
		parser.add_argument(
			"--wait",
			action="store_true",
			default=False,
			help="Wait for server exit"
		)

	def run(self, args):
		if args.debug is not None:
			if args.debug[0] not in DebugType.AllTypes:
				raise ValueError("Debug type must be one of {}".format(DebugType.AllTypes))

			Settings.DEBUG_TYPE = args.debug[0]
			Settings.DEBUG_SERVICE = args.debug[1]
			Settings.DEBUG_SERVICE_ID = int(args.debug[2]) if len(args.debug) == 3 else None

		if args.wait:
			signal.signal(signal.SIGINT, sig_int_handler)

		if args.type == "unique":
			RunUniqService(args.name)
		elif args.type == "multi":
			RunMultiService(args.name, args.num)

		if args.wait:
			for p in all_processes:
				p.wait()
				
print(OperationRegister.registry)