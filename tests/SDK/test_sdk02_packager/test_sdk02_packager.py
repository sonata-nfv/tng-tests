import yaml
import tempfile
import shutil
import subprocess
import time
import os
import csv
import resource


class TestProject:

    def __init__(self, project_path, i0=1, nsd="nsd.yml",
                 vnfd="vnfd_number_1.yml"):
        self.project_path = project_path
        self.tmp_project_path = ""
        self.tmp_diretory = None

        self.vnf_descriptor = None
        self.nsd_descriptor = None
        self.project_descriptor = None

        self.i = i0
        self.i0 = i0
        self.results = {"t": [], "skip": []}

        self.load_project_to_temp(project_path)

        self.vnf_descriptor_path = os.path.join(self.tmp_project_path, vnfd)
        self.nsd_descriptor_path = os.path.join(self.tmp_project_path, nsd)

        self.nsd_descriptor = self.load_descriptor(self.nsd_descriptor_path)

        self.vnf_descriptor = self.load_descriptor(self.vnf_descriptor_path)

        self.project_descriptor = self.load_descriptor(os.path.join(
            self.tmp_project_path, "project.yml"))

    def descriptors(self):
        yield self.nsd_descriptor
        yield self.vnf_descriptor
        yield self.project_descriptor

    def descriptor_paths(self):
        yield self.nsd_descriptor_path
        yield self.vnf_descriptor_path
        yield os.path.join(self.tmp_project_path, "project.yml")

    def path_and_desc(self):
        yield self.nsd_descriptor_path, self.nsd_descriptor
        yield self.vnf_descriptor_path, self.vnf_descriptor
        yield (os.path.join(self.tmp_project_path, "project.yml"),
               self.project_descriptor)

    def load_project_to_temp(self, project_path):
        self.tmp_diretory = tempfile.mkdtemp()
        #self.tmp_diretory = "first_test"
        self.tmp_project_path = os.path.join(self.tmp_diretory,
                                             os.path.basename(project_path))
        shutil.copytree(project_path, self.tmp_project_path)

    def get_vnf_incremented_filesname(self):
        vnf_filename = os.path.splitext(self.vnf_descriptor_path)
        vnf_filename = (
                vnf_filename[0].split("_number_")[0] + "_number_" +
                str(self.i) + vnf_filename[1])
        return vnf_filename

    def increment(self):
        self.i += 1
        cnf = "cnf_" + str(self.i)

        self.vnf_descriptor["name"] = cnf
        self.vnf_descriptor["cloudnative_deployment_units"]\
            [0]["connection_points"][0]["port"] += 1
        self.vnf_descriptor["connection_points"][0]["port"] += 1
        vnf_filename = self.get_vnf_incremented_filesname()
        self.vnf_descriptor_path = vnf_filename

        function = {"vnf_id": cnf,
                    "vnf_name": cnf,
                    "vnf_vendor": "eu.5gtango",
                    "vnf_version": "0.1"
                    }
        self.nsd_descriptor["network_functions"].append(function)
        self.nsd_descriptor["virtual_links"][0]\
            ["connection_points_reference"].append(cnf + ":data")

        self.project_descriptor["files"].append(
            {"path": os.path.basename(vnf_filename),
             "type": "application/vnd.5gtango.vnfd",
             "tags": ["eu.5gtango"]})

    def load_descriptor(self, path):
        ret = None
        with open(path) as f:
            ret = yaml.load(f)
        return ret

    def store_descriptors(self):
        for d_path, d in self.path_and_desc():
            self.store_descriptor(d_path, d)

    def store_descriptor(self, path, desc):
        ret = None
        with open(path, "w") as f:
            ret = yaml.dump(desc, f)
        return ret

    def yield_command(self, _format="eu.5gtango"):
        yield ["tng-sdk-package", "-p", self.tmp_project_path,
               "-o", self.tmp_diretory, "--format", _format,
               "--validation_level", "skip"]
        yield ["tng-sdk-package", "-p", self.tmp_project_path,
               "-o", self.tmp_diretory, "--format", _format,
               "--validation_level", "t"]

    def test_one(self, command, i, *args, **kwargs):
        t = time.time()
        p = subprocess.Popen(command, *args, **kwargs)
        p.wait()
        self.results[command[-1]].append(
            [i, time.time() - t,
             resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss])
        return p

    def test_in_loop(self, n=100):
        while self.i <= n:
            for command in self.yield_command():
                print(" ".join(command))
                self.test_one(command, self.i, shell=False)
            self.increment()
            self.store_descriptors()

    def store_results(self, _format="eu.5gtango"):
        for validation_level, rows in self.results.items():
            filename = \
                "results_{}_valid_level_{}.csv".format(_format,
                                                       validation_level)
            with open(filename, "w") as f:
                writer = csv.writer(f)
                writer.writerow(
                    ["number_of_vnfs", "process_time", "memory_usage"])
                for row in rows:
                    writer.writerow(row)


class TestProjectOsm(TestProject):

    def __init__(self, *args, **kwargs):
        super(TestProjectOsm, self).__init__(nsd="cirros_1vnf_nsd.yaml",
                                             vnfd="cirros_vnfd_number_1.yaml",
                                             *args, **kwargs)

    def yield_command(self, _format="eu.etsi.osm"):
        return super(TestProjectOsm, self).yield_command(_format)

    def store_results(self, _format="eu.etsi.osm"):
        return super(TestProjectOsm, self).store_results(_format)

    def increment(self):
        self.i += 1
        vnf_filename = self.get_vnf_incremented_filesname()
        self.vnf_descriptor_path = vnf_filename

        self.project_descriptor["files"].append(
            {"path": os.path.basename(vnf_filename),
             "type": "application/vnd.etsi.osm.vnfd"})


def main():
    test_project = TestProjectOsm("test_project_osm")
    test_project.test_in_loop()
    test_project.store_results()

    test_project = TestProject("test_project")
    test_project.test_in_loop()
    test_project.store_results()


if __name__ == "__main__":
    main()
