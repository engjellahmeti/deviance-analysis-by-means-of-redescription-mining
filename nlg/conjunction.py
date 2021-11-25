# @project Deviance Analysis by Means of Redescription Mining - Master Thesis 
# @author Engjëll Ahmeti
# @date 1/20/2021
from nlg.extraction import Extraction

class Conjunction:
    def __init__(self, leftSide, rightSide, extract=True):
        self.leftSide = leftSide
        self.rightSide = rightSide

        extraction = Extraction('and', leftSide, extract,rightSide)

        self.tree = extraction.tree
        self.SPL = extraction.SPL
        self.CoNLL = extraction.CoNLL
        self.DSyntS = extraction.DSyntS

    def __str__(self) -> str:
        return self.leftSide.__str__() + 'and ' + self.rightSide.__str__()

    # def extractTree(self):
    #     dict = {}
    #     dict['and'] = [self.leftSide.tree, self.rightSide.tree]
    #
    #     return dict
    #
    # def extractCoNLL(self):
    #     dict = {}
    #     dict['and'] = [self.leftSide.CoNLL, self.rightSide.CoNLL]
    #
    #     return dict
    #
    # def extractDSyntS(self):
    #     dict = {}
    #     dict['and'] = [self.leftSide.DSyntS, self.rightSide.DSyntS]
    #
    #     return dict