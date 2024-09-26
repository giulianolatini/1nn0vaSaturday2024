# Introduzione

## Chi sono ?

Sono un appassionato d'informatica _diversamente giovane_ che ha gestito sistemi informatici professionalmente negli ultimi 35 anni, con piccole digressioni nel modo dello sviluppo software procedurale per calcolo scientifico prima che la programmazione ad oggetti e i sistemi RAD (Rapid Application Development) sono diventati disponibili<sup>[Biografia]</sup>.

## Di cosa parleremo ?

PowerShell usato nel monitoring di sistemi e applicazioni attraverso l'uso del protocollo securizzato HTTPS, di un TimeSeries DBMS come repository di eventi e di una engine di analisi dati per la generazione di alert e report.

Per essere piú specifico, l'intenzione é di fornire una serie di spunti per costruirsi in casa un sistema di monitoraggio di sistemi e applicazioni che sia in grado di raccogliere dati da piú sorgenti, di memorizzarli in un database di serie temporali e di analizzarli per generare alert e report, alternativo a soluzioni commerciali come Nagios, Zabbix, PRTG, ecc.

## Perché ?

Perché é divertente e perché é possibile. Spesso si pensa che per fare qualcosa di utile e di professionale sia necessario spendere soldi per acquistare software e hardware. In realtá, con un po' di impegno e di tempo, si possono ottenere risultati soddisfacenti con software open source e hardware di recupero.

## Come ?

Con l'ausilio di PowerShell, un linguaggio di scripting e di automazione di Microsoft, che é in grado di interagire con i sistemi operativi Windows e Linux, con i database SQL e NoSQL, con i servizi RESTful e con i servizi cloud. L'uso di HTTP(S) come canale di comunicazione tra i vari componenti del sistema permette di superare le barriere poste dai firewall e dai NAT. L'uso di un database di serie temporali permette di memorizzare dati riferiti temporalmente in modo efficiente e di analizzarli velocemente. L'uso di un engine di analisi dati permette di generare alert e report in modo flessibile richiamando script PowerShell.

## Gli strumenti necessari sono

- Un sistema operativo Windows 10 o Windows Server 2016 o Linux
- Un database InfluxDB
- Un engine di analisi dati Kapacitor
- Un sistema di monitoraggio Grafana
- Un sistema di notifica Telegram
- Un sistema di notifica Email e/o app mobile
  
---
[Biografia]: Biografia.md
