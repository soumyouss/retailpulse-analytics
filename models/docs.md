{% docs customer_segment %}
Segmentation RFM basée sur l'historique d'achat :
- prospect : aucune commande
- nouveau : 1 commande complétée
- regulier : 2 à 4 commandes complétées
- vip : 5 commandes ou plus
- perdu : commandes passées mais toutes annulées/remboursées
{% enddocs %}

{% docs revenue %}
Montant de la commande uniquement si statut = completed.
Vaut 0 pour les commandes annulées, pending ou remboursées.
{% enddocs %}

{% docs lifetime_value %}
Somme de tous les revenus des commandes complétées du client.
Calculé depuis fct_orders, hors frais de livraison.
{% enddocs %}