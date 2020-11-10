/***
* Name: TP4Model
* Author: kevin
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model TP4Model

global {
	/** Insert the global definitions, variables and actions here */
	// add parameter to moddel
					  
	int nb_tree <- 200 parameter:"Number of tree"
					   category:'Tree' min:20 max:500;
					   
	int nb_feux <- 5 parameter:"Number of burning tree"
					   category:'Tree' min:1 max:50;
	
	float speed_pompier <- 2.0 parameter:"Speed of pompiers"
					   category:'Fireman' min:2.0 max:5.0;
					   
	int nb_pompiers <- 3 parameter:"Number of pompiers"
					   category:'Fireman' min:2 max:5;
	
	int rayon_perception <- 3 parameter:"Number of pompiers"
					   category:'Fireman' min:2 max:5;
	
	float fireman_watering_distance <- 3.0 parameter:"Distance to grow water"
					   category:'Fireman' min:2.0 max:5.0;
	
	int tree_drying_time <- 5 parameter:"Number of step in protect state"
							category:'Fireman' min:2 max:10;
					   
	int tree_burning_time <- 5 parameter:"Number of before diying"
							category:"Tree Burning" min:2 max:10;
	
	int tree_propagating_time <- 3 parameter:"Number of before burning"
							category:"Tree Burning" min:2 max:10;
	
	float tree_propagation_probability <- 0.01 parameter:"Probability for tree to propage fire"
							category:"Tree Burning" min:0.0 max:1.0;
							
	
							
	

	init{
		create tree number: nb_tree{
			size<-1+rnd(10.0);
			color<-rgb(100+rnd(155),100+rnd(155),100+rnd(155));
		}
		
		create tree_burning {
				ask target: nb_feux among(tree){
					set state<-'Burning';
				}
			}
			
		
		create pompier number: nb_pompiers{
			size<-1+rnd(4.0);
			color<-rgb(100+rnd(155),0,0);
			speed<-speed_pompier;
		}
		
		
		
		
	}
	
}

// agents
species name:tree skills:[] control:fsm{
		rgb color;
		float size <- 1 + rnd(5.0);
		int count;
		float range<-20.0;
		
		//les états
		state Intac initial:true{
			 color <- rgb(100 + rnd(155),100 + rnd(155),100 + rnd(155));
		}
		
		state Burning{
			
			color<-rgb(255,100+rnd(155),0);
			
			count<-count + 1;
			transition to: Destroyed when: (count > tree_burning_time);
			
			if(flip(1-tree_propagation_probability)){
				 	
				 	if(count > tree_propagating_time){
				 		
						ask target: (self neighbors_at range) where (each.state = 'Intac'){
							
							set state<-"Burning";
//							create tree_burning{
//								self.size<-myself.size;
//								self.location<-myself.location;
//							}
						}
						
					}	 
			}
			
		}
		
		state Destroyed{
				create tree_dead{
					self.location<-myself.location;
				}
				do action:die;
		}
		
		state Protected{
			 color <-rgb(0,255,0);
		}
		
		aspect basic{
			draw triangle(size) color:color; 
		}
}

species name:tree_burning skills:[]{
		float size ;
		rgb color<-rgb(255,100+rnd(155),0);	
				
		aspect basic{
			draw triangle(size) color:color; 
		}
}

species name:tree_dead skills:[]{
		rgb color<-rgb("black");//#green
		float size<-3.0;
		
		aspect basic{
			draw triangle(size) color:color; 
		}
}

species name:pompier skills:[moving] {
		rgb color init:rgb('red'); 
		float size init: 4.0;
		float n_speed init: 2.0;
		tree target;
		
//		reflex patrolling{
//			do action: wander speed:n_speed amplitude:180.0;
//		}
		
		reflex search_target when:target=nil{
			
			do action: wander speed:n_speed amplitude:180.0;
			
			ask list(tree) at_distance(rayon_perception) where (each.state = 'Burning') sort_by(self distance_to each) {
				myself.target <- self;
			}
		}
		
		reflex follow when:target!=nil {
			speed <- 0.8;
			do action: goto target:target;
		}
		
		reflex save_tree when:target!=nil{
			set  target.state <- "Protected";
			target<-nil;
		}
		
		
		aspect basic{
			draw square(size) color:color; 
			// lier pompier et sa cible
			if (target!=nil) {
				draw polyline([self.location,target.location]) color:#black;
			}
		}
}


experiment TP4Model type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		
		display Forest{
			species tree aspect:basic;
			species tree_burning aspect:basic;
			species tree_dead aspect:basic;
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
