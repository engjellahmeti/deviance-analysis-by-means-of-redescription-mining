# @project Deviance Analysis by Means of Redescription Mining - Master Thesis 
# @author Engjëll Ahmeti
# @date 1/23/2021
from nlg.extraction import Extraction

class Implication:
    def __init__(self, leftSide, rightSide, extract=True, constraintType='', leftRule=None, rightRule=None, ruleID=None):
        self.leftSide = leftSide
        self.rightSide = rightSide
        self.constraintType = constraintType
        self.leftRule = leftRule
        self.rightRule = rightRule
        self.ruleID = ruleID
        
        
        extraction = Extraction('imply', leftSide, extract,rightSide)

        self.tree = extraction.tree
        self.SPL = extraction.SPL
        self.CoNLL = extraction.CoNLL
        self.DSyntS = extraction.DSyntS

    def __str__(self) -> str:
        return 'If ' + self.leftSide.__str__() + 'that implicates that ' + (self.rightSide.__str__()).strip() + '.'
