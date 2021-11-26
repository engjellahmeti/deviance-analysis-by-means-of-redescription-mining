# @project Deviance Analysis by Means of Redescription Mining - Master Thesis
# @author Engjëll Ahmeti
# @date 12/8/2020

import re
from pandas.core.frame import DataFrame
from feature_vectors.declare_constraint import DeclareConstraint
from feature_vectors.rule_extractor import RuleExtractor
from redescription_mining.redescription import RedescriptionMining
from event_log_generation.generate_logs import GenerateEventLogs
from rxes_approach.rxes_file import RXESApproach
import os
from log_print import Print
import pandas as pd
from nlg.nlg import NLG
import random as rd
import sys, getopt
from redescription_mining.data_model import RedescriptionDataModel
from typing import List, Optional, Tuple


class Main:
    def __init__(self, extract_dsynts_on_leafs, algorithm, config_or_template):
        self.algorithms = ['reremi', 'layeredtrees', 'splittrees', 'cartwheel']
        self.algorithm = algorithm
        self.config_or_template = config_or_template
        if algorithm is not None:
            self.ruleExt = RuleExtractor()
            self.redesc = RedescriptionMining()
            self.rxes = RXESApproach()
            self.nlg_ = NLG(extract_dsynts_on_leafs=extract_dsynts_on_leafs)

    # region Helper Methods
    def discover_redescription_for_each_constraint(self, frame: DataFrame, event_log_path: str, declare_constraint: DeclareConstraint, is_positive_or_negative_log: str, filename: str) -> DataFrame:
        redescription_data_model: RedescriptionDataModel = self.ruleExt.extract_fulfilment(event_log_path=event_log_path,
                                                                                        declare_constraint=declare_constraint,
                                                                                        is_positive_or_negative_log=is_positive_or_negative_log,
                                                                                        write_to_CSV=True,
                                                                                        remove_attributes=True)

        redescriptions = self.redesc.discover_redescriptions(redescription_data_model=redescription_data_model, is_positive_or_negative_log=is_positive_or_negative_log, activation_activity=declare_constraint.activation, target_activity=declare_constraint.target,
                                                                config_or_template=self.config_or_template, filename=filename+'-'+algorithm, algorithm=self.algorithm) # algorithm='reremi')
        
        if not redescriptions.empty:
            if frame is None:
                redescriptions['constraint'] = [declare_constraint.rule_type for x in
                                                        range(0, len(redescriptions.index))]
                frame = redescriptions.copy()
            else:
                redescriptions['constraint'] = [declare_constraint.rule_type for x in range(0, len(redescriptions.index))]
                frame = pd.concat([frame, redescriptions.copy()])

        return frame
    
    def write_final_descriptions(self, negative: DataFrame, positive: DataFrame, filename: str) -> None:
        if negative is not None:
            negative.to_csv(os.path.abspath(
                'redescription_mining/results/') + '/' + filename + '-' + self.algorithm + '-negative.queries', index=False)
        
        if positive is not None:
            positive.to_csv(os.path.abspath(
                'redescription_mining/results/') + '/' + filename + '-' + self.algorithm + '-positive.queries', index=False)
    # endregion

    # region 1. Input Declare File
    def input_declare_file(self, filename: str, declare_file_path: str, generate_logs: bool = True, only_negative_logs: bool = False, amount_of_traces: int = 10000) -> Optional[Tuple[DataFrame, DataFrame]]:
        g = GenerateEventLogs()
        declare_constraints = g.get_declare_constraints(declare_file_path=declare_file_path)

        negative_event_log_path = os.path.abspath('event_log_reader/logs/' + filename + '-negative.xes')
        positive_event_log_path = os.path.abspath('event_log_reader/logs/' + filename + '-positive.xes')

        negative = None
        positive = None

        if only_negative_logs:
            g.generate_logs(declare_file_path=declare_file_path, event_log_location=negative_event_log_path)#, amount_of_traces=amount_of_traces)
            for dc in declare_constraints:
                print()
                dc.__str__()
                negative = self.discover_redescription_for_each_constraint(frame=negative, event_log_path=negative_event_log_path, declare_constraint=dc, is_positive_or_negative_log='negative', filename=filename)

        elif generate_logs:
            g.generate_logs(declare_file_path=declare_file_path, event_log_location=positive_event_log_path, both_positive_negative_event=True, amount_of_traces=amount_of_traces)

            for dc in declare_constraints:
                dc.__str__()
                negative = self.discover_redescription_for_each_constraint(frame=negative, event_log_path=negative_event_log_path, declare_constraint=dc, is_positive_or_negative_log='negative', filename=filename)

                positive = self.discover_redescription_for_each_constraint(frame=positive, event_log_path=positive_event_log_path, declare_constraint=dc, is_positive_or_negative_log='positive', filename=filename)
                print()

        self.write_final_descriptions(negative=negative, positive=positive, filename=filename)

        Print.YELLOW.print('1. Input Declare File finished.')

        return (negative, positive)
    # endregion

    # region 2. Input real positive and negative event logs
    def input_real_positive_and_negative_event_logs(self, positive_event_log_path: str, negative_event_log_path: str) -> Optional[Tuple[DataFrame, DataFrame]]:
        log_id = self.rxes.self.rxes(file_path=positive_event_log_path)

        declare_constraints = self.rxes.get_respone_constraints(log_id=log_id, no_of_rows=100, type_of_constraints='not mp')
        
        negative = None
        positive = None

        for dc in declare_constraints:            
            print()
            dc.__str__()

            negative = self.discover_redescription_for_each_constraint(frame=negative, event_log_path=negative_event_log_path, declare_constraint=dc, is_positive_or_negative_log='negative', filename=filename)

            positive = self.discover_redescription_for_each_constraint(frame=positive, event_log_path=positive_event_log_path, declare_constraint=dc, is_positive_or_negative_log='positive', filename=filename)

        self.write_final_descriptions(negative=negative, positive=positive, filename=filename)

        Print.YELLOW.print('2. Input real positive and negative event logs finished.')

        return (negative, positive)
    #endregion

    # region 3. Input positive and negative event logs together with Declare Constraints
    def input_positive_and_event_logs_together_with_declare_constraints(self, positive_event_log_path: str, negative_event_log_path: str, declare_constraints: List[DeclareConstraint], filename) -> Optional[Tuple[DataFrame, DataFrame]]:
        negative = None
        positive = None

        for dc in declare_constraints:
            print()
            dc.__str__()

            negative = self.discover_redescription_for_each_constraint(frame=negative, event_log_path=negative_event_log_path, declare_constraint=dc, is_positive_or_negative_log='negative', filename=filename)

            positive = self.discover_redescription_for_each_constraint(frame=positive, event_log_path=positive_event_log_path, declare_constraint=dc, is_positive_or_negative_log='positive', filename=filename)

        self.write_final_descriptions(negative=negative, positive=positive, filename=filename)

        Print.YELLOW.print('3. Input positive and negative event logs together with Declare Constraints finished. ')

        return (negative, positive)
    #endregion

    # region 4. Input Declare File For One Type Only
    def input_declare_file_with_only_one_event_log(self, filename: str, is_positive_or_negative_log: str, declare_file_path: str, amount_of_traces: int = 1000) -> Optional[DataFrame]:
        g = GenerateEventLogs()
        declare_constraints = g.get_declare_constraints(declare_file_path=declare_file_path)
        event_log_path = os.path.abspath('event_log_reader/logs/' + filename + '-'+is_positive_or_negative_log+'.xes')

        g.generate_logs(declare_file_path=declare_file_path, event_log_location=event_log_path, amount_of_traces=amount_of_traces)

        output = None

        for dc in declare_constraints:
            print()
            dc.__str__()

            output = self.discover_redescription_for_each_constraint(frame=output, event_log_path=event_log_path, declare_constraint=dc, is_positive_or_negative_log=is_positive_or_negative_log, filename=filename)

        if is_positive_or_negative_log == 'negative':
            self.write_final_descriptions(negative=output, positive=None, filename=filename)
        elif is_positive_or_negative_log == 'positive':
            self.write_final_descriptions(negative=None, positive=output, filename=filename)
        
        Print.YELLOW.print('4. Input Declare File only one event log type finished.')

        return output

    # endregion
    
    # region X. NLG processing
    def nlg_call(self, negative_redescriptions_path, positive_redescriptions_path, print_bool=False, output=''):
        (set_of_rules, redescriptions) = self.nlg_.nlg(negative_redescriptions_path, positive_redescriptions_path)

        if print_bool and output == '':
            for item in set_of_rules:
                Print.CYAN.print('--> A negative event log is: ')
                Print.CYAN.print('            -->' + item[0].__str__())
                output += '--> A negative event log is:\n'
                output += '            --> {0}\n'.format(item[0].__str__())

                print()
                Print.CYAN.print('--> While a positive event log is: ')
                output += '\n'
                output += '--> While a positive event log is:\n'
                for itemP in item[1]:
                    Print.CYAN.print('            -->' + itemP.__str__())
                    output += '            --> {0}\n'.format(itemP.__str__())

        return (set_of_rules, redescriptions, output)

    def nlgCall_v2(self, negative_redescriptions_path, positive_redescriptions_path, print_bool=False):
        (negative_rules, positive_rules) = self.nlg_.nlgSplit(negative_redescriptions_path, positive_redescriptions_path)
        output = ''
        if print_bool:
            Print.CYAN.print('--> The negative event log has the following rules: ')
            output += '--> The negative event log has the following rules:\n'
            for index, item in enumerate(negative_rules):
                Print.END.print('            {0}. {1} ({2})'.format(index+1, item[0].__str__(), item[1]))
                output += '            {0}. {1} ({2})\n'.format(index+1, item[0].__str__(), item[1])

            print()

            Print.CYAN.print('--> While the positive event log has the following rules: ')
            output += '\n'
            output += '--> While the positive event log has the following rules:\n'
            for index, item in enumerate(positive_rules):
                Print.END.print('            {0}. {1} ({2})'.format(index+1, item[0].__str__(), item[1]))
                output += '            {0}. {1} ({2})\n'.format(index+1, item[0].__str__(), item[1])

        (setOfRules, redescriptions) = self.nlg_.nlg(negative_redescriptions_path, positive_redescriptions_path)
        output += '\n'
        return (setOfRules, redescriptions, output)

    def get_dsynts(self, set_of_rules):
        return self.nlg_.transform_conll_to_dsynts(set_of_rules)

    def generate_traces_for_nlg_example_output(self, declare_filename, filename, algorithm='reremi'):
        negative_event_log_path = 'event_log_reader/logs/' + filename + '-negative.xes'
        positive_event_log_path = 'event_log_reader/logs/' + filename + '-positive.xes'

        g = GenerateEventLogs()
        declare_file_path = os.path.abspath('event_log_generation/declare constraint files/{0}.decl'.format(declare_filename))
        declare_constraints = g.get_declare_constraints(declare_file_path=declare_file_path)

        result = {}
        for dc in declare_constraints:
            is_positive_or_negative_log = 'negative'
            _ = self.ruleExt.extract_fulfilment(event_log_path=negative_event_log_path,
                                                            declare_constraint=dc,
                                                            is_positive_or_negative_log=is_positive_or_negative_log,
                                                            write_to_CSV=True,
                                                            remove_attributes=True)


            if os.path.exists(os.path.abspath('redescription_mining/results/' + filename + '-' + algorithm + '-positive.queries')):
                output = self.nlg_.find_deviant_traces(filename + '-' + algorithm)

                if len(result.keys()) == 0:
                    result = output
                else:
                    for key in output.keys():
                        if key not in result.keys():
                            result[key] = output[key]
                        else:
                            for rule in output[key].keys():
                                if rule not in result[key].keys():
                                    result[key][rule] = output[key][rule]
                                else:
                                    result[key][rule] = list(set(result[key][rule] + output[key][rule]))



         
        return result

    def contraint_instance_extraction(self, is_positive_or_negative_log, declare_filename, filename, algorithm='reremi'):
        event_log_path = 'event_log_reader/logs/' + filename + '-{0}.xes'.format(is_positive_or_negative_log)

        g = GenerateEventLogs()
        declare_file_path = os.path.abspath(
            'event_log_generation/declare constraint files/{0}.decl'.format(declare_filename))
        declare_constraints = g.get_declare_constraints(declare_file_path=declare_file_path)

        for dc in declare_constraints:
            (_, _, _, _) = self.ruleExt.extract_fulfilment(event_log_path=event_log_path,
                                                            declare_constraint=dc,
                                                            is_positive_or_negative_log=is_positive_or_negative_log,
                                                            write_to_CSV=True,
                                                            remove_attributes=True)
            print()
        Print.YELLOW.print('Constraint Instance Extraction done. ')

    def print_trace_failure(self, traces, k):
        Print.GREEN.print('Concrete examples of traces that failed: ')
        output = 'Concrete examples of traces that failed:\n'

        if len(traces) > 0:
            for trace in traces:
                if len(traces[trace].keys()) >= 3:
                    rules_total = list(traces[trace].keys())
                    rules = [rd.choice(rules_total)]
                    temp = [traces[trace][rules[0]][0]]

                    rules_total.remove(rules[0])
                    rules.append(rd.choice(rules_total))
                    for item in traces[trace][rules[1]]:
                        if 'executed' in item:
                           temp.append(item)

                    if len(temp) == 1:
                        temp.append(traces[trace][rules[1]][0])

                    rules_total.remove(rules[1])
                    rules.append(rd.choice(rules_total))
                    temp.append(traces[trace][rules[2]][0])

                    Print.END.print('The process execution with \'{0}\' is deviant because {1}({2}), {3}({4}) and {5}({6}).'.format(Print.BLUE.__call__(trace), temp[0], rules[0], temp[1], rules[1], temp[2], rules[2]))
                    output += 'The process execution with \'{0}\' is deviant because {1}({2}), {3}({4}) and {5}({6}).\n'.format(trace, temp[0], rules[0], temp[1], rules[1], temp[2], rules[2])

                elif len(traces[trace].keys()) == 2:
                    rules = list(traces[trace].keys())

                    temp = None
                    for item in traces[trace][rules[0]]:
                        if 'executed' in item:
                            temp = [item]
                    if temp is None:
                        temp = [traces[trace][rules[0]][0]]
                    temp.append(traces[trace][rules[1]][0])
                    Print.END.print('The process execution with \'{0}\' is deviant because {1}({2}) and {3}({4}).'.format(Print.BLUE.__call__(trace),temp[0], rules[0], temp[1], rules[1]))
                    output += 'The process execution with \'{0}\' is deviant because {1}({2}) and {3}({4}).\n'.format(trace,temp[0], rules[0], temp[1], rules[1])

                else:
                    rules = list(traces[trace].keys())
                    # temp = traces[trace][rules[0]]
                    temp = None
                    for item in traces[trace][rules[0]]:
                        if 'executed' in item:
                            temp = [item]
                    if temp is None:
                        temp = [traces[trace][rules[0]]]
                    
                    if type(temp) is list and len(temp) > 0:
                        temp = temp[0]

                    Print.END.print('The process execution with \'{0}\' is deviant because {1}({2}).'.format(Print.BLUE.__call__(trace),temp[0], rules[0]))
                    output += 'The process execution with \'{0}\' is deviant because {1}({2}).\n'.format(trace,temp[0], rules[0])

        return output
    # endregion

    #region Extract Arguments
    def extract_arguments(self, argv):
        input_type: int = -1
        algorithm: str = ''
        filename: str = ''
        extract_dsynts: bool = True 
        declare_filename: str = ''
        amount_of_traces: int = -1
        min_trace_length: int = -1
        max_trace_length: int = -1

        try:
            opts, args = getopt.getopt(argv, "h:t:a:f:e:d:s:i:x:",
                                       longopts=["input_type=", "algorithm=", "filename=", "extract_dsynts=",
                                                 "declare_filename=", "amount_of_traces=", "min_trace_length=",
                                                 "max_trace_length="])
        except getopt.GetoptError:
            print(getopt.GetoptError.msg)
            print(
                'python main.py -t <input_type> -a <algorithm> -f <filename> -e <extract_dsynts> -d <declare_filename> -s <amount_of_traces> -i <min_trace_length> -x <max_trace_length>')
            print(r"python main.py -t 1 -a 'reremi' -f 'test' -e True -d 'C:\...\test.decl' -s 1000 -i 2 -x 3")
            sys.exit(2)
        for opt, arg in opts:
            if opt == '-h':
                print(
                    'python main.py -t <input_type> -a <algorithm> -f <filename> -e <extract_dsynts> -d <declare_filename> -s <amount_of_traces> -i <min_trace_length> -x <max_trace_length>')
                print(r"python main.py -t 8 -a 'reremi' -f 'running-example' -e True -d 'Running Example.decl' -s 1000 -i 2 -x 3")
                sys.exit()
            elif opt in ("-t", "--input_type"):
                input_type = int(arg)
            elif opt in ("-a", "--algorithm"):
                algorithm = arg
            elif opt in ("-f", "--filename"):
                filename = arg
            elif opt in ("-e", "--extract_dsynts"):
                extract_dsynts = bool(arg)
            elif opt in ("-d", "--declare_filename"):
                declare_filename = arg
            elif opt in ("-s", "--amount_of_traces"):
                amount_of_traces = int(arg)
            elif opt in ("-i", "--min_trace_length"):
                min_trace_length = int(arg)
            elif opt in ("-x", "--max_trace_length"):
                max_trace_length = int(arg)

        print('{0}-{1}-{2}-{3}-{4}-{5}-{6}-{7}'.format(input_type, algorithm, filename, extract_dsynts, declare_filename,
                                                        amount_of_traces, min_trace_length, max_trace_length))
        return (input_type, algorithm, filename, extract_dsynts, declare_filename, amount_of_traces, min_trace_length, max_trace_length)
    #endregion

if __name__ == '__main__':
    Print.YELLOW.print('The tool has started. ')
    config_or_template = 'template' # 'config'
    main = Main(extract_dsynts_on_leafs=None, algorithm=None, config_or_template=None)

    if len(sys.argv[1:]) > 0:
        (input_type, algorithm, filename, extract_dsynts_on_leafs, declare_filename, amount_of_traces, min_trace_length, max_trace_length) = main.extract_arguments(sys.argv[1:])
        main = Main(extract_dsynts_on_leafs=extract_dsynts_on_leafs, algorithm=algorithm, config_or_template=config_or_template)

    else:
        extract_dsynts_on_leafs = False
        input_type = 8
        algorithm = 'reremi' # 'splittrees' reremi
        config_or_template = 'template' # 'config'
        main = Main(extract_dsynts_on_leafs=extract_dsynts_on_leafs, algorithm=algorithm, config_or_template=config_or_template)
        filename = 'running-example'#'#credit-application-subset' #running-example' # road-traffic-fines,repair-example
        declare_filename = 'Running Example'#Credit Application Subset'#Running Example' # 'FirstPaperExample'  # Repair Example, Road Traffic Fines

    if input_type == 1:
        generate_logs = True
        only_negative_logs = False
        declare_file_path = os.path.abspath('event_log_generation/declare constraint files/{0}.decl'.format(declare_filename))

        negBool, posBool = True, True
        amount_of_traces = 1000
        while (negBool and posBool) or negBool:
            if posBool:
                (negative, positive) = main.input_declare_file(filename=filename, declare_file_path=declare_file_path, generate_logs=generate_logs, only_negative_logs=only_negative_logs, amount_of_traces=amount_of_traces)
                if positive is not None and negative is not None:
                    posBool = False
                    negBool = False
                elif positive is not None:
                    posBool = False
            else:
                break
                onlyNegative = True
                (negative, positive) = main.input_declare_file(filename=filename, declare_file_path=declare_file_path, generate_logs=generate_logs, only_negative_logs=only_negative_logs)
                if negative.shape[0] > 0:
                    negBool = False
                
            amount_of_traces += 1000
            if amount_of_traces > 16000:
                break

    elif input_type == 2:
        negative_event_log_path = 'event_log_reader/logs/'+filename+'-negative.xes'
        positive_event_log_path = 'event_log_reader/logs/'+filename+'-positive.xes'

        (negative, positive) = main.input_real_positive_and_negative_event_logs(positive_event_log_path=positive_event_log_path, negative_event_log_path=negative_event_log_path)

    elif input_type == 3:
        negative_event_log_path = 'event_log_reader/logs/'+filename+'-negative.xes'
        positive_event_log_path = 'event_log_reader/logs/'+filename+'-positive.xes'

        g = GenerateEventLogs()
        declare_file_path = os.path.abspath('event_log_generation/declare constraint files/{0}.decl'.format(declare_filename))

        declare_constraints = g.get_declare_constraints(declare_file_path=declare_file_path)

        (negative, positive) = main.input_positive_and_event_logs_together_with_declare_constraints(positive_event_log_path=positive_event_log_path, negative_event_log_path=negative_event_log_path, declare_constraints=declare_constraints, filename=filename)

    elif input_type == 4:
        declare_file_path = os.path.abspath('event_log_generation/declare constraint files/{0}.decl'.format(declare_filename))

        output = main.input_declare_file_with_only_one_event_log(is_positive_or_negative_log='positive', filename=filename, declare_file_path=declare_file_path)

    if input_type > 3 or (negative is not None and positive is not None):
        traces = main.generate_traces_for_nlg_example_output(declare_filename=declare_filename, filename=filename, algorithm=algorithm)
        #
        negative_redescription_path = os.path.abspath('redescription_mining/results/'+filename+'-'+algorithm+'-negative.queries')
        positive_redescription_path = os.path.abspath('redescription_mining/results/'+filename+'-'+algorithm+'-positive.queries')
        (set_of_rules, redescriptions, output) = main.nlgCall_v2(negative_redescriptions_path=negative_redescription_path, positive_redescriptions_path=positive_redescription_path, print_bool=True)

        output_compare = main.nlg_.apply_comparisons(set_of_rules=set_of_rules, filename=filename +'-'+algorithm)

        output += output_compare
        # print()
        output_deviant = main.print_trace_failure(traces=traces, k=5)

        output += output_deviant

        with open(os.path.abspath('nlg/output/'+filename+'-'+algorithm+'.txt'), 'wt') as a:
            a.write(output)

    print()
