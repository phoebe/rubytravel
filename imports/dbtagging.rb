select distinct * where {?a ?b category:Snow_tubing_areas_in_California  }
Category:Snow_tubing_areas_in_the_United_States
select distinct * where { ?c <http://www.w3.org/2004/02/skos/core#broader> category:Snow_tubing_areas_in_the_United_States . ?a <http://www.w3.org/2004/02/skos/core#subject> ?c}
select distinct * where { _:c <http://www.w3.org/2004/02/skos/core#broader> category:Snow_tubing_areas_in_the_United_States . ?a <http://www.w3.org/2004/02/skos/core#subject> _:c}
