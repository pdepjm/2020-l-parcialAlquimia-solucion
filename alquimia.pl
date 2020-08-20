tiene(ana, agua).
tiene(ana, vapor).
tiene(ana, tierra).
tiene(ana, hierro).
tiene(beto, Elemento) :-
    tiene(ana, Elemento).
tiene(cata, fuego).
tiene(cata, agua).
tiene(cata, aire).
tiene(cata, tierra).

jugador(Jugador) :-
    tiene(Jugador, _).

compuesto(pasto, [agua, tierra]).
compuesto(silicio, [tierra]).
compuesto(hierro, [fuego, agua, tierra]).
compuesto(vapor, [agua, fuego]).

compuesto(huesos, [pasto, agua]).
compuesto(presion, [hierro, vapor]).

compuesto(plástico, [huesos, presion]).
compuesto(play, [silicio, hierro, plástico]).

elemento(Elemento) :-
    compuesto(Elemento, _).
elemento(Elemento) :-
    necesita(_, Elemento).

% Además, se tiene la siguiente base de conocimientos:
herramienta(ana, circulo(50, 3)).
herramienta(ana, cuchara(40)).
herramienta(beto, circulo(20, 1)).
herramienta(beto, libro(inerte)).
herramienta(cata, libro(vida)).
herramienta(cata, circulo(100, 5)).

% % Los círculos alquímicos tienen diámetro en cms y cantidad de niveles.
% % Las cucharas tienen una longitud en cms.
% Hay distintos tipos de libro.


% Saber si un jugador tieneIngredientes para construir un elemento, que es cuando tiene en su inventario todo lo que hace falta.
tieneIngredientesPara(Jugador, Elemento) :-
    jugador(Jugador),
    compuesto(Elemento, _),
    forall(necesita(Elemento, Ingrediente), tiene(Jugador, Ingrediente)).

necesita(Elemento, Ingrediente) :-
    compuesto(Elemento, Ingredientes),
    member(Ingrediente, Ingredientes).

/* Criterio corrección: 
- Qué onda el generador??
*/
:- begin_tests(punto_2).
test(ana_tiene_los_ingredientes_para_el_pasto, nondet) :-
    tieneIngredientesPara(ana, pasto).
test(pero_no_para_el_vapor, fail) :-
    tieneIngredientesPara(ana, vapor).
:- end_tests(punto_2).




% Saber si alguien es todopoderoso, que es cuando tiene todos los elementos primitivos (los que no pueden construirse a partir de nada).
todopoderoso(Jugador) :-
    jugador(Jugador),
    esPrimitivo(Jugador),
    estaArmadoHastaLosDientes(Jugador).

esPrimitivo(Jugador) :-
    forall(primitivo(Elemento), tiene(Jugador, Elemento)).

estaArmadoHastaLosDientes(Jugador) :-
    forall(elementoFaltante(Jugador, Elemento),
           tieneHerramientaPara(Jugador, Elemento)).

primitivo(Elemento) :-
    elemento(Elemento),
    not(compuesto(Elemento, _)).

elementoFaltante(Jugador, Elemento) :-
    elemento(Elemento),
    not(tiene(Jugador, Elemento)).


/* Criterio corrección: 
  Lo difícil de este punto es generar el elemento.
*/:- begin_tests(punto_3).
test(cata_es_todopoderosa, nondet) :-
    todopoderoso(cata).
test(pero_beto_no, fail) :-
    todopoderoso(beto).
:- end_tests(punto_3).


% Saber si un elemento estaVivo. Se sabe que el agua, el fuego y todo lo que los contenga están vivos. Debe funcionar para cualquier nivel.
estaVivo(agua).
estaVivo(fuego).
estaVivo(Elemento) :-
    necesita(Elemento, Ingrediente),
    estaVivo(Ingrediente).

/* Criterio corrección: 
  Es un caso simple de recursión. Verificar lo de siempre: caso base, etc.
*/:- begin_tests(punto_4).
test(play_station_esta_viva, nondet) :-
    estaVivo(play).
test(pero_el_silicio_no, fail) :-
    estaVivo(silicio).
:- end_tests(punto_4).

% Conocer las personas que puedeConstruir un elemento, para lo que se necesita tener los ingredientes y además contar con una o más herramientas que sirvan. 
% Para los elementos vivos sirve el libro de la vida (y para los no vivos el libro inerte). Además, las cucharas y círculos sirven cuando soportan la cantidad de ingredientes del elemento (las cucharas tantos ingredientes como centímetros/10, y los círculos alquímicos tantos ingredientes como metros * cantidad de niveles).
puedeConstruir(Jugador, Elemento) :-
    tieneIngredientesPara(Jugador, Elemento),
    tieneHerramientaPara(Jugador, Elemento).

tieneHerramientaPara(Jugador, Elemento) :-
    herramienta(Jugador, Herramienta),
    sirveParaConstruir(Herramienta, Elemento).

sirveParaConstruir(libro(vida), Elemento) :-
    estaVivo(Elemento).
sirveParaConstruir(libro(inerte), Elemento) :-
    not(estaVivo(Elemento)).
sirveParaConstruir(Herramienta, Elemento) :-
    cantidadQueSoporta(Herramienta, Soporte),
    cantidadQueNecesita(Elemento, Necesario),
    Soporte>=Necesario.

cantidadQueSoporta(cuchara(Cms), Cantidad) :-
    Cantidad is Cms/10.
cantidadQueSoporta(circulo(Cms, Nivel), Cantidad) :-
    Cantidad is Cms/100*Nivel.

cantidadQueNecesita(Elemento, Cantidad) :-
    compuesto(Elemento, Ingredientes),
    length(Ingredientes, Cantidad).  

/* Criterio corrección: 
  Este es el punto!
*/:- begin_tests(punto_5).
test(beto_puede_construir_el_silicio, nondet) :-
    puedeConstruir(beto, silicio).
test(pero_no_puede_construir_la_presion, fail) :-
    puedeConstruir(beto, presion).
test(ana_puede_construir_el_silicio, nondet) :-
    puedeConstruir(ana, silicio).
test(y_tamibne_la_presion, nondet) :-
    puedeConstruir(ana, presion).
:- end_tests(punto_5).

% Conocer quienGana, que es quien puede construir más cosas.
quienGana(Jugador) :-
    cantidadQuePuedeConstruir(Jugador, Maximo),
    forall(cantidadQuePuedeConstruir(_, Cantidad),
           Maximo>=Cantidad).
  

cantidadQuePuedeConstruir(Jugador, Cantidad) :-
    jugador(Jugador),
    findall(Elemento,
            distinct(Elemento, puedeConstruir(Jugador, Elemento)),
            Elementos),
    length(Elementos, Cantidad).




:- begin_tests(punto_6).
test(cata_es_ganadora, nondet) :-
    quienGana(cata).
test(pero_beto_no, fail) :-
    quienGana(beto).
:- end_tests(punto_6).

% Bonus:
% Saber si un jugador podriaTener un elemento, que es cuando combinando los elementos que tiene todas las veces que sea necesario, podría llegar a construir un elemento. En otras palabras, podría tener un elemento cuando podría tener todo lo necesario para construir ese elemento.
% Por ejemplo, XXXXX podría llegar a tener una play station.
podriaConstruir(Jugador, Elemento) :-
  tiene(Jugador, Elemento).

podriaConstruir(Jugador, Elemento) :-
  elemento(Elemento), jugador(Jugador),
  tieneHerramientaPara(Jugador,Elemento),
  forall(necesita(Elemento, Ingrediente), podriaConstruir(Jugador, Ingrediente)).