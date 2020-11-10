/***
* Name: TP2Model
* Author: kevin
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model TP2Model

/* Insert your model definition here */

/***
* Name: firstModel
* Author: kevin
* Description: 
* Tags: Tag1, Tag2, TagN
***/


global {
	/** Insert the global definitions, variables and actions here */
	
	// add parameter to moddel
					  
	int nb_tree <- 200 parameter:'Number of tree'
					   category:'Tree' min:20 max:500;
					   
	int nb_feux <- 5 parameter:'Number of burning tree'
					   category:'Tree' min:1 max:50;
					   
	int nb_pompiers <- 3 parameter:'Number of pompiers'
					   category:'Tree' min:2 max:5;
	
	float speed_pompier <- 2.0 parameter:'Speed of pompiers'
					   category:'Tree' min:2.0 max:5.0;

	init{
		create tree number: nb_tree{
			size<-1+rnd(10.0);
			color<-rgb(0,100+rnd(155),0);
		}
		
		create pompier number: nb_pompiers{
			size<-1+rnd(4.0);
			color<-rgb(100+rnd(155),0,0);
			speed<-speed_pompier;
		}
		
		ask target: nb_feux among(tree){
			set state<-'Burning';
		}
		
	}
	
	
}

// agents
species name:tree skills:[] control:fsm{
		rgb color init:rgb('green'); //#green
		float size init: 5.0;
		int treshold<-50+rnd(50);
		int count<-0;
		float range<-20.0;
		
		//les états
		state Intac initial:true{
			color<-rgb(0,100+rnd(155),0);
		}
		
		state Burning{
			color<-rgb(255,100+rnd(155),0);
			count<-count + 1;
			transition to: Destroyed when: (count > treshold);
			
			if(flip(0.01)){
				ask target: (self neighbors_at range) where (each.state = 'Intac'){
					set state<-'Burning';
				}
			}
		}
		
		state Destroyed{
			color<-rgb(#black);
			size<-3.0;
		}
		
		aspect basic{
			draw triangle(size) color:color; // circle, square, dot, rounded, line
		}
}

species name:pompier skills:[moving] {
		rgb color init:rgb('red'); 
		float size init: 4.0;
		float speed init: 2.0;
		
		
		reflex patrolling{
			do action: wander speed:speed amplitude:180.0;
		}
		
		aspect basic{
			draw square(size) color:color; // circle, square, dot, rounded, line
		}
}


experiment TP2Model type: gui {
	/** Insert here the definition of the input and output of the model */
	
	output {
		display Forest{
			species tree aspect:basic;
			species pompier aspect:basic;
		}
		
		display tree_distribution{
			chart "td_diagram" type:pie{
				data "under_4m" value:length (list (tree)
				where (each.size < 4) )color:rgb(100+rnd(155));
				
				data "between_4_and_7m" value:length (list (tree)
				where ( each.size > 4 and each.size < 7 ) )color:rgb(100+rnd(155),0,0);
				
				data "over_7m" value:length (list (tree)
				where (each.size > 7) ) color:rgb(100+rnd(155));
			
			}
			
		}
		
	}
}
