# @project Deviance Analysis by Means of Redescription Mining - Master Thesis
# @author Engjëll Ahmeti
# @date 1/19/2021
from nlg.extraction import Extraction

class Parentheses:
    def __init__(self, rule, extract=True):
        self.rule = rule

        extraction = Extraction('parentheses', self.rule, extract)

        self.tree = extraction.tree
        self.SPL = extraction.SPL
        self.CoNLL = extraction.CoNLL
        self.DSyntS = extraction.DSyntS

    def __str__(self):
        return self.rule.__str__()
        # return '(' + self.rule.__str__() + ')'

    # def extractTree(self):
    #     dict = {}
    #     dict['parentheses'] = self.rule.tree
    #
    #     return dict
    #
    # def extractCoNLL(self):
    #     dict = {}
    #     dict['parentheses'] = self.rule.CoNLL
    #
    #     return dict
    #
    # def extractDSyntS(self):
    #     dict = {}
    #     dict['parentheses'] = self.rule.DSyntS
    #
    #     return dict