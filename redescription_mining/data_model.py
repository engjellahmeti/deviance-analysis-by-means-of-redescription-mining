# @project Deviance Analysis by Means of Redescription Mining - Master Thesis 
# @author Engjëll Ahmeti
# @date 10/23/2021
from typing import List


class RedescriptionDataModel:
    def __init__(self, left_view: str, left_attributes: List[str], right_view: str, right_attributes: List[str]):
        self.left_view = left_view
        self.left_attributes = left_attributes
        self.right_view = right_view
        self.right_attributes = right_attributes
