# @project Deviance Analysis by Means of Redescription Mining - Master Thesis
# @author Engjëll Ahmeti
# @date 12/10/2020


import os
import shutil
from clired import exec_clired
from clired.classData import Data
import pandas as pd
from pandas.core.frame import DataFrame
from log_print import Print
import re
from redescription_mining.data_model import RedescriptionDataModel

class RedescriptionMining:
    def __init__(self):
        self.configuration = ''

    def discover_redescriptions(self, redescription_data_model: RedescriptionDataModel, is_positive_or_negative_log: str, left_activity: str, right_activity: str, algorithm: str = 'reremi', config_or_template='config', filename='results') -> DataFrame:
        Print.YELLOW.print('Started extrating redescriptions. ')
        if len(redescription_data_model.left_attributes) == 0 and len(redescription_data_model.right_attributes) == 0:
            return DataFrame()

        if config_or_template == 'config':
            config_path ="redescription_mining/configs/config.txt"
        else:
            config_path ="redescription_mining/configs/template.txt"

        full_config_path = os.path.abspath(config_path)

        self.setConfiguration(full_config_path=full_config_path, algorithm=algorithm, redescription_data_model=redescription_data_model)

        exec_clired.run([None, full_config_path])

        self.reset_configuration(full_config_path)

        redescriptions = self.rename_redescriptions(redescriptions_path=os.path.abspath('__TMP_DIR__results.queries'), move_redescriptions_to_path=os.path.abspath('redescription_mining/results/') + '/' + filename + '-'+is_positive_or_negative_log+'.queries', redescription_data_model=redescription_data_model, left_activity=left_activity, right_activity=right_activity)

        Print.YELLOW.print('Redescriptions have been generated.')

        return redescriptions

    def setConfiguration(self, full_config_path: str, algorithm: str, redescription_data_model: RedescriptionDataModel):
        Print.YELLOW.print('Setting up configurations.')
        LHS_data = os.path.abspath(redescription_data_model.left_view)
        RHS_data = os.path.abspath(redescription_data_model.right_view)

        xml_string = open(full_config_path, mode='r').read()
        if 'LHS_data.csv' not in xml_string:
            temp = re.sub('\.txt', '-sample.txt', full_config_path)
            xml_string = open(temp, mode='r').read()

        self.configuration = xml_string

        xml_string = xml_string.replace('LHS_data.csv', LHS_data)
        xml_string = xml_string.replace('RHS_data.csv', RHS_data)
        xml_string = xml_string.replace('algorithm.csv', algorithm)


        with open(full_config_path, mode='w') as a:
            a.write(xml_string)

    def reset_configuration(self, full_config_path: str):
        temp = re.sub('\.txt', '-sample.txt', full_config_path)
        xml_string = open(temp, mode='r').read()
        with open(full_config_path, mode='w') as a:
            a.write(xml_string)

    def rename_redescriptions(self, redescriptions_path: str, move_redescriptions_to_path: str, redescription_data_model: RedescriptionDataModel, left_activity: str, right_activity: str):
        redescriptions = pd.read_csv(redescriptions_path, delimiter='\t')
        l_vs = {}
        LHS_vars = redescription_data_model.left_attributes
        RHS_vars = redescription_data_model.right_attributes

        for i in range(0, len(LHS_vars)):
            l_vs['v' +str(i)] = LHS_vars[i]

        r_vs = {}
        for i in range(0, len(RHS_vars)):
            r_vs['v' +str(i)] = RHS_vars[i]

        activity_left = []
        rules_Left = []
        left_vars = []
        for row in redescriptions['query_LHS']:
            fields = ''
            activity_left.append(left_activity)
            for v in l_vs.keys():
                row = row.replace(v, l_vs[v])

                if l_vs[v] in row:
                    if fields == '':
                        fields = l_vs[v]
                    else:
                        fields = fields + ',' + l_vs[v]

            left_vars.append(fields)
            rules_Left.append(row)

        redescriptions['query_LHS'] = rules_Left
        redescriptions['LHS_vars'] = left_vars
        redescriptions['LHS_activity'] = activity_left



        activity_right = []
        rules_Right = []
        right_vars = []
        for row in redescriptions['query_RHS']:
            fields = ''
            activity_right.append(right_activity)
            for v in r_vs.keys():
                row = row.replace(v, r_vs[v])

                if r_vs[v] in row:
                    if fields == '':
                        fields = r_vs[v]
                    else:
                        fields = fields + ',' + r_vs[v]

            right_vars.append(fields)
            rules_Right.append(row)

        redescriptions['query_RHS'] = rules_Right
        redescriptions['RHS_vars'] = right_vars
        redescriptions['RHS_activity'] = activity_right

        redescriptions.drop(redescriptions.columns[9], axis=1, inplace=True)


        redescriptions.to_csv(redescriptions_path, index=False)


        shutil.move(redescriptions_path, move_redescriptions_to_path)

        return redescriptions
