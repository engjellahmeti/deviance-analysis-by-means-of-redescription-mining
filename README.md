# Deviance Analysis by means of Redescription Mining
With respect to an expected or desired outcome, business processes often deviate in their executions, where such executions can deviate in a positive or negative way. However, a business process cannot show the reason why the deviance has occurred, therefore, the deviance analysis is used. In general, deviance analysis belongs in the family of process mining and it aims to find the reason why an execution has violated the compliance rules of a process or why it is not meeting the performance targets through previous process executions stored in an event log. Hence, in this paper a concept for deviance analysis of process event logs of the same business process is proposed by means of redescription mining. The new data mining technique called redescription mining is able to mine positive rules that correspond to normal executions of the process and negative rules that correspond to deviant executions with over behavioral, data and organizational aspects of the traces. Finally, by comparing and analyzing the positive rules with the negative ones, the source of the deviance is found and then the deviance is explained in a natural language text that is generated based on the rules discovered by redescription mining. 

This code is the implementation of the approach stated above.

Just a map to where everything is:

Declare Files -> deviance-analysis-by-means-of-redescription-mining/event_log_generation/declare constraint files/

Event Logs -> deviance-analysis-by-means-of-redescription-mining/event_log_reader/logs/

Redescription Rules -> deviance-analysis-by-means-of-redescription-mining/redescription_mining/results/

NLG Output -> deviance-analysis-by-means-of-redescription-mining/nlg/output/


How to run the code:

    'python main.py -t <input_type> -a <algorithm> -f <filename> -d <declare_filename> -s <amount_of_traces> -i <min_trace_length> -x <max_trace_length>'

  - input_type - can be 1 (the input is only declare file), 2 (the input is only positive and negative event log), 3 (the input is positive and negative event log and declare file), 8 (this generates the NLG if the redescription rules are already discovered)
  - algorithm - can be either splittrees or reremi
  - filename - corresponds to the filename of the event log which should be placed in event_log_reader/logs
  - declare_filename - corresponds to the filename of the declare file which should be placed in event_log_generation/declare constraint files
  - amount_of_traces - number of amount of traces to be generated per event log
  - min_trace_length - the min. number of events per trace
  - max_trace_length - the max. number of events per trace
 
## Citations
If you're using *Deviance Analysis by means of Redescription Mining* approach in your research or applications, please cite using this BibTeX:
```
@InProceedings{10.1007/978-3-031-07475-2_7,
	author="K{\"a}ppel, Martin
	and Ahmeti, Engj{\"e}ll
	and Jablonski, Stefan",
	editor="Augusto, Adriano
	and Gill, Asif
	and Bork, Dominik
	and Nurcan, Selmin
	and Reinhartz-Berger, Iris
	and Schmidt, Rainer",
	title="Deviance Analysis by Means of Redescription Mining",
	booktitle="Enterprise, Business-Process and Information Systems Modeling",
	year="2022",
	publisher="Springer International Publishing",
	address="Cham",
	pages="91--107",
	abstract="Often business processes deviate in a positive or negative way from their expected or desired behavior. Deviance mining aims at detecting deviant process executions and at revealing their causes. In this paper we propose a novel approach for identifying the causes of a deviant process execution based on redescription mining, which extracts knowledge in form of logical rules. By analyzing, combining, and filtering these rules we identify the reasons for the deviating behavior of a business process in general as well as of particular process instances. Afterwards the results of this analysis are transformed into an understandable and well-readable natural language text that can be taken by business analysts and process owners to optimize processes in a reasoned manner.",
	isbn="978-3-031-07475-2"
}
```